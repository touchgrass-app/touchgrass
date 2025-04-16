package com.touchgrass.application.user.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.core.util.StringUtils;
import com.touchgrass.domain.user.model.User;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Map;

@Service
public class UserService {
    private final ObjectMapper objectMapper;

    public UserService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public void updateUserFromJson(User user, String json) {
        try {
            Map<String, String> updates = objectMapper.readValue(json, new TypeReference<Map<String, String>>() {});
            
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