package com.touchgrass.domain.model;

import java.time.LocalDateTime;
import java.util.UUID;

public class HabitCompletion {
    private final UUID id;
    private final UUID habitId;
    private final LocalDateTime completedAt;

    public HabitCompletion(UUID id, UUID habitId, LocalDateTime completedAt) {
        this.id = id;
        this.habitId = habitId;
        this.completedAt = completedAt;
    }

    public UUID getId() { return id; }
    public UUID getHabitId() { return habitId; }
    public LocalDateTime getCompletedAt() { return completedAt; }
} 