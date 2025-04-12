package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.dto.RegisterRequest;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.auth.service.AuthService;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
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
            AuthResponse response = authService.register(request);
            return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(response));
        } catch (AuthenticationException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage(), "REGISTRATION_ERROR"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("An unexpected error occurred during registration: " + e.getMessage(), "INTERNAL_ERROR"));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<User>> getCurrentUser(Authentication authentication) {
        try {
            User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new AuthenticationException("User not found"));
            return ResponseEntity.ok(ApiResponse.success(user));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage(), "USER_NOT_FOUND"));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("An unexpected error occurred: " + e.getMessage(), "INTERNAL_ERROR"));
        }
    }
} 