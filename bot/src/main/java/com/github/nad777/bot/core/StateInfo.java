package com.github.nad777.bot.core;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;

@Data
@AllArgsConstructor
@RequiredArgsConstructor
public class StateInfo {
    private final Long chatId;
    private State state;
    private String taskId;
}
