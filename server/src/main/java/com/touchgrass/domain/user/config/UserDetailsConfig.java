package com.touchgrass.domain.user.config;

import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.Optional;

@Configuration
public class UserDetailsConfig {
    
    @Bean
    public UserDetailsService userDetailsService(UserRepository userRepository) {
        return username -> {
            Optional<User> user = userRepository.findByUsername(username);
            if (user.isEmpty()) {
                throw new UsernameNotFoundException("User not found");
            }
            return user.get();
        };
    }
} 