package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.user.dto.UserResponse;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;

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

    private User findCurrentUser(Authentication authentication) {
        return userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new AuthenticationException("Current user not found"));
    }

    private User findUserById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new AuthenticationException("User not found"));
    }

    private void checkAdminOrSelfPermission(User targetUser, User currentUser) {
        if (!currentUser.isAdmin() && !targetUser.getUsername().equals(currentUser.getUsername())) {
            throw new AuthenticationException("You don't have permission to perform this action");
        }
    }

    private <T> ResponseEntity<ApiResponse<T>> handleUserNotFound(AuthenticationException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage(), "USER_NOT_FOUND"));
    }

    private <T> ResponseEntity<ApiResponse<T>> handlePermissionDenied(AuthenticationException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage(), "PERMISSION_DENIED"));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication authentication) {
        try {
            User user = findCurrentUser(authentication);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(@PathVariable Long id) {
        try {
            User user = findUserById(id);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable Long id, Authentication authentication) {
        try {
            User user = findUserById(id);
            User currentUser = findCurrentUser(authentication);
            checkAdminOrSelfPermission(user, currentUser);

            userRepository.deleteById(id);
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (AuthenticationException e) {
            if (e.getMessage().contains("permission")) {
                return handlePermissionDenied(e);
            }
            return handleUserNotFound(e);
        }
    }

    @PatchMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> updateUser(
            @PathVariable Long id,
            @RequestBody UserResponse userResponse,
            Authentication authentication) {
        try {
            User user = findUserById(id);
            User currentUser = findCurrentUser(authentication);
            checkAdminOrSelfPermission(user, currentUser);

            // Update user fields
            user.setFirstName(userResponse.firstName());
            user.setLastName(userResponse.lastName());
            user.setDateOfBirth(userResponse.dateOfBirth());

            // Save updated user
            User updatedUser = userRepository.save(user);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(updatedUser)));
        } catch (AuthenticationException e) {
            if (e.getMessage().contains("permission")) {
                return handlePermissionDenied(e);
            }
            return handleUserNotFound(e);
        }
    }
}
