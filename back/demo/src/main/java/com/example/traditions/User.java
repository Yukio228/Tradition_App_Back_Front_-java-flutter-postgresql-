package com.example.traditions;

import jakarta.persistence.*;

@Entity
@Table(name = "users")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true)
    private String email;

    private String password;

    @Column(length = 20)
    private String role;

    @Column(length = 20, unique = true)
    private String username;

    @Column(length = 10)
    private String themePreference; // DARK / LIGHT / SYSTEM

    @Column(length = 255)
    private String avatarUrl;

    // -------- GETTERS --------

    public Long getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getRole() {
        return role;
    }

    public String getUsername() {
        return username;
    }

    public String getThemePreference() {
        return themePreference;
    }

    public String getAvatarUrl() {
        return avatarUrl;
    }

    // -------- SETTERS --------

    public void setId(Long id) {
        this.id = id;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setThemePreference(String themePreference) {
        this.themePreference = themePreference;
    }

    public void setAvatarUrl(String avatarUrl) {
        this.avatarUrl = avatarUrl;
    }
}

