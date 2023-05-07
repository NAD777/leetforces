package com.github.nad777.bot.client.responses;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

public record SubmitTaskResponse(String status, int code, long submission_id) {
    @NotNull
    @Contract(pure = true)
    @Override
    public String toString() {
        return "SUBMISSION ID: ***" + submission_id + "***\nSTATUS CODE: ***" + code + "***\nSTATUS DESCRIPTION: ***" + status + "***";
    }
}
