package com.touchgrass.server.user;

import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class UserService {

    private final UserRepository userRepository;

    @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public User loginUser(String usernameOrEmail, String password) {
        // Try to find existing user
        Optional<User> existingUser = userRepository.findByUsernameOrEmail(usernameOrEmail);
        
        if (existingUser.isPresent()) {
            User user = existingUser.get();
            // Update password if different
            if (!user.getPassword().equals(password)) {
                user.setPassword(password);
            }
            // Update last login
            user.setLastLogin(LocalDateTime.now());
            return userRepository.save(user);
        } else {
            // Create new user
            User newUser = new User();
            // If input looks like email, set it as email and generate username
            if (usernameOrEmail.contains("@")) {
                newUser.setEmail(usernameOrEmail);
                newUser.setUsername(usernameOrEmail.split("@")[0]);
            } else {
                newUser.setUsername(usernameOrEmail);
                newUser.setEmail(usernameOrEmail + "@touchgrass.com"); // Temporary email
            }
            newUser.setPassword(password);
            newUser.setLastLogin(LocalDateTime.now());
            return userRepository.save(newUser);
        }
    }

    public User getUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("User not found with id: " + id));
    }

    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    public Optional<User> getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }

    @Transactional
    public User registerUser(String username, String email, String password) {
        if (userRepository.existsByUsername(username)) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email already exists");
        }
        
        User user = new User(username, email, password);
        return userRepository.save(user);
    }

    @Transactional
    public User createUser(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email already exists");
        }
        return userRepository.save(user);
    }

    @Transactional
    public User updateUser(Long id, User userDetails) {
        User user = getUserById(id);
        
        if (userDetails.getUsername() != null && !userDetails.getUsername().equals(user.getUsername())) {
            if (userRepository.existsByUsername(userDetails.getUsername())) {
                throw new IllegalArgumentException("Username already exists");
            }
            user.setUsername(userDetails.getUsername());
        }
        
        if (userDetails.getEmail() != null && !userDetails.getEmail().equals(user.getEmail())) {
            if (userRepository.existsByEmail(userDetails.getEmail())) {
                throw new IllegalArgumentException("Email already exists");
            }
            user.setEmail(userDetails.getEmail());
        }

        if (userDetails.getFirstName() != null) {
            user.setFirstName(userDetails.getFirstName());
        }
        if (userDetails.getLastName() != null) {
            user.setLastName(userDetails.getLastName());
        }
        
        return userRepository.save(user);
    }

    @Transactional
    public void deleteUser(Long id) {
        if (!userRepository.existsById(id)) {
            throw new EntityNotFoundException("User not found with id: " + id);
        }
        userRepository.deleteById(id);
    }

    @Transactional
    public void updateLastLogin(Long userId) {
        userRepository.updateLastLogin(userId);
    }
} 