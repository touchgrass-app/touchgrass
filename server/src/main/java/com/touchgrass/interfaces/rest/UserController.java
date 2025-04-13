package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.user.dto.UserResponse;
import com.touchgrass.application.user.exception.UserErrorCode;
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

    private void checkAdminPermission(User currentUser) {
        if (!currentUser.isAdmin()) {
            throw new AuthenticationException("You don't have permission to perform this action");
        }
    }

    private <T> ResponseEntity<ApiResponse<T>> handleUserNotFound(AuthenticationException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(ApiResponse.error(e.getMessage(), UserErrorCode.USER_NOT_FOUND.getCode()));
    }

    private <T> ResponseEntity<ApiResponse<T>> handlePermissionDenied(AuthenticationException e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error(e.getMessage(), UserErrorCode.PERMISSION_DENIED.getCode()));
    }

    // Current user endpoints (/me)
    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> getCurrentUser(Authentication authentication) {
        try {
            User user = findCurrentUser(authentication);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    @DeleteMapping("/me")
    public ResponseEntity<ApiResponse<Void>> deleteCurrentUser(Authentication authentication) {
        try {
            User currentUser = findCurrentUser(authentication);
            userRepository.deleteById(currentUser.getId());
            return ResponseEntity.ok(ApiResponse.success(null));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    @PatchMapping("/me")
    public ResponseEntity<ApiResponse<UserResponse>> updateCurrentUser(
            @RequestBody UserResponse userResponse,
            Authentication authentication) {
        try {
            User currentUser = findCurrentUser(authentication);

            // Update user fields
            currentUser.setFirstName(userResponse.firstName());
            currentUser.setLastName(userResponse.lastName());
            currentUser.setDateOfBirth(userResponse.dateOfBirth());

            // Save updated user
            User updatedUser = userRepository.save(currentUser);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(updatedUser)));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    // User ID-based endpoints
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUserById(
            @PathVariable Long id,
            Authentication authentication) {
        try {
            User user = findUserById(id);
            return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
        } catch (AuthenticationException e) {
            return handleUserNotFound(e);
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUserById(
            @PathVariable Long id,
            Authentication authentication) {
        try {
            User currentUser = findCurrentUser(authentication);
            checkAdminPermission(currentUser);

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
    public ResponseEntity<ApiResponse<UserResponse>> updateUserById(
            @PathVariable Long id,
            @RequestBody UserResponse userResponse,
            Authentication authentication) {
        try {
            User user = findUserById(id);
            User currentUser = findCurrentUser(authentication);
            checkAdminPermission(currentUser);

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
