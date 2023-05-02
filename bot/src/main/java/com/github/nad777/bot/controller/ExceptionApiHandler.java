package com.github.nad777.bot.controller;

import com.github.nad777.bot.controller.responses.ApiErrorResponse;
import org.jetbrains.annotations.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.Arrays;
import java.util.List;

@RestControllerAdvice
public class ExceptionApiHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiErrorResponse> handleException(@NotNull Exception e) {
        List<String> errors = List.of(Arrays.toString(e.getStackTrace()));
        ApiErrorResponse response = new ApiErrorResponse("Internal server error", "500", e.getClass().getSimpleName(), e.getMessage(), errors);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
    }
}
