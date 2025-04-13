package com.touchgrass.domain.user.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.core.GrantedAuthority;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {
    private User user;

    @BeforeEach
    void setUp() {
        user = User.builder()
            .username("testuser")
            .email("test@example.com")
            .password("password")
            .firstName("Test")
            .lastName("User")
            .dateOfBirth(LocalDate.of(1990, 1, 1))
            .isAdmin(false)
            .build();
    }

    @Test
    void testBuilder() {
        assertNotNull(user);
        assertEquals("testuser", user.getUsername());
        assertEquals("test@example.com", user.getEmail());
        assertEquals("password", user.getPassword());
        assertEquals("Test", user.getFirstName());
        assertEquals("User", user.getLastName());
        assertEquals(LocalDate.of(1990, 1, 1), user.getDateOfBirth());
        assertFalse(user.isAdmin());
    }

    @Test
    void testSetters() {
        user.setUsername("newuser");
        user.setEmail("new@example.com");
        user.setPassword("newpassword");
        user.setFirstName("New");
        user.setLastName("Name");
        user.setDateOfBirth(LocalDate.of(1995, 1, 1));
        user.setAdmin(true);
        user.setAvatarUrl("http://example.com/avatar.jpg");

        assertEquals("newuser", user.getUsername());
        assertEquals("new@example.com", user.getEmail());
        assertEquals("newpassword", user.getPassword());
        assertEquals("New", user.getFirstName());
        assertEquals("Name", user.getLastName());
        assertEquals(LocalDate.of(1995, 1, 1), user.getDateOfBirth());
        assertTrue(user.isAdmin());
        assertEquals("http://example.com/avatar.jpg", user.getAvatarUrl());
    }

    @Test
    void testUserDetailsMethods() {
        assertTrue(user.isAccountNonExpired());
        assertTrue(user.isAccountNonLocked());
        assertTrue(user.isCredentialsNonExpired());
        assertTrue(user.isEnabled());

        Collection<? extends GrantedAuthority> authorities = user.getAuthorities();
        assertEquals(1, authorities.size());
        assertEquals("ROLE_USER", authorities.iterator().next().getAuthority());

        user.setAdmin(true);
        authorities = user.getAuthorities();
        assertEquals("ROLE_ADMIN", authorities.iterator().next().getAuthority());
    }

    @Test
    void testUpdateLastLogin() {
        assertNull(user.getLastLogin());
        
        user.updateLastLogin();
        
        assertNotNull(user.getLastLogin());
        assertNotNull(user.getUpdatedAt());
        assertEquals(user.getLastLogin(), user.getUpdatedAt());
    }

    @Test
    void testUpdateProfile() {
        String newFirstName = "New";
        String newLastName = "Name";
        LocalDate newDateOfBirth = LocalDate.of(1995, 1, 1);
        String newAvatarUrl = "http://example.com/avatar.jpg";
        
        // First set an initial updatedAt
        user.setUpdatedAt(LocalDateTime.now());
        LocalDateTime beforeUpdate = user.getUpdatedAt();

        user.updateProfile(newFirstName, newLastName, newDateOfBirth, newAvatarUrl);

        assertEquals(newFirstName, user.getFirstName());
        assertEquals(newLastName, user.getLastName());
        assertEquals(newDateOfBirth, user.getDateOfBirth());
        assertEquals(newAvatarUrl, user.getAvatarUrl());
        assertTrue(user.getUpdatedAt().isAfter(beforeUpdate));
    }
} 