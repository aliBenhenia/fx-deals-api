package com.bloomberg.fxdeals.aspect;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface Loggable {
    LogLevel value() default LogLevel.INFO;
    boolean logParams() default true;
    boolean logResult() default true;
}

enum LogLevel {
    INFO, DEBUG, WARN, ERROR
}