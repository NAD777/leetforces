package com.github.nad777.bot.core.commands;

import com.pengrad.telegrambot.model.BotCommand;
import com.pengrad.telegrambot.model.Update;
import com.pengrad.telegrambot.request.SendMessage;
import org.jetbrains.annotations.NotNull;

public interface Command {
    String command();
    String description();
    SendMessage handle(Update update);
    default boolean supports(@NotNull Update update) {
        return update.message().text().equals(command());
    }
    default BotCommand toApiCommand() {
        return new BotCommand(command(), description());
    }
}
