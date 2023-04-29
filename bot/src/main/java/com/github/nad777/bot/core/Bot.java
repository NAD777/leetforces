package com.github.nad777.bot.core;

import com.pengrad.telegrambot.TelegramBot;
import com.pengrad.telegrambot.UpdatesListener;
import com.pengrad.telegrambot.model.Update;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class Bot implements AutoCloseable, UpdatesListener {
    private final TelegramBot telegramBot;

    @Override
    public int process(List<Update> updates) {
        return 0;
    }

    @Override
    public void close() {
        telegramBot.removeGetUpdatesListener();
    }
}
