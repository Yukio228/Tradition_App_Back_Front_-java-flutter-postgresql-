package com.example.traditions;

import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin
public class AuthController {

    private final UserRepository repo;
    private final UsernameService usernameService;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public AuthController(UserRepository repo, UsernameService usernameService) {
        this.repo = repo;
        this.usernameService = usernameService;
    }

    @PostMapping("/register")
    public Map<String, String> register(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");
        String username = body.get("username");

        if (password == null || password.length() < 6) {
            return Map.of("error", "Пароль меньше 6 символов");
        }

        if (email == null || email.isBlank()) {
            return Map.of("error", "Email обязателен");
        }

        if (repo.findByEmail(email).isPresent()) {
            return Map.of("error", "Пользователь уже существует");
        }

        if (username != null && !username.isBlank()) {
            if (!usernameService.isValid(username)) {
                return Map.of("error", "Никнейм должен быть 3-20 символов и содержать только латиницу, цифры и _");
            }
            if (repo.existsByUsername(username)) {
                return Map.of("error", "Никнейм уже занят");
            }
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(encoder.encode(password));
        user.setRole("USER");
        user.setThemePreference("DARK");
        user.setUsername(
                username == null || username.isBlank()
                        ? usernameService.generateUnique("user")
                        : username
        );
        repo.save(user);

        return Map.of("status", "ok");
    }

    @PostMapping("/login")
    public Map<String, String> login(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        return repo.findByEmail(email)
                .filter(u -> encoder.matches(password, u.getPassword()))
                .map(u -> {
                    String role = u.getRole() == null ? "USER" : u.getRole();
                    return Map.of(
                            "status", "ok",
                            "role", role
                    );
                })
                .orElse(Map.of("error", "Неверный email или пароль"));
    }
}

