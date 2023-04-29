package com.github.nad777.bot.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.MediaType;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class ClientConfiguration {
    @Value("${juggler-base-url}")
    private String jugglerBaseUrl;

    @Bean
    public WebClient jugglerWebClient() {
        return WebClient.builder()
                .baseUrl(jugglerBaseUrl)
                .defaultHeader("Content-Type", MediaType.APPLICATION_JSON_VALUE)
                .build();
    }
}
