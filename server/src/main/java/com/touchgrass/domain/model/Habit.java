package com.touchgrass.domain.model;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class Habit {
    private final UUID id;
    private String name;
    private String description;
    private final UUID userId;
    private final List<HabitCompletion> completions;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Habit(UUID id, String name, String description, UUID userId) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.userId = userId;
        this.completions = new ArrayList<>();
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    public void complete(LocalDateTime completedAt) {
        HabitCompletion completion = new HabitCompletion(UUID.randomUUID(), this.id, completedAt);
        completions.add(completion);
        this.updatedAt = LocalDateTime.now();
    }

    public int getCurrentStreak() {
        if (completions.isEmpty()) return 0;
        
        int streak = 0;
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime lastCompletion = completions.get(completions.size() - 1).getCompletedAt();
        
        // Simple streak calculation - can be enhanced based on habit frequency
        if (lastCompletion.toLocalDate().equals(now.toLocalDate())) {
            streak = 1;
        }
        
        return streak;
    }

    // Getters
    public UUID getId() { return id; }
    public String getName() { return name; }
    public String getDescription() { return description; }
    public UUID getUserId() { return userId; }
    public List<HabitCompletion> getCompletions() { return completions; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
} 