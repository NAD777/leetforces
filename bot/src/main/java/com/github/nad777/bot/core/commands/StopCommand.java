package com.github.nad777.bot.core.commands;

import com.github.nad777.bot.client.JugglerClient;
import com.github.nad777.bot.core.MarkdownProcessor;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Component
@RequiredArgsConstructor
public class StopCommand implements Command {
    private final JugglerClient jugglerClient;

    private final static String COMMAND = "/stop";
    private final static String DESCRIPTION = "Unregister and stop receiving messages";
    private final static String MESSAGE = "Unregistered successfully";

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
        try {
            jugglerClient.deleteChat(chatId);
            return new SendMessage(chatId, MarkdownProcessor.process(MESSAGE));
        } catch (WebClientResponseException e) {
            if (e.getStatusCode() != HttpStatus.NOT_FOUND) {
                throw e;
            }
            return null;
        }
    }
}
