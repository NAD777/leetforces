package com.github.nad777.bot.client.requests;

public record SubmitTaskRequest(String file_name, String task_id, byte[] file) {
}
