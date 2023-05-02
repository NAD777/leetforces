package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.client.JugglerClient;
import com.github.nad777.bot.client.responses.ListTasksResponse;
import com.github.nad777.bot.client.responses.TaskResponse;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ListCommand implements Command {
    private final JugglerClient jugglerClient;

    private final static String COMMAND = "/list";
    private final static String DESCRIPTION = "Show all available tasks to solve";

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
        long chatId = update.message().chat().id();
        ListTasksResponse response = jugglerClient.getTasks();
        if (response.list() == null) {
            return new SendMessage(chatId, "There are no available tasks at the moment");
        }
        StringBuilder builder = new StringBuilder();
        builder.append("Here is the list of available tasks:\n\n");
        for (TaskResponse e : response.list()) {
            builder.append(e.taskName()).append("\n");
            builder.append("/task_no_").append(e.taskId()).append("\n\n");
        }
        return new SendMessage(chatId, builder.toString());
    }
}
