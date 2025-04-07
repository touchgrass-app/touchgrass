package com.touchgrass.infrastructure.filters;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class RequestLoggingFilter extends OncePerRequestFilter {
    private final Logger logger = LoggerFactory.getLogger(RequestLoggingFilter.class);

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        logger.debug("=== REQUEST INFO ===");
        logger.debug("URI: " + request.getRequestURI());
        logger.debug("Method: " + request.getMethod());
        logger.debug("Headers: ");
        Collections.list(request.getHeaderNames()).forEach(header -> 
            logger.debug(header + ": " + request.getHeader(header))
        );
        
        filterChain.doFilter(request, response);
        
        logger.debug("=== RESPONSE INFO ===");
        logger.debug("Status: " + response.getStatus());
    }
} 