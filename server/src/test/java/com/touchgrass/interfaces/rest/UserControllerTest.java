package com.touchgrass.interfaces.rest;

import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.security.test.context.support.WithMockUser;

import java.time.LocalDate;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    private User user;
    private User admin;

    private User createUser(String username, String email, boolean isAdmin) {
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword("password"); // In real app, this would be encoded
        user.setAdmin(isAdmin);
        return userRepository.save(user);
    }

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();

        user = createUser("user", "user@example.com", false);
        admin = createUser("admin", "admin@example.com", true);
    }

    @Test
    @WithMockUser(username = "user")
    void getCurrentUser_ShouldReturnUserDetails() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value("user"))
                .andExpect(jsonPath("$.data.email").value("user@example.com"))
                .andExpect(jsonPath("$.data.admin").value(false));
    }

    @Test
    @WithMockUser(username = "admin")
    void getCurrentUser_ShouldReturnAdminDetails() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value("admin"))
                .andExpect(jsonPath("$.data.email").value("admin@example.com"))
                .andExpect(jsonPath("$.data.admin").value(true));
    }

    @Test
    void getCurrentUser_ShouldReturnUnauthorizedWhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/users/me"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(username = "user")
    void getUserById_ShouldReturnUser() throws Exception {
        mockMvc.perform(get("/api/users/" + user.getId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value("user"))
                .andExpect(jsonPath("$.data.email").value("user@example.com"))
                .andExpect(jsonPath("$.data.admin").value(false));
    }

    @Test
    @WithMockUser(username = "user")
    void getUserById_ShouldReturnNotFoundForNonExistentUser() throws Exception {
        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isNotFound());
    }

    @Test
    void getUserById_ShouldReturnUnauthorizedWhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/users/" + user.getId()))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(username = "user")
    void deleteUser_ShouldDeleteUser() throws Exception {
        // Try to delete own account
        mockMvc.perform(delete("/api/users/" + user.getId()))
                .andExpect(status().isOk());

        // Verify user is deleted
        mockMvc.perform(get("/api/users/" + user.getId()))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(username = "user")
    void deleteUser_ShouldNotDeleteOtherUser() throws Exception {
        // Try to delete admin's account
        mockMvc.perform(delete("/api/users/" + admin.getId()))
                .andExpect(status().isForbidden());

        // Verify admin still exists
        mockMvc.perform(get("/api/users/" + admin.getId()))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(username = "admin", roles = "ADMIN")
    void deleteUser_AdminCanDeleteAnyUser() throws Exception {
        // Admin deletes regular user
        mockMvc.perform(delete("/api/users/" + user.getId()))
                .andExpect(status().isOk());

        // Verify user is deleted
        mockMvc.perform(get("/api/users/" + user.getId()))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(username = "user")
    void updateUser_ShouldUpdateUser() throws Exception {
        String updateJson = """
                {
                    "firstName": "Updated",
                    "lastName": "User",
                    "dateOfBirth": "1990-01-01"
                }
                """;

        mockMvc.perform(put("/api/users/" + user.getId())
                .contentType("application/json")
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.firstName").value("Updated"))
                .andExpect(jsonPath("$.data.lastName").value("User"))
                .andExpect(jsonPath("$.data.dateOfBirth").value("1990-01-01"));
    }

    @Test
    @WithMockUser(username = "user")
    void updateUser_ShouldNotUpdateOtherUser() throws Exception {
        String updateJson = """
                {
                    "firstName": "Updated",
                    "lastName": "User",
                    "dateOfBirth": "1990-01-01"
                }
                """;

        mockMvc.perform(put("/api/users/" + admin.getId())
                .contentType("application/json")
                .content(updateJson))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(username = "admin", roles = "ADMIN")
    void updateUser_AdminCanUpdateAnyUser() throws Exception {
        String updateJson = """
                {
                    "firstName": "Updated",
                    "lastName": "User",
                    "dateOfBirth": "1990-01-01"
                }
                """;

        mockMvc.perform(put("/api/users/" + user.getId())
                .contentType("application/json")
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.firstName").value("Updated"))
                .andExpect(jsonPath("$.data.lastName").value("User"))
                .andExpect(jsonPath("$.data.dateOfBirth").value("1990-01-01"));
    }

    @Test
    void updateUser_ShouldReturnUnauthorizedWhenNotAuthenticated() throws Exception {
        String updateJson = """
                {
                    "firstName": "Updated",
                    "lastName": "User",
                    "dateOfBirth": "1990-01-01"
                }
                """;

        mockMvc.perform(put("/api/users/" + user.getId())
                .contentType("application/json")
                .content(updateJson))
                .andExpect(status().isUnauthorized());
    }
}