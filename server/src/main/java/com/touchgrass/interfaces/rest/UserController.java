package com.touchgrass.interfaces.rest;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.user.dto.UserResponse;
import com.touchgrass.application.user.exception.UserErrorCode;
import com.touchgrass.application.user.service.UserService;
import com.touchgrass.domain.exceptions.PermissionDeniedException;
import com.touchgrass.domain.exceptions.UserNotFoundException;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserRepository userRepository;
    private final UserService userService;

    public UserController(UserRepository userRepository, UserService userService) {
        this.userRepository = userRepository;
        this.userService = userService;
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

    @GetMapping("/me")
    public ApiResponse<UserResponse> getCurrentUser(Authentication authentication) {
        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new UsernameNotFoundException("User not found"));
        return ApiResponse.success(UserResponse.from(user));
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
            @RequestBody String json,
            Authentication authentication) {
        System.err.println("\nIn updateCurrentUser:");
        System.err.println("Request body: " + json);

        User currentUser = (User) authentication.getPrincipal();
        userService.updateUserFromJson(currentUser, json);
        userRepository.save(currentUser);
        return ResponseEntity.ok(ApiResponse.success(UserResponse.from(currentUser)));
    }

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
            @RequestBody String json,
            Authentication authentication) {
        User currentUser = (User) authentication.getPrincipal();
        if (!currentUser.isAdmin()) {
            throw new PermissionDeniedException("Only admin users can update other users");
        }

        User user = userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));

        userService.updateUserFromJson(user, json);
        userRepository.save(user);
        return ResponseEntity.ok(ApiResponse.success(UserResponse.from(user)));
    }
}
