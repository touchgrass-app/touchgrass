package com.touchgrass.application.auth.service;

import com.touchgrass.application.auth.command.LoginCommand;
import com.touchgrass.application.auth.command.RegisterCommand;
import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.dto.RegisterRequest;
import org.springframework.stereotype.Service;

@Service
public class AuthService {
    private final LoginCommand loginCommand;
    private final RegisterCommand registerCommand;

    public AuthService(LoginCommand loginCommand, RegisterCommand registerCommand) {
        this.loginCommand = loginCommand;
        this.registerCommand = registerCommand;
    }

    public AuthResponse login(AuthRequest request) {
        return loginCommand.execute(request);
    }

    public AuthResponse register(RegisterRequest request) {
        return registerCommand.execute(request);
    }
}
