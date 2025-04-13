package com.touchgrass.application.auth.command;

import com.touchgrass.application.auth.dto.AuthRequest;
import com.touchgrass.application.auth.dto.AuthResponse;
import com.touchgrass.application.auth.exception.AuthenticationException;
import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
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
    private final UserRepository userRepository;

    public LoginCommand(AuthenticationManager authenticationManager,
                       JwtTokenProvider tokenProvider,
                       UserRepository userRepository) {
        this.authenticationManager = authenticationManager;
        this.tokenProvider = tokenProvider;
        this.userRepository = userRepository;
    }

    public AuthResponse execute(AuthRequest request) {
        try {
            // Try to find user by both username and email
            User userByUsername = userRepository.findByUsername(request.getUsername()).orElse(null);
            User userByEmail = userRepository.findByEmail(request.getUsername()).orElse(null);

            // If no user found by either method
            if (userByUsername == null && userByEmail == null) {
                throw new AuthenticationException("Invalid username or password");
            }

            // If both username and email matches found, ensure they're the same user
            if (userByUsername != null && userByEmail != null && !userByUsername.getId().equals(userByEmail.getId())) {
                throw new AuthenticationException("Invalid username or password");
            }

            // Use whichever user was found (they're either the same user or only one was found)
            User userToAuthenticate = userByUsername != null ? userByUsername : userByEmail;
            
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(userToAuthenticate.getUsername(), request.getPassword())
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);

            // Update last login timestamp
            userToAuthenticate.updateLastLogin();
            userRepository.save(userToAuthenticate);

            return new AuthResponse(jwt, userToAuthenticate.getUsername());
        } catch (org.springframework.security.core.AuthenticationException e) {
            throw new AuthenticationException("Invalid username or password");
        }
    }
}
