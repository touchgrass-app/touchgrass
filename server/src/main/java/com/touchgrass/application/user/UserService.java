package com.touchgrass.application.user;

import com.touchgrass.application.user.dto.RegisterUserCommand;
import com.touchgrass.domain.user.User;
import com.touchgrass.domain.user.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {
    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public User registerUser(RegisterUserCommand command) {
        // Check if username or email already exists
        if (userRepository.existsByUsername(command.getUsername())) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(command.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }

        User user = new User();
        user.setUsername(command.getUsername());
        user.setEmail(command.getEmail());
        user.setPassword(command.getPassword()); // TODO: Hash password
        user.setFirstName(command.getFirstName());
        user.setLastName(command.getLastName());
        user.setDateOfBirth(command.getDateOfBirth());
        user.setAdmin(false);
        user.setCreatedAt(LocalDateTime.now());
        user.setUpdatedAt(LocalDateTime.now());

        return userRepository.save(user);
    }

    public Optional<User> getUserById(Long id) {
        return userRepository.findById(id);
    }

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public User updateUserProfile(Long id, String firstName, String lastName, LocalDate dateOfBirth) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        user.updateProfile(firstName, lastName, dateOfBirth);
        return userRepository.save(user);
    }

    @Transactional
    public void updateLastLogin(Long id) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

        user.updateLastLogin();
        userRepository.save(user);
    }

    @Transactional
    public User loginUser(String usernameOrEmail, String password) {
        Optional<User> user = userRepository.findByUsername(usernameOrEmail);
        if (user.isEmpty()) {
            user = userRepository.findByEmail(usernameOrEmail);
        }

        if (user.isEmpty()) {
            throw new IllegalArgumentException("User not found");
        }

        // TODO: Add proper password hashing
        if (!user.get().getPassword().equals(password)) {
            throw new IllegalArgumentException("Invalid password");
        }

        User authenticatedUser = user.get();
        authenticatedUser.updateLastLogin();
        return userRepository.save(authenticatedUser);
    }
} 