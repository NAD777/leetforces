package com.github.nad777.bot.client;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
@RequiredArgsConstructor
public class JugglerClient {
    private final WebClient jugglerWebClient;

    public void registerChat(long id) {
        jugglerWebClient.post()
                .uri("/chat/{id}", id)
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }

    public void deleteChat(long id) {
        jugglerWebClient.delete()
                .uri("/chat/{id}", id)
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }
}
