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
    private final static String STARS = "***";

    @PostMapping("/update")
    public void processUpdate(@NotNull @RequestBody ResultUpdateRequest request) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append("Results for submission ID: ***").append(request.submitId()).append("***\n");
        stringBuilder.append("\nTASK NAME: ***").append(request.taskName()).append(STARS);
        stringBuilder.append("\nSTATUS: ***").append(request.status()).append(STARS);
        if (request.testNum() != -1) {
            stringBuilder.append("\nTEST FAILED: ***").append(request.testNum()).append(STARS);
        }
        if (request.runTime() != -1) {
            stringBuilder.append("\nTIME: ***").append(request.runTime()).append(" ms").append(STARS);
            stringBuilder.append("\nMEMORY: ***").append(request.memoryUsed()).append(" MB").append(STARS);
        }
        bot.processUpdate(request.chatId(), stringBuilder.toString());
    }
}
