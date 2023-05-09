package com.github.nad777.bot.core;

import com.github.nad777.bot.client.JugglerClient;
import com.github.nad777.bot.client.requests.AddTaskRequest;
import com.github.nad777.bot.client.requests.SubmitTaskRequest;
import com.github.nad777.bot.client.responses.AddTaskResponse;
import com.github.nad777.bot.client.responses.SubmitTaskResponse;
import com.github.nad777.bot.core.commands.Command;
import com.pengrad.telegrambot.TelegramBot;
import com.pengrad.telegrambot.model.Document;
import com.pengrad.telegrambot.model.File;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.GetFile;
import com.pengrad.telegrambot.request.SendMessage;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.jetbrains.annotations.Nullable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClientResponseException;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
public class UserMessageProcessor {
    private final TelegramBot telegramBot;
    private final JugglerClient jugglerClient;
    private static List<? extends Command> commandList;
    private static final Map<Long, StateInfo> STATE_MAP = new HashMap<>();
    private static final Map<Long, AddTaskRequest> ADD_TASK_REQUEST_MAP = new HashMap<>();
    private final static String FILE_EXPECTED = "File expected! Try again or press /cancel";
    private final static String SUBMITTED_FILE = "You've submitted file.\n";
    private final static String LARGE_FILE = "File is too large. Try again or press /cancel";
    private final static String WRONG_FORMAT = "Format of message you provided is wrong. Try again or press /cancel";
    private final static String CORRECT_TASK_INFO = "Now you need to send a *.pdf* file with task description.";
    private final static String CORRECT_TASK_FILE = """
            Finally, you should provide your master solution. Only *.py* or *.java* files are supported.

            *### MASTER SOLUTION CONVENTIONS ###*
            Each master solution must obey the following rules:
                - master solution executable file must parse 1 argument, namely `sample` which determines if data generator wants to generate sample or run the solution
                - master solution uses stdin and stdout as input and output stream correspondingly
            """;
    private final static long MAX_FILE_SIZE = 2 * 1024 * 1024;
    private final static String UNSUPPORTED_COMMAND = "Unsupported command";

    @Autowired
    public UserMessageProcessor(TelegramBot telegramBot, JugglerClient jugglerClient, List<? extends Command> commandList) {
        this.telegramBot = telegramBot;
        this.jugglerClient = jugglerClient;
        UserMessageProcessor.commandList = commandList;
    }

    public static List<? extends Command> commands() {
        return commandList;
    }

    public SendMessage process(@NotNull Update update) {
        if (update.message() == null) {
            return null;
        }
        long chatId = update.message().chat().id();
        StateInfo stateInfo = STATE_MAP.get(chatId);
        String text = update.message().text();

        if (text != null) {
            log.info("Get user message: \"" + text + "\"");
        }
        if (update.message().document() != null) {
            log.info("Get document from user");
        }

        if (text != null && text.equals("/cancel")) {
            ADD_TASK_REQUEST_MAP.remove(chatId);
            STATE_MAP.remove(chatId);
            return null;
        } else if (stateInfo == null || stateInfo.getState() == State.WAITING_FOR_COMMAND) {
            if (text == null) {
                throw new UnsupportedOperationException(UNSUPPORTED_COMMAND);
            }
            if (text.startsWith("/")) {
                for (Command c : commands()) {
                    if (c.supports(update)) {
                        return c.handle(update);
                    }
                }
            }
        } else if (stateInfo.getState() == State.WAITING_FOR_TASK_TO_SUBMIT) {
            if (update.message().document() == null) {
                return new SendMessage(chatId, MarkdownProcessor.process(FILE_EXPECTED));
            }
            Document document = update.message().document();
            if (document.fileSize() > MAX_FILE_SIZE) {
                return new SendMessage(chatId, MarkdownProcessor.process(LARGE_FILE));
            }
            String fileName = document.fileName();
            byte[] file = getFileFromDocument(document);
            // Send file to juggler
            SubmitTaskRequest request = new SubmitTaskRequest(fileName, stateInfo.getTaskId(), file);
            try {
                SubmitTaskResponse response = jugglerClient.submitTask(chatId, request);
                log.info(response.toString());
                return new SendMessage(chatId, MarkdownProcessor.process(SUBMITTED_FILE + response));
            } catch (WebClientResponseException e) {
                if (e.getStatusCode() != HttpStatus.UNSUPPORTED_MEDIA_TYPE) {
                    throw e;
                }
                return new SendMessage(chatId, MarkdownProcessor.process(WRONG_FORMAT));
            }
        } else if (stateInfo.getState() == State.WAITING_FOR_TASK_INFO) {
            if (text == null) {
                throw new UnsupportedOperationException(UNSUPPORTED_COMMAND);
            }
            AddTaskRequest request = parseInfoMessage(text);
            if (request == null) {
                return new SendMessage(chatId, MarkdownProcessor.process(WRONG_FORMAT));
            }
            ADD_TASK_REQUEST_MAP.put(chatId, request);
            STATE_MAP.get(chatId).setState(State.WAITING_FOR_TASK_FILE);
            return new SendMessage(chatId, MarkdownProcessor.process(CORRECT_TASK_INFO));
        } else if (stateInfo.getState() == State.WAITING_FOR_TASK_FILE) {
            if (update.message().document() == null) {
                return new SendMessage(chatId, MarkdownProcessor.process(FILE_EXPECTED));
            }
            Document document = update.message().document();
            if (document.fileSize() > MAX_FILE_SIZE) {
                return new SendMessage(chatId, MarkdownProcessor.process(LARGE_FILE));
            }
            String fileName = document.fileName();
            if (!fileName.endsWith(".pdf")) {
                return new SendMessage(chatId, MarkdownProcessor.process(WRONG_FORMAT));
            }
            byte[] file = getFileFromDocument(document);
            ADD_TASK_REQUEST_MAP.get(chatId).setTaskFile(file);
            ADD_TASK_REQUEST_MAP.get(chatId).setTaskFilename(fileName);
            STATE_MAP.get(chatId).setState(State.WAITING_FOR_MASTER_SOLUTION);
            return new SendMessage(chatId, MarkdownProcessor.process(CORRECT_TASK_FILE));
        } else if (stateInfo.getState() == State.WAITING_FOR_MASTER_SOLUTION) {
            if (update.message().document() == null) {
                return new SendMessage(chatId, MarkdownProcessor.process(FILE_EXPECTED));
            }
            Document document = update.message().document();
            if (document.fileSize() > MAX_FILE_SIZE) {
                return new SendMessage(chatId, MarkdownProcessor.process(LARGE_FILE));
            }
            String fileName = document.fileName();
            if (!fileName.endsWith(".py") && !fileName.endsWith(".java")) {
                return new SendMessage(chatId, MarkdownProcessor.process(WRONG_FORMAT));
            }
            byte[] file = getFileFromDocument(document);
            ADD_TASK_REQUEST_MAP.get(chatId).setMasterFilename(fileName);
            ADD_TASK_REQUEST_MAP.get(chatId).setMasterFile(file);

            AddTaskResponse response = jugglerClient.addTask(chatId, ADD_TASK_REQUEST_MAP.get(chatId));
            log.info(response.toString());

            STATE_MAP.remove(chatId);
            ADD_TASK_REQUEST_MAP.remove(chatId);

            return new SendMessage(chatId, MarkdownProcessor.process("STATUS: " + response.status()));
        }

        throw new UnsupportedOperationException(UNSUPPORTED_COMMAND);
    }

    public static void setState(Long chatId, State state, String taskId) {
        if (STATE_MAP.containsKey(chatId)) {
            StateInfo stateInfo = STATE_MAP.get(chatId);
            stateInfo.setState(state);
            stateInfo.setTaskId(taskId);
        }
        STATE_MAP.put(chatId, new StateInfo(chatId, state, taskId));
    }

    public static void removeState(Long chatId) {
        STATE_MAP.remove(chatId);
    }

    @Nullable
    private AddTaskRequest parseInfoMessage(@NotNull String message) {
        try {
            AddTaskRequest request = new AddTaskRequest();
            String[] list = message.split("\n");
            request.setTaskName(list[0]);
            request.setAmountTest(Integer.parseInt(list[1]));
            request.setMemoryLimit(Integer.parseInt(list[2]));
            request.setTimeLimit(Float.parseFloat(list[3].replaceAll(",", ".")));
            return request;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private byte[] getFileFromDocument(@NotNull Document document) {
        String fileId = document.fileId();
        GetFile getFile = new GetFile(fileId);
        File file = telegramBot.execute(getFile).file();
        byte[] fileBytes;
        try {
            fileBytes = telegramBot.getFileContent(file);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
        return fileBytes;
    }
}
