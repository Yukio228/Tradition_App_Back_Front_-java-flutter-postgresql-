package com.example.traditions;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/profile")
@CrossOrigin
public class ProfileController {

    private static final long MAX_AVATAR_BYTES = 5 * 1024 * 1024;
    private static final List<String> ALLOWED_TYPES =
            List.of("image/jpeg", "image/png", "image/webp");

    private final UserRepository repo;
    private final UsernameService usernameService;

    @Value("${app.upload-dir:uploads/avatars}")
    private String uploadDir;

    public ProfileController(UserRepository repo, UsernameService usernameService) {
        this.repo = repo;
        this.usernameService = usernameService;
    }

    @GetMapping("/me")
    public Map<String, String> getProfile(@RequestHeader("X-User-Email") String email) {
        User user = repo.findByEmail(email).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found")
        );

        if (user.getUsername() == null || user.getUsername().isBlank()) {
            user.setUsername(usernameService.generateUnique("user"));
            repo.save(user);
        }

        String themePref = user.getThemePreference() == null
                ? "SYSTEM"
                : user.getThemePreference().toUpperCase();

        return Map.of(
                "email", user.getEmail(),
                "role", user.getRole() == null ? "USER" : user.getRole(),
                "username", user.getUsername(),
                "themePreference", themePref,
                "avatarUrl", user.getAvatarUrl() == null ? "" : user.getAvatarUrl()
        );
    }

    @PutMapping("/me")
    public Map<String, String> updateProfile(
            @RequestHeader("X-User-Email") String email,
            @RequestBody Map<String, String> body
    ) {
        User user = repo.findByEmail(email).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found")
        );

        String pref = body.get("themePreference");
        if (pref != null && !pref.isBlank()) {
            pref = pref.toUpperCase();
            if (!pref.equals("DARK") && !pref.equals("LIGHT") && !pref.equals("SYSTEM")) {
                throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid theme");
            }
            user.setThemePreference(pref);
        }

        String username = body.get("username");
        if (username != null) {
            username = username.trim();
            if (!usernameService.isValid(username)) {
                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Никнейм должен быть 3-20 символов и содержать только латиницу, цифры и _"
                );
            }
            boolean taken = repo.existsByUsername(username)
                    && (user.getUsername() == null || !user.getUsername().equals(username));
            if (taken) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Никнейм уже занят");
            }
            user.setUsername(username);
        }

        repo.save(user);
        return Map.of("status", "ok");
    }

    @PostMapping(
            value = "/me/avatar",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public Map<String, String> uploadAvatar(
            @RequestHeader("X-User-Email") String email,
            @RequestParam("file") MultipartFile file
    ) {
        User user = repo.findByEmail(email).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found")
        );

        if (file.isEmpty()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Empty file");
        }

        if (file.getSize() > MAX_AVATAR_BYTES) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "File too large");
        }

        String contentType = file.getContentType();
        String original = file.getOriginalFilename() == null ? "" : file.getOriginalFilename().toLowerCase();
        String ext = "";
        int dot = original.lastIndexOf('.');
        if (dot != -1) {
            ext = original.substring(dot + 1);
        }

        boolean allowed = contentType != null && ALLOWED_TYPES.contains(contentType);
        if (!allowed && !(ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || ext.equals("webp"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Unsupported file type");
        }

        String safeExt = ext.isEmpty() ? "jpg" : ext;
        String filename = UUID.randomUUID() + "." + safeExt;

        try {
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            Files.createDirectories(uploadPath);
            Path target = uploadPath.resolve(filename);
            file.transferTo(target.toFile());
        } catch (IOException e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Upload failed");
        }

        String url = "/uploads/avatars/" + filename;
        user.setAvatarUrl(url);
        repo.save(user);

        return Map.of("avatarUrl", url);
    }
}

