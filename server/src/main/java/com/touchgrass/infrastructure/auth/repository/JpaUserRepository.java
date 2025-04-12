package com.touchgrass.infrastructure.auth.repository;

import com.touchgrass.domain.user.model.User;
import com.touchgrass.domain.user.repository.UserRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface JpaUserRepository extends UserRepository, JpaRepository<User, Long> {
} 