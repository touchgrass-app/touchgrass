package com.touchgrass.controller;

import com.touchgrass.model.LoginRequest;
import com.touchgrass.model.LoginResponse;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*") // For development only
public class LoginController {

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        // For MVP, we'll just return success for any login attempt
        return new LoginResponse("Login successful!", true);
    }
} 