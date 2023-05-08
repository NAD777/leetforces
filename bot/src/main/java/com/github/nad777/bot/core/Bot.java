package com.github.nad777.bot.core;

import com.github.nad777.bot.core.commands.Command;
import com.pengrad.telegrambot.TelegramBot;
import com.pengrad.telegrambot.UpdatesListener;
import com.pengrad.telegrambot.model.BotCommand;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.model.request.ParseMode;
import com.pengrad.telegrambot.request.SendMessage;
import com.pengrad.telegrambot.request.SetMyCommands;
import com.pengrad.telegrambot.response.BaseResponse;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class Bot implements AutoCloseable, UpdatesListener {
    private final TelegramBot telegramBot;
    private final UserMessageProcessor userMessageProcessor;

    private final static String ERROR = "Error while sending message: ";
    private final static String UNSUPPORTED_COMMAND = "Sorry, I don't understand you. Try /help to see list of commands";

    @PostConstruct
    public void start() {
        setCommands();
        telegramBot.setUpdatesListener(this);
    }

    @Override
    public int process(@NotNull List<Update> updates) {
        updates.forEach(update -> {
            SendMessage message;
            try {
                message = userMessageProcessor.process(update);
            } catch (UnsupportedOperationException e) {
                message = new SendMessage(update.message().chat().id(), MarkdownProcessor.process(UNSUPPORTED_COMMAND));
            }
            if (message != null) {
                message.parseMode(ParseMode.MarkdownV2);
                BaseResponse response = telegramBot.execute(message);
                if (!response.isOk()) {
                    log.error(ERROR + response.description());
                }
            }
        });
        return UpdatesListener.CONFIRMED_UPDATES_ALL;
    }

    @Override
    public void close() {
        telegramBot.removeGetUpdatesListener();
    }

    public void processUpdate(long chatId, String description) {
        SendMessage message = new SendMessage(chatId, MarkdownProcessor.process(description));
        message.parseMode(ParseMode.MarkdownV2);
        BaseResponse response = telegramBot.execute(message);
        if (!response.isOk()) {
            log.error(ERROR + response.description());
        }
    }

    private void setCommands() {
        List<BotCommand> botCommands = new ArrayList<>();
        for (Command c : UserMessageProcessor.commands()) {
            botCommands.add(c.toApiCommand());
        }
        SetMyCommands setMyCommands = new SetMyCommands(botCommands.toArray(new BotCommand[0]));
        telegramBot.execute(setMyCommands);
    }
}
