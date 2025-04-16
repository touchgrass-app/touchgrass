package com.touchgrass.application.user.dto;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.core.util.StringUtils;
import com.touchgrass.domain.user.model.User;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Map;

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

    public record UpdateUser(
        String firstName,
        String lastName,
        LocalDate dateOfBirth,
        String avatarUrl
    ) {}

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

    public static void updateUserFromJson(User user, String json) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, String> updates = mapper.readValue(json, new TypeReference<Map<String, String>>() {});
            
            for (Map.Entry<String, String> entry : updates.entrySet()) {
                String camelKey = StringUtils.snakeToCamel(entry.getKey());
                String value = entry.getValue();
                
                switch (camelKey) {
                    case "firstName" -> user.setFirstName(value);
                    case "lastName" -> user.setLastName(value);
                    case "dateOfBirth" -> user.setDateOfBirth(LocalDate.parse(value));
                    case "avatarUrl" -> user.setAvatarUrl(value);
                }
            }
        } catch (Exception e) {
            throw new RuntimeException("Failed to update user from JSON", e);
        }
    }
}