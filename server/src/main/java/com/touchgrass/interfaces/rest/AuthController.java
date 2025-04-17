package com.touchgrass.interfaces.rest;

import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.dto.RegisterRequest;
import com.touchgrass.application.auth.exception.AuthErrorCode;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.application.auth.service.AuthService;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@RequestBody AuthRequest request) {
        try {
            AuthResponse response = authService.login(request);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (AuthenticationException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage(), AuthErrorCode.AUTHENTICATION_ERROR.getCode()));
        }
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@RequestBody RegisterRequest request) {
        try {
            AuthResponse response = authService.register(request);
            return ResponseEntity.ok(ApiResponse.success(response));
        } catch (AuthenticationException e) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage(), AuthErrorCode.REGISTRATION_ERROR.getCode()));
        }
    }
}