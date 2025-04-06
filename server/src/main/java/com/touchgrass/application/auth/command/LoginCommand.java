package com.touchgrass.application.auth.command;

import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.infrastructure.auth.JwtTokenProvider;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Component
public class LoginCommand {
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;

    public LoginCommand(AuthenticationManager authenticationManager, 
                       JwtTokenProvider tokenProvider) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
    }

    public AuthResponse execute(AuthRequest request) {
        try {
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);

            return new AuthResponse(jwt, request.getUsername());
        } catch (Exception e) {
            throw new AuthenticationException("The username or password you entered is incorrect. Please try again.");
        }
    }
}
