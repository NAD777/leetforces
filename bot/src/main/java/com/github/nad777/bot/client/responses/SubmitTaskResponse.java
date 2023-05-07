package com.github.nad777.bot.client.responses;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

public record SubmitTaskResponse(String status, int code, @JsonProperty("submission_id") long submissionId) {
    @NotNull
    @Contract(pure = true)
    @Override
    public String toString() {
        return "SUBMISSION ID: ***" + submissionId + "***\nSTATUS CODE: ***" + code + "***\nSTATUS DESCRIPTION: ***" + status + "***";
    }
}
