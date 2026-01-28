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
    private String role; // ✅ ДОБАВИЛИ ROLE

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

    public String getRole() {       // ✅ ВАЖНО
        return role;
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

    public void setRole(String role) {   // ✅ ВАЖНО
        this.role = role;
    }
}
