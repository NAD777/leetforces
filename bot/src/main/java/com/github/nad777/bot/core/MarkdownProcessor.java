package com.github.nad777.bot.core;

import org.jetbrains.annotations.Contract;
import org.jetbrains.annotations.NotNull;

public class MarkdownProcessor {
    @NotNull
    @Contract(pure = true)
    public static String process(String s) {
        s = s.replaceAll("\\.", "\\\\.");
        s = s.replaceAll("!", "\\\\!");
        s = s.replaceAll("-", "\\\\-");
        s = s.replaceAll("\\{", "\\\\{");
        s = s.replaceAll("}", "\\\\}");
        s = s.replaceAll("_", "\\\\_");
        s = s.replaceAll("\\+", "\\\\+");
        System.out.println(s);
        return s;
    }
}
