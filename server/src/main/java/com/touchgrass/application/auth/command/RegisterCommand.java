package com.touchgrass.application.auth.command;

import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.dto.RegisterRequest;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

@Component
public class RegisterCommand {
    private static final Logger logger = LoggerFactory.getLogger(RegisterCommand.class);
    
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    public RegisterCommand(UserRepository userRepository,
                         PasswordEncoder passwordEncoder,
                         AuthenticationManager authenticationManager,
                         JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
    }

    public AuthResponse execute(RegisterRequest request) {
        logger.info("Starting registration process for username: {}", request.getUsername());
        
        try {
            // Check if username or email already exists
            if (userRepository.existsByUsername(request.getUsername())) {
                logger.warn("Username already exists: {}", request.getUsername());
                throw new AuthenticationException("This username is already taken. Please choose a different one.");
            }
            if (userRepository.existsByEmail(request.getEmail())) {
                logger.warn("Email already exists: {}", request.getEmail());
                throw new AuthenticationException("This email is already registered. Please use a different email or try logging in.");
            }

            logger.debug("Creating new user with username: {}", request.getUsername());
            
            // Create new user
            User user = new User();
            user.setUsername(request.getUsername());
            user.setEmail(request.getEmail());
            user.setPassword(passwordEncoder.encode(request.getPassword()));
            user.setFirstName(request.getFirstName());
            user.setLastName(request.getLastName());
            user.setDateOfBirth(request.getDateOfBirth());
            user.setAdmin(false);
            user.setCreatedAt(LocalDateTime.now());
            user.setUpdatedAt(LocalDateTime.now());

            // Save user
            logger.debug("Saving user to database");
            userRepository.save(user);
            logger.info("User saved successfully: {}", user.getUsername());

            // Authenticate the user and generate token
            logger.debug("Authenticating user and generating token");
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);
            logger.info("Registration completed successfully for user: {}", user.getUsername());

            return new AuthResponse(jwt, user.getUsername());
        } catch (Exception e) {
            logger.error("Error during registration process", e);
            throw e;
        }
    }
}
