package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.dto.RegisterRequest;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.auth.service.AuthService;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // For development only
public class AuthController {
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);
    private final AuthService authService;
    private final UserRepository userRepository;

    public AuthController(AuthService authService, UserRepository userRepository) {
        this.authService = authService;
        this.userRepository = userRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(e.getMessage(), "INVALID_CREDENTIALS"));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@RequestBody RegisterRequest request) {
        try {
            logger.info("Received registration request for username: {}", request.getUsername());
            logger.debug("Full registration request: {}", request);
            AuthResponse response = authService.register(request);
            logger.info("Successfully registered user: {}", request.getUsername());
            return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
        } catch (AuthenticationException e) {
            logger.warn("Registration failed for username: {} - {}", request.getUsername(), e.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage(), "AUTHENTICATION_ERROR"));
        } catch (Exception e) {
            logger.error("Unexpected error during registration for username: {}", request.getUsername(), e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("An unexpected error occurred during registration: " + e.getMessage(), "INTERNAL_ERROR"));
        }
    }
    
    @PostMapping("/register2")
    public ResponseEntity<String> register2(@RequestBody(required = false) String requestBody) {
        return ResponseEntity.ok("Auth register endpoint reached with body: " + (requestBody != null ? requestBody : "null"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(Authentication authentication) {
        try {
            logger.info("Getting current user data for: {}", authentication.getName());
            User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new AuthenticationException("User not found"));
            logger.info("Successfully retrieved user data for: {}", authentication.getName());
            return ResponseEntity.ok(ApiResponse.success(user));
        } catch (AuthenticationException e) {
            logger.warn("Failed to get current user: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage(), "USER_NOT_FOUND"));
        } catch (Exception e) {
            logger.error("Unexpected error getting current user", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("An unexpected error occurred: " + e.getMessage(), "INTERNAL_ERROR"));
        }
    }
} 