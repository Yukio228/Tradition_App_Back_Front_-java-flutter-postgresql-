package com.example.traditions;

import org.springframework.stereotype.Service;

@Service
public class UsernameService {

    private final UserRepository repo;

    public UsernameService(UserRepository repo) {
        this.repo = repo;
    }

    public boolean isValid(String username) {
        if (username == null) return false;
        return username.matches("^[a-zA-Z0-9_]{3,20}$");
    }

    public String generateUnique(String base) {
        String seed = base == null || base.isBlank() ? "user" : base;
        String candidate = seed;
        int i = 0;
        while (repo.existsByUsername(candidate)) {
            i++;
            candidate = seed + i;
        }
        return candidate;
    }
}

