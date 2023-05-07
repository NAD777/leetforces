package com.github.nad777.bot.controller.requests;

import com.fasterxml.jackson.annotation.JsonProperty;

public record ResultUpdateRequest(@JsonProperty("chat_id") Long chatId, String status,
                                  @JsonProperty("test_num") Integer testNum, @JsonProperty("run_time") Integer runTime,
                                  @JsonProperty("memory_used") Integer memoryUsed,
                                  @JsonProperty("submit_id") Long submitId) {
}
