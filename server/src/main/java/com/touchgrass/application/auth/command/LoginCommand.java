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
            User userByUsername = userRepository.findByUsername(request.getUsername()).orElse(null);
            User userByEmail = userRepository.findByEmail(request.getUsername()).orElse(null);

            if (userByUsername == null && userByEmail == null) {
                throw new AuthenticationException("Invalid username or password");
            }

            if (userByUsername != null && userByEmail != null && !userByUsername.getId().equals(userByEmail.getId())) {
                throw new AuthenticationException("Invalid username or password");
            }

            User userToAuthenticate = userByUsername != null ? userByUsername : userByEmail;

            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(userToAuthenticate.getUsername(), request.getPassword()));

            SecurityContextHolder.getContext().setAuthentication(authentication);
            String jwt = tokenProvider.generateToken(authentication);

            userToAuthenticate.updateLastLogin();
            userRepository.save(userToAuthenticate);

            return new AuthResponse(jwt, userToAuthenticate.getUsername());
        } catch (org.springframework.security.core.AuthenticationException e) {
            throw new AuthenticationException("Invalid username or password");
        }
    }
}
