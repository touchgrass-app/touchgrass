package com.touchgrass.interfaces.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Collections;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    private User testUser;
    private User adminUser;
    private String userToken;
    private String adminToken;

    @BeforeEach
    void setUp() {
        // Create a test user in the database
        testUser = User.builder()
            .username("testuser")
            .password("password")
            .email("test@example.com")
            .firstName("Test")
            .lastName("User")
            .dateOfBirth(LocalDate.of(1990, 1, 1))
            .isAdmin(false)
            .build();
        testUser = userRepository.save(testUser);

        // Create an admin user
        adminUser = User.builder()
            .username("admin")
            .password("password")
            .email("admin@example.com")
            .firstName("Admin")
            .lastName("User")
            .dateOfBirth(LocalDate.of(1990, 1, 1))
            .isAdmin(true)
            .build();
        adminUser = userRepository.save(adminUser);

        // Generate JWT token for the test user
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
            testUser.getUsername(),
            testUser.getPassword(),
            Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER"))
        );
        Authentication userAuthentication = new UsernamePasswordAuthenticationToken(
            userDetails,
            null,
            userDetails.getAuthorities()
        );
        userToken = jwtTokenProvider.generateToken(userAuthentication);

        // Generate JWT token for the admin user
        UserDetails adminDetails = new org.springframework.security.core.userdetails.User(
            adminUser.getUsername(),
            adminUser.getPassword(),
            Collections.singletonList(new SimpleGrantedAuthority("ROLE_ADMIN"))
        );
        Authentication adminAuthentication = new UsernamePasswordAuthenticationToken(
            adminDetails,
            null,
            adminDetails.getAuthorities()
        );
        adminToken = jwtTokenProvider.generateToken(adminAuthentication);
    }

    @Nested
    @DisplayName("Current User Endpoints (/me)")
    class CurrentUserEndpoints {
        @Test
        @DisplayName("GET /api/users/me - Should return current user details when authenticated")
        void getUserDetails_ShouldReturnUserDetails() throws Exception {
            mockMvc.perform(get("/api/users/me")
                    .header("Authorization", "Bearer " + userToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.id").value(testUser.getId()));
        }

        @Test
        @DisplayName("GET /api/users/me - Should return 401 when not authenticated")
        void getUserDetails_ShouldReturnUnauthorized() throws Exception {
            mockMvc.perform(get("/api/users/me"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("DELETE /api/users/me - Should delete current user when authenticated")
        void deleteUser_ShouldDeleteUser() throws Exception {
            mockMvc.perform(delete("/api/users/me")
                    .header("Authorization", "Bearer " + userToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("DELETE /api/users/me - Should return 401 when not authenticated")
        void deleteUser_ShouldReturnUnauthorized() throws Exception {
            mockMvc.perform(delete("/api/users/me"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("PATCH /api/users/me - Should update current user details when authenticated")
        void updateUser_ShouldUpdateUserDetails() throws Exception {
            User updatedUser = User.builder()
                .firstName("Updated")
                .lastName("Name")
                .build();

            mockMvc.perform(patch("/api/users/me")
                    .header("Authorization", "Bearer " + userToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.firstName").value("Updated"))
                    .andExpect(jsonPath("$.data.lastName").value("Name"));
        }

        @Test
        @DisplayName("PATCH /api/users/me - Should return 401 when not authenticated")
        void updateUser_ShouldReturnUnauthorized() throws Exception {
            User updatedUser = User.builder()
                .firstName("Updated")
                .lastName("Name")
                .build();

            mockMvc.perform(patch("/api/users/me")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isUnauthorized());
        }
    }

    @Nested
    @DisplayName("User ID Endpoints")
    class UserIdEndpoints {
        @Test
        @DisplayName("GET /api/users/{id} - Should return user details when authenticated")
        void getUserById_ShouldReturnUserDetails() throws Exception {
            mockMvc.perform(get("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + userToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.id").value(testUser.getId()));
        }

        @Test
        @DisplayName("GET /api/users/{id} - Should return 401 when not authenticated")
        void getUserById_ShouldReturnUnauthorized() throws Exception {
            mockMvc.perform(get("/api/users/" + testUser.getId()))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("DELETE /api/users/{id} - Should delete user when authenticated as admin")
        void deleteUserById_ShouldDeleteUser() throws Exception {
            mockMvc.perform(delete("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + adminToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));
        }

        @Test
        @DisplayName("DELETE /api/users/{id} - Should return 403 when authenticated as non-admin")
        void deleteUserById_ShouldReturnForbidden() throws Exception {
            mockMvc.perform(delete("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + userToken))
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("DELETE /api/users/{id} - Should return 401 when not authenticated")
        void deleteUserById_ShouldReturnUnauthorized() throws Exception {
            mockMvc.perform(delete("/api/users/" + testUser.getId()))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @DisplayName("PATCH /api/users/{id} - Should update user details when authenticated as admin")
        void updateUserById_ShouldUpdateUserDetails() throws Exception {
            User updatedUser = User.builder()
                .firstName("Updated")
                .lastName("Name")
                .build();

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + adminToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.firstName").value("Updated"))
                    .andExpect(jsonPath("$.data.lastName").value("Name"));
        }

        @Test
        @DisplayName("PATCH /api/users/{id} - Should return 403 when authenticated as non-admin")
        void updateUserById_ShouldReturnForbidden() throws Exception {
            User updatedUser = User.builder()
                .firstName("Updated")
                .lastName("Name")
                .build();

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + userToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("PATCH /api/users/{id} - Should return 401 when not authenticated")
        void updateUserById_ShouldReturnUnauthorized() throws Exception {
            User updatedUser = User.builder()
                .firstName("Updated")
                .lastName("Name")
                .build();

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isUnauthorized());
        }
    }
}