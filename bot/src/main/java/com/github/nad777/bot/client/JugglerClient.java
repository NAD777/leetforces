package com.github.nad777.bot.client;

import com.github.nad777.bot.client.requests.SubmitTaskRequest;
import com.github.nad777.bot.client.responses.ListTasksResponse;
import com.github.nad777.bot.client.responses.SubmitTaskResponse;
import com.github.nad777.bot.client.responses.TaskFileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.BodyInserters;
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

    public ListTasksResponse getTasks() {
        return jugglerWebClient.get()
                .uri("/list")
                .retrieve()
                .bodyToMono(ListTasksResponse.class)
                .block();
    }

    public TaskFileResponse getTaskById(String taskId) {
        return jugglerWebClient.get()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("get-task")
                        .queryParam("task-id", taskId)
                        .build())
                .retrieve()
                .bodyToMono(TaskFileResponse.class)
                .block();
    }

    public SubmitTaskResponse submitTask(long id, SubmitTaskRequest request) {
        return jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("submit")
                        .queryParam("chat-id", id)
                        .build())
                .bodyValue(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(SubmitTaskResponse.class)
                .block();
    }
}
