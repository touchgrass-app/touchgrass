package com.touchgrass.interfaces.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.application.user.dto.UserResponse;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.model.UserRole;
import com.touchgrass.domain.user.repository.UserRepository;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.orm.jpa.EntityManagerFactoryUtils;
import jakarta.persistence.EntityManager;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

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
            testUser.getAuthorities()
        );
        userToken = jwtTokenProvider.generateToken(userAuthentication);

        // Generate JWT token for the admin user
        Authentication adminAuthentication = new UsernamePasswordAuthenticationToken(
            adminUser,
            null,
            adminUser.getAuthorities()
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
            // Verify initial state
            User beforeUser = userRepository.findById(testUser.getId()).orElseThrow();
            System.err.println("\nBefore update:");
            System.err.println("ID: " + beforeUser.getId());
            System.err.println("First Name: " + beforeUser.getFirstName());
            System.err.println("Last Name: " + beforeUser.getLastName());
            System.err.println("Username: " + beforeUser.getUsername());
            System.err.println("Email: " + beforeUser.getEmail());

            UserResponse updatedUser = new UserResponse(
                testUser.getId(),  // id
                testUser.getUsername(),  // username
                testUser.getEmail(),  // email
                "Updated",  // firstName
                "Name",     // lastName
                testUser.getDateOfBirth(),  // dateOfBirth
                testUser.isAdmin(),  // isAdmin
                testUser.getCreatedAt(),  // createdAt
                testUser.getUpdatedAt(),  // updatedAt
                testUser.getLastLogin(),  // lastLogin
                testUser.getAvatarUrl()  // avatarUrl
            );

            // Perform the update
            mockMvc.perform(patch("/api/users/me")
                    .header("Authorization", "Bearer " + userToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(updatedUser)))
                    .andExpect(status().isOk())
                    .andExpect(jsonPath("$.data.firstName").value("Updated"))
                    .andExpect(jsonPath("$.data.lastName").value("Name"));

            // Clear the Hibernate cache
            entityManager.clear();

            // Verify final state
            User afterUser = userRepository.findById(testUser.getId()).orElseThrow();
            System.err.println("\nAfter update (after cache clear):");
            System.err.println("ID: " + afterUser.getId());
            System.err.println("First Name: " + afterUser.getFirstName());
            System.err.println("Last Name: " + afterUser.getLastName());
            System.err.println("Username: " + afterUser.getUsername());
            System.err.println("Email: " + afterUser.getEmail());

            // These assertions should fail because we're not saving to the database
            assertEquals("Updated", afterUser.getFirstName(), "First name should not be updated in database");
            assertEquals("Name", afterUser.getLastName(), "Last name should not be updated in database");
        }

        @Test
        @DisplayName("PATCH /api/users/me - Should return 401 when not authenticated")
        void updateUser_ShouldReturnUnauthorized() throws Exception {
            UserResponse updatedUser = new UserResponse(
                testUser.getId(),  // id
                testUser.getUsername(),  // username
                testUser.getEmail(),  // email
                "Updated",  // firstName
                "Name",     // lastName
                testUser.getDateOfBirth(),  // dateOfBirth
                testUser.isAdmin(),  // isAdmin
                testUser.getCreatedAt(),  // createdAt
                testUser.getUpdatedAt(),  // updatedAt
                testUser.getLastLogin(),  // lastLogin
                testUser.getAvatarUrl()  // avatarUrl
            );

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