package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.user.dto.UserResponse;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;

import jakarta.websocket.MessageHandler.Partial;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        try {
            User user = userRepository.findById(id)
                    .orElseThrow(() -> new AuthenticationException("User not found"));
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(e.getMessage(), "USER_NOT_FOUND"));
        }
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication authentication) {
        try {
            User user = userRepository.findByUsername(authentication.getName())
                    .orElseThrow(() -> new AuthenticationException("User not found"));
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND)
                    .body(ApiResponse.error(e.getMessage(), "USER_NOT_FOUND"));
        }
    }

    @PostMapping("/{id}")
    public User deleteUser(@RequestBody int id) {
        return null;
    }

    @PatchMapping("/{id}")
    public User updateUser(@RequestBody Partial<User> user) {
        return null;
    }

}
