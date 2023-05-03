package com.github.nad777.bot.controller.requests;

public record ResultUpdateRequest(Long chat_id, String status, Integer test_num, Integer run_time, Integer memory_used,
                                  Long submit_id) {
}
