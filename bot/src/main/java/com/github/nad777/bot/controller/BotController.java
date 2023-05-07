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
        stringBuilder.append("Results for submission ID: ***").append(request.submit_id()).append("***\n");
        stringBuilder.append("\nSTATUS: ***").append(request.status()).append("***");
        if (request.test_num() != -1) {
            stringBuilder.append("\nTEST FAILED: ***").append(request.test_num()).append("***");
        }
        if (request.run_time() != -1) {
            stringBuilder.append("\nTIME: ***").append(request.run_time()).append("***");
            stringBuilder.append("\nMEMORY: ***").append(request.memory_used()).append("***");
        }
        bot.processUpdate(request.chat_id(), stringBuilder.toString());
    }
}
