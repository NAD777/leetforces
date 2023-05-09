package com.github.nad777.bot.client.responses;

import com.fasterxml.jackson.annotation.JsonProperty;

public record TaskFileResponse(@JsonProperty("task_name") String taskName, @JsonProperty("task_id") String taskId,
                               String filename, @JsonProperty("task_file") String taskFile) {
    @Override
    public String toString() {
        return "TaskFileResponse[taskName=" + taskName() + ", taskId=" + taskId() + ", filename=" + filename() + "]";
    }
}
