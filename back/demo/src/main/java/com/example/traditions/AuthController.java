package com.example.traditions;

import org.springframework.web.bind.annotation.*;
import org.springframework.security.crypto.bcrypt   .BCryptPasswordEncoder;

import java.util.Map;

@RestController
@RequestMapping("/auth")
@CrossOrigin
public class AuthController {

    private final UserRepository repo;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public AuthController(UserRepository repo) {
        this.repo = repo;
    }

    @PostMapping("/register")
    public Map<String, String> register(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        if (password.length() < 6) {
            return Map.of("error", "Пароль меньше 6 символов");
        }

        if (repo.findByEmail(email).isPresent()) {
            return Map.of("error", "Пользователь уже существует");
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(encoder.encode(password));
        repo.save(user);

        return Map.of("status", "ok");
    }

    @PostMapping("/login")
    public Map<String, String> login(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        return repo.findByEmail(email)
                .filter(u -> encoder.matches(password, u.getPassword()))
                .map(u -> Map.of(
                        "status", "ok",
                        "role", u.getRole()   // ✅ ВОТ ОН, КЛЮЧЕВОЙ ФИКС
                ))
                .orElse(Map.of("error", "Неверный email или пароль"));
    }
}
