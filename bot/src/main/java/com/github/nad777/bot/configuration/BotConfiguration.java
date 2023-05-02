package com.github.nad777.bot.configuration;

import com.pengrad.telegrambot.TelegramBot;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@RequiredArgsConstructor
public class BotConfiguration {
    private final ApplicationConfig applicationConfig;

    @Bean
    public TelegramBot telegramBot() {
        String token = applicationConfig.botToken();
        return new TelegramBot(token);
    }
}
