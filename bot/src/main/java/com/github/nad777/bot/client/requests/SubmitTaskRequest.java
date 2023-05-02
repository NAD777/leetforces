package com.github.nad777.bot.client.requests;

public record SubmitTaskRequest(String name, String task_no, byte[] source_file) {
}
