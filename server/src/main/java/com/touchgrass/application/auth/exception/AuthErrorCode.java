package com.touchgrass.application.auth.exception;

public enum AuthErrorCode {
    AUTHENTICATION_ERROR("AUTHENTICATION_ERROR"),
    REGISTRATION_ERROR("REGISTRATION_ERROR");

    private final String code;

    AuthErrorCode(String code) {
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