package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.client.JugglerClient;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class StartCommand implements Command {
    private final JugglerClient jugglerClient;

    private final static String COMMAND = "/start";
    private final static String DESCRIPTION = "Register and start chat";
    private final static String WELCOME = "Welcome! Type /help for a list of commands.";

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
        jugglerClient.registerChat(chatId);
        return new SendMessage(chatId, WELCOME);
    }
}
