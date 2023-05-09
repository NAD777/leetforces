package com.github.nad777.bot.client.requests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record SubmitTaskRequest(String name, @JsonProperty("task_no") String taskNo,
                                @JsonProperty("source_file") byte[] sourceFile) {
}
