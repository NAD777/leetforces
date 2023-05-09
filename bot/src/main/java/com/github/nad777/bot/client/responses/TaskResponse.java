package com.github.nad777.bot.client.responses;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TaskResponse(@JsonProperty("task_id") long taskId, @JsonProperty("task_name") String taskName) {
}
