package com.touchgrass.domain.service;

import com.touchgrass.domain.model.Habit;
import com.touchgrass.domain.repository.HabitRepository;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class HabitService {
    private final HabitRepository habitRepository;

    public HabitService(HabitRepository habitRepository) {
        this.habitRepository = habitRepository;
    }

    public Habit createHabit(String name, String description, UUID userId) {
        Habit habit = new Habit(UUID.randomUUID(), name, description, userId);
        return habitRepository.save(habit);
    }

    public void completeHabit(UUID habitId, LocalDateTime completedAt) {
        Habit habit = habitRepository.findById(habitId)
            .orElseThrow(() -> new RuntimeException("Habit not found"));
        
        habit.complete(completedAt);
        habitRepository.save(habit);
    }

    public List<Habit> getUserHabits(UUID userId) {
        return habitRepository.findByUserId(userId);
    }

    public void deleteHabit(UUID habitId) {
        habitRepository.delete(habitId);
    }
} 