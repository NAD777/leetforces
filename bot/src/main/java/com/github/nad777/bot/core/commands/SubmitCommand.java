package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.core.MarkdownProcessor;
import com.github.nad777.bot.core.State;
import com.github.nad777.bot.core.UserMessageProcessor;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

@Component
public class SubmitCommand implements Command {
    private static final String COMMAND = "/submit_";
    private static final String DESCRIPTION = "Command to submit task by task id";
    private static final String MESSAGE = """
            Now you can submit task solution in the next message. Only *.py* or *.java* files are supported
            You can submit one more solution immediately after submitting previous without any additional commands.
            If you don't want to send any more solutions to current task, just press /cancel""";

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

        UserMessageProcessor.setState(chatId, State.WAITING_FOR_TASK_TO_SUBMIT, taskId);

        return new SendMessage(chatId, MarkdownProcessor.process(MESSAGE));
    }

    @Override
    public boolean supports(@NotNull Update update) {
        return update.message().text().startsWith(COMMAND)
                && update.message().text().length() > COMMAND.length()
                && update.message().text().split(" ").length == 1;
    }
}
