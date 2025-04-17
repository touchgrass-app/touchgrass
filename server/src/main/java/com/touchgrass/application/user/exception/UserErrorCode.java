package com.touchgrass.application.user.exception;

public enum UserErrorCode {
    USER_NOT_FOUND("USER_NOT_FOUND"),
    PERMISSION_DENIED("PERMISSION_DENIED");

    private final String code;

    UserErrorCode(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

    @Override
    public String toString() {
        return code;
    }
} 