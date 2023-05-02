package com.github.nad777.bot.client;

import com.github.nad777.bot.client.requests.SubmitTaskRequest;
import com.github.nad777.bot.client.responses.ListTasksResponse;
import com.github.nad777.bot.client.responses.SubmitTaskResponse;
import com.github.nad777.bot.client.responses.TaskFileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Component
@RequiredArgsConstructor
public class JugglerClient {
    private final WebClient jugglerWebClient;

    public void registerChat(long id) {
        jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("chat")
                        .queryParam("chat_id", id)
                        .build())
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }

    public void deleteChat(long id) {
        jugglerWebClient.delete()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("chat")
                        .queryParam("chat_id", id)
                        .build())
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }

    public ListTasksResponse getTasks() {
        try {
            return jugglerWebClient.get()
                    .uri("/list")
                    .retrieve()
                    .bodyToMono(ListTasksResponse.class)
                    .block();
        } catch (WebClientResponseException e) {
            if (e.getStatusCode() != HttpStatus.NOT_FOUND) {
                throw e;
            }
            return new ListTasksResponse(null);
        }
    }

    public TaskFileResponse getTaskById(String taskId) {
        try {
            return jugglerWebClient.get()
                    .uri(uriBuilder -> uriBuilder
                            .pathSegment("get_task")
                            .queryParam("task_id", taskId)
                            .build())
                    .retrieve()
                    .bodyToMono(TaskFileResponse.class)
                    .block();
        } catch (WebClientResponseException e) {
            if (e.getStatusCode() != HttpStatus.NOT_FOUND) {
                throw e;
            }
            return new TaskFileResponse(null, null, null);
        }
    }

    public SubmitTaskResponse submitTask(long id, SubmitTaskRequest request) {
        return jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("submit")
                        .queryParam("chat_id", id)
                        .build())
                .bodyValue(BodyInserters.fromValue(request))
                .retrieve()
                .bodyToMono(SubmitTaskResponse.class)
                .block();
    }
}
