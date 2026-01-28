package com.example.traditions;

import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class UsernameBackfillRunner implements ApplicationRunner {

    private final UserRepository repo;
    private final UsernameService usernameService;

    public UsernameBackfillRunner(UserRepository repo, UsernameService usernameService) {
        this.repo = repo;
        this.usernameService = usernameService;
    }

    @Override
    public void run(ApplicationArguments args) {
        List<User> users = repo.findAll();
        for (User user : users) {
            String current = user.getUsername();
            if (current == null || current.isBlank()) {
                user.setUsername(usernameService.generateUnique("user"));
                repo.save(user);
            }
        }
    }
}
