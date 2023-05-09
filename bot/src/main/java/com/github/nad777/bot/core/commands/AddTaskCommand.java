package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.core.MarkdownProcessor;
import com.github.nad777.bot.core.State;
import com.github.nad777.bot.core.UserMessageProcessor;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

@Component
public class AddTaskCommand implements Command {
    private final static String COMMAND = "/add_task";
    private final static String DESCRIPTION = "Command to add your task to database";
    private final static String MESSAGE = """
            Now, you need to send the following information about your task. Please, send this info in one message.
            `Task name`
            `Amount os tests`
            `Memory limit` -- An integer number of MB
            `Time limit` -- An float number of seconds""";

    @Override
    public String command() {
        return COMMAND;
    }

    @Override
    public String description() {
        return DESCRIPTION;
    }

    @Override
    public SendMessage handle(@NotNull Update update) {
        Long chatId = update.message().chat().id();

        UserMessageProcessor.setState(chatId, State.WAITING_FOR_TASK_INFO, null);

        return new SendMessage(chatId, MarkdownProcessor.process(MESSAGE));
    }
}
