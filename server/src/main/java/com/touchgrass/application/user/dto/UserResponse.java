package com.touchgrass.application.user.dto;

import com.touchgrass.domain.user.model.User;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record UserResponse(
        Long id,
        String username,
        String email,
        String firstName,
        String lastName,
        LocalDate dateOfBirth,
        boolean isAdmin,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        LocalDateTime lastLogin,
        String avatarUrl) {
    public static UserResponse from(User user) {
        return new UserResponse(
                user.getId(),
                user.getUsername(),
                user.getEmail(),
                user.getFirstName(),
                user.getLastName(),
                user.getDateOfBirth(),
                user.isAdmin(),
                user.getCreatedAt(),
                user.getUpdatedAt(),
                user.getLastLogin(),
                user.getAvatarUrl());
    }
}