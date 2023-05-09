package com.github.nad777.bot.client.requests;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class AddTaskRequest {
    @JsonProperty("task_name") String taskName;
    @JsonProperty("amount_test") Integer amountTest;
    @JsonProperty("memory_limit") Integer memoryLimit;
    @JsonProperty("time_limit") Float timeLimit;
    @JsonProperty("task_filename") String taskFilename;
    @JsonProperty("task_file") byte[] taskFile;
    @JsonProperty("master_filename") String masterFilename;
    @JsonProperty("master_file") byte[] masterFile;
}
