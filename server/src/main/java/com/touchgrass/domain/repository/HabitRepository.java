package com.touchgrass.domain.repository;

import com.touchgrass.domain.model.Habit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface HabitRepository {
    Habit save(Habit habit);
    Optional<Habit> findById(UUID id);
    List<Habit> findByUserId(UUID userId);
    void delete(UUID id);
} 