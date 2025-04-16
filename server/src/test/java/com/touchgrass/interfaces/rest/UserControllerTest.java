package com.touchgrass.interfaces.rest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.time.LocalDate;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;

import jakarta.persistence.EntityManager;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
@Transactional
class UserControllerTest {

    private static final Logger log = LoggerFactory.getLogger(UserControllerTest.class);

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EntityManager entityManager;

    private User testUser;
    private User adminUser;
    private String userToken;
    private String adminToken;

    @BeforeEach
    void setUp() {
        // Create test user
        testUser = User.builder()
                .username("testuser")
                .email("test@example.com")
                .password(passwordEncoder.encode("password"))
                .firstName("Test")
                .lastName("User")
                .dateOfBirth(LocalDate.of(1990, 1, 1))
                .isAdmin(false)
                .build();
        testUser = userRepository.save(testUser);

        // Create admin user
        adminUser = User.builder()
                .username("admin")
                .email("admin@example.com")
                .password(passwordEncoder.encode("password"))
                .firstName("Admin")
                .lastName("User")
                .dateOfBirth(LocalDate.of(1990, 1, 1))
                .isAdmin(true)
                .build();
        adminUser = userRepository.save(adminUser);

        // Generate JWT token for the test user
        Authentication userAuthentication = new UsernamePasswordAuthenticationToken(
                testUser,
                null,
                testUser.getAuthorities());
        userToken = jwtTokenProvider.generateToken(userAuthentication);

        // Generate JWT token for the admin user
        Authentication adminAuthentication = new UsernamePasswordAuthenticationToken(
                adminUser,
                null,
                adminUser.getAuthorities());
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
        @Transactional(propagation = Propagation.NOT_SUPPORTED)
        @DisplayName("DELETE /api/users/me - Should delete current user")
        void deleteCurrentUser_ShouldDeleteUser() throws Exception {
            assertTrue(userRepository.findById(testUser.getId()).isPresent());

            mockMvc.perform(delete("/api/users/me")
                    .header("Authorization", "Bearer " + userToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));

            assertFalse(userRepository.findById(testUser.getId()).isPresent());
        }

        @Test
        @DisplayName("DELETE /api/users/me - Should return 401 when not authenticated")
        void deleteUser_ShouldReturnUnauthorized() throws Exception {
            mockMvc.perform(delete("/api/users/me"))
                    .andExpect(status().isUnauthorized());
        }

        @Test
        @Transactional(propagation = Propagation.NOT_SUPPORTED)
        @DisplayName("PATCH /api/users/me - Should update user details when authenticated")
        void updateUser_ShouldUpdateUserDetails() throws Exception {
            String json = "{\"first_name\": \"UpdatedFirstName\", \"last_name\": \"UpdatedLastName\"}";

            mockMvc.perform(patch("/api/users/me")
                    .header("Authorization", "Bearer " + userToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(json))
                    .andExpect(status().isOk());

            User userInNewTransaction = userRepository.findByUsername(testUser.getUsername()).orElseThrow();
            assertEquals("UpdatedFirstName", userInNewTransaction.getFirstName());
            assertEquals("UpdatedLastName", userInNewTransaction.getLastName());
        }

        @Test
        @DisplayName("PATCH /api/users/me - Should return 401 when not authenticated")
        void updateUser_ShouldReturnUnauthorized() throws Exception {
            String json = "{'first_name': 'TestFirstName', 'last_name': 'TestLastName'}";

            mockMvc.perform(patch("/api/users/me")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(json))
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
        @Transactional(propagation = Propagation.NOT_SUPPORTED)
        @DisplayName("DELETE /api/users/{id} - Should delete user when authenticated as admin")
        void deleteUserById_ShouldDeleteUser() throws Exception {
            assertTrue(userRepository.findById(testUser.getId()).isPresent());

            mockMvc.perform(delete("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + adminToken))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.success").value(true));

            assertFalse(userRepository.findById(testUser.getId()).isPresent());
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
        @Transactional(propagation = Propagation.NOT_SUPPORTED)
        @DisplayName("PATCH /api/users/{id} - Should update user when authenticated as admin")
        void updateUserById_ShouldUpdateUser() throws Exception {
            String json = "{\"first_name\": \"UpdatedFirstName\", \"last_name\": \"UpdatedLastName\"}";

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + adminToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(json))
                    .andExpect(status().isOk());

            User userInNewTransaction = userRepository.findByUsername(testUser.getUsername()).orElseThrow();
            assertEquals("UpdatedFirstName", userInNewTransaction.getFirstName());
            assertEquals("UpdatedLastName", userInNewTransaction.getLastName());
        }

        @Test
        @DisplayName("PATCH /api/users/{id} - Should return 403 when authenticated as non-admin")
        void updateUserById_ShouldReturnForbidden() throws Exception {
            String json = "{\"first_name\": \"UpdatedFirstName\", \"last_name\": \"UpdatedLastName\"}";

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .header("Authorization", "Bearer " + userToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(json))
                    .andExpect(status().isForbidden());
        }

        @Test
        @DisplayName("PATCH /api/users/{id} - Should return 401 when not authenticated")
        void updateUserById_ShouldReturnUnauthorized() throws Exception {
            String json = "{\"first_name\": \"UpdatedFirstName\", \"last_name\": \"UpdatedLastName\"}";

            mockMvc.perform(patch("/api/users/" + testUser.getId())
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(json))
                    .andExpect(status().isUnauthorized());
        }
    }
}