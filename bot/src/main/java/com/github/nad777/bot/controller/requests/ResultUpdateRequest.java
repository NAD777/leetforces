package com.github.nad777.bot.controller.requests;

public record ResultUpdateRequest(long chatId, String status, Integer test, String time, String memory, long submissionId) {
}
