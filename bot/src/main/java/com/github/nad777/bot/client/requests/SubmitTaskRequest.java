package com.github.nad777.bot.client.requests;

public record SubmitTaskRequest(String fileName, String taskId, byte[] file) {
}
