package com.github.nad777.bot.controller;

import com.github.nad777.bot.controller.requests.ResultUpdateRequest;
import com.github.nad777.bot.core.Bot;
import lombok.RequiredArgsConstructor;
import org.jetbrains.annotations.NotNull;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class BotController {
    private final Bot bot;

    @PostMapping("/update")
    public void processUpdate(@NotNull @RequestBody ResultUpdateRequest request) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("SUBMISSION ID: ").append(request.submissionId());
        stringBuilder.append("\nSTATUS: ").append(request.status());
        if (request.test() != null && request.test() != -1) {
            stringBuilder.append("\nTEST FAILED: ").append(request.test());
            stringBuilder.append("\nTIME: ").append(request.time());
            stringBuilder.append("\nMEMORY: ").append(request.memory());
        }
        bot.processUpdate(request.chatId(), stringBuilder.toString());
    }
}