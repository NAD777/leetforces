package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.client.JugglerClient;
import com.github.nad777.bot.client.responses.TaskFileResponse;
import com.github.nad777.bot.core.State;
import com.github.nad777.bot.core.UserMessageProcessor;
import com.pengrad.telegrambot.TelegramBot;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendDocument;
import com.pengrad.telegrambot.request.SendMessage;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class TaskCommand implements Command {
    private final TelegramBot telegramBot;
    private final JugglerClient jugglerClient;

    private static final String COMMAND = "/task_no_";
    private static final String DESCRIPTION = "Command to get task by task id";
    private static final String MESSAGE =
            "Here is your file with task description. You can submit task solution in the next message. Only __.py__ or __.java__ files are supported";

    @Override
    public String command() {
        return COMMAND + "{task_id}";
    }

    @Override
    public String description() {
        return DESCRIPTION;
    }

    @Override
    public SendMessage handle(@NotNull Update update) {
        long chatId = update.message().chat().id();
        String taskId = update.message().text().substring(COMMAND.length());
        TaskFileResponse response = jugglerClient.getTaskById(taskId);

        SendDocument sendDocument = new SendDocument(chatId, response.taskFile());
        telegramBot.execute(sendDocument);

        UserMessageProcessor.setState(State.WAITING_FOR_FILE);
        return new SendMessage(chatId, MESSAGE);
    }

    @Override
    public boolean supports(@NotNull Update update) {
        return update.message().text().startsWith(COMMAND)
                && update.message().text().length() > COMMAND.length()
                && update.message().text().split(" ").length == 1;
    }
}
