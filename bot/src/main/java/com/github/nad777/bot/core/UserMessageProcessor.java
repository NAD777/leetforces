package com.github.nad777.bot.core;

import com.github.nad777.bot.client.JugglerClient;
import com.github.nad777.bot.client.requests.SubmitTaskRequest;
import com.github.nad777.bot.core.commands.Command;
import com.pengrad.telegrambot.TelegramBot;
import com.pengrad.telegrambot.model.Document;
import com.pengrad.telegrambot.model.File;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.GetFile;
import com.pengrad.telegrambot.request.SendMessage;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;

@Component
public class UserMessageProcessor {
    private final TelegramBot telegramBot;
    private final JugglerClient jugglerClient;
    private static List<? extends Command> commandList;
    private static State currentState = State.WAITING_FOR_COMMAND;
    private static String previousCommand;
    private final static String UNSUPPORTED_COMMAND = "Sorry, I don't understand you. Try /help to see list of commands";
    private final static String FILE_EXPECTED = "File with solution expected!";
    private final static String LARGE_FILE = "File is too large.";
    private final static String SUBMITTED_FILE = "You've submitted file.";
    private final static long MAX_FILE_SIZE = 2 * 1024 * 1024;

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
        switch (currentState) {
            case WAITING_FOR_COMMAND -> {
                if (update.message().text() == null) {
                    return new SendMessage(chatId, UNSUPPORTED_COMMAND);
                }
                String command = update.message().text();
                if (command.startsWith("/")) {
                    for (Command c : commands()) {
                        if (c.supports(update)) {
                            previousCommand = command;
                            return c.handle(update);
                        }
                    }
                }
            }
            case WAITING_FOR_FILE -> {
                if (update.message().document() == null) {
                    currentState = State.WAITING_FOR_COMMAND;
                    return new SendMessage(chatId, FILE_EXPECTED);
                }
                // get document
                Document document = update.message().document();
                //check if it isn't too large
                if (document.fileSize() > MAX_FILE_SIZE) {
                    return new SendMessage(chatId, LARGE_FILE);
                }
                String fileName = document.fileName();
                String fileId = document.fileId();
                GetFile getFile = new GetFile(fileId);
                File file = telegramBot.execute(getFile).file();
                byte[] fileBytes;
                try {
                    fileBytes = telegramBot.getFileContent(file);
                } catch (IOException e) {
                    throw new RuntimeException(e);
                }
                // send file to juggler
                String taskId = previousCommand.substring("/task_no_".length());
                SubmitTaskRequest request = new SubmitTaskRequest(fileName, taskId, fileBytes);
                jugglerClient.submitTask(chatId, request);
                return new SendMessage(chatId, SUBMITTED_FILE);
            }
        }

        return new SendMessage(chatId, UNSUPPORTED_COMMAND);
    }

    public static void setState(State state) {
        currentState = state;
    }
}
