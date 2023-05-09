package com.github.nad777.bot.client;

import com.github.nad777.bot.client.requests.AddTaskRequest;
import com.github.nad777.bot.client.requests.SubmitTaskRequest;
import com.github.nad777.bot.client.responses.AddTaskResponse;
import com.github.nad777.bot.client.responses.ListTasksResponse;
import com.github.nad777.bot.client.responses.SubmitTaskResponse;
import com.github.nad777.bot.client.responses.TaskFileResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.reactive.function.client.WebClientResponseException;

@Component
@RequiredArgsConstructor
public class JugglerClient {
    private final WebClient jugglerWebClient;
    private final static String PATH_SEGMENT = "chat";
    private final static String QUERY_PARAM = "chat_id";

    public void registerChat(long chatId) {
        jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment(PATH_SEGMENT)
                        .queryParam(QUERY_PARAM, chatId)
                        .build())
                .retrieve()
                .bodyToMono(Void.class)
                .block();
    }

    public void deleteChat(long chatId) {
        jugglerWebClient.delete()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment(PATH_SEGMENT)
                        .queryParam(QUERY_PARAM, chatId)
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
            return new TaskFileResponse(null, null, null, null);
        }
    }

    public SubmitTaskResponse submitTask(long id, SubmitTaskRequest request) {
        return jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("submit")
                        .queryParam(QUERY_PARAM, id)
                        .build())
                .bodyValue(request)
                .retrieve()
                .bodyToMono(SubmitTaskResponse.class)
                .block();
    }

    public AddTaskResponse addTask(long chatId, AddTaskRequest request) {
        return jugglerWebClient.post()
                .uri(uriBuilder -> uriBuilder
                        .pathSegment("add_task")
                        .queryParam(QUERY_PARAM, chatId)
                        .build())
                .bodyValue(request)
                .retrieve()
                .bodyToMono(AddTaskResponse.class)
                .block();
    }
}
