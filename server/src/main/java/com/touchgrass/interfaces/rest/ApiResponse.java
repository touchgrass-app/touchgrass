package com.touchgrass.interfaces.rest;

public class ApiResponse<T> {
    private T data;
    private String message;
    private String error;
    private boolean success;

    private ApiResponse(T data, String message, String error, boolean success) {
        this.data = data;
        this.message = message;
        this.error = error;
        this.success = success;
    }

    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(data, null, null, true);
    }

    public static <T> ApiResponse<T> error(String message, String error) {
        return new ApiResponse<>(null, message, error, false);
    }

    public T getData() {
        return data;
    }

    public String getMessage() {
        return message;
    }

    public String getError() {
        return error;
    }

    public boolean isSuccess() {
        return success;
    }
} 