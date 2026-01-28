package com.example.traditions;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "admin_logs")
public class AdminLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String adminEmail;

    private String action;

    private LocalDateTime createdAt;

    public AdminLog() {
        this.createdAt = LocalDateTime.now();
    }

    public AdminLog(String adminEmail, String action) {
        this.adminEmail = adminEmail;
        this.action = action;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getAdminEmail() {
        return adminEmail;
    }

    public String getAction() {
        return action;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
