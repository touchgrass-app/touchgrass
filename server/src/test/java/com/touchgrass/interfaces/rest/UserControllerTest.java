package com.touchgrass.interfaces.rest;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;
import com.touchgrass.domain.user.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDate;
import java.util.Collections;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
public class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean(name = "userRepository")
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    private User testUser;
    private String jwtToken;

    @BeforeEach
    void setUp() {
        // Create a test user
        testUser = new User();
        testUser.setId(1L);
        testUser.setUsername("testuser");
        testUser.setEmail("test@example.com");
        testUser.setPassword("password");
        testUser.setFirstName("Test");
        testUser.setLastName("User");
        testUser.setDateOfBirth(LocalDate.of(1990, 1, 1));
        testUser.setAdmin(false);

        // Mock repository responses
        when(userRepository.findByUsername(any())).thenReturn(Optional.of(testUser));
        when(userRepository.save(any())).thenReturn(testUser);
        when(userRepository.findById(any())).thenReturn(Optional.of(testUser));

        // Generate JWT token
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                testUser,  // Use the User object as principal
                null,
                Collections.singletonList(new SimpleGrantedAuthority("ROLE_USER")));
        jwtToken = jwtTokenProvider.generateToken(authentication);
    }

    @Test
    @WithMockUser
    void getUserDetails_ShouldReturnUserDetails() throws Exception {
        mockMvc.perform(get("/api/users/me")
                .header("Authorization", "Bearer " + jwtToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.username").value(testUser.getUsername()))
                .andExpect(jsonPath("$.data.email").value(testUser.getEmail()));
    }

    @Test
    @WithMockUser
    void deleteUser_ShouldDeleteUser() throws Exception {
        mockMvc.perform(delete("/api/users/1")  // Use the user's ID
                .header("Authorization", "Bearer " + jwtToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true));
    }

    @Test
    @WithMockUser
    void updateUser_ShouldUpdateUserDetails() throws Exception {
        User updatedUser = new User();
        updatedUser.setFirstName("Updated");
        updatedUser.setLastName("Name");

        mockMvc.perform(patch("/api/users/1")  // Use PATCH instead of PUT
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedUser)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.firstName").value("Updated"))
                .andExpect(jsonPath("$.data.lastName").value("Name"));
    }
}