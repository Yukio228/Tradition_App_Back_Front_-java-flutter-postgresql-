package com.example.traditions;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "traditions")
public class Tradition {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String description;

    @Column(columnDefinition = "TEXT")
    private String meaning;

    private String category;

    @JsonProperty("imageUrl")
    @Column(name = "image_url")
    private String imageUrl;

    @JsonProperty("youtubeUrl")
    @Column(name = "youtube_url")
    private String youtubeUrl;

    @JsonProperty("createdAt")
    @Column(name = "created_at", updatable = false, insertable = false)
    private LocalDateTime createdAt;

    // ===== GETTERS =====
    public Long getId() { return id; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public String getMeaning() { return meaning; }
    public String getCategory() { return category; }
    public String getImageUrl() { return imageUrl; }
    public String getYoutubeUrl() { return youtubeUrl; }
    public LocalDateTime getCreatedAt() { return createdAt; }

    // ===== SETTERS =====
    public void setId(Long id) { this.id = id; }
    public void setTitle(String title) { this.title = title; }
    public void setDescription(String description) { this.description = description; }
    public void setMeaning(String meaning) { this.meaning = meaning; }
    public void setCategory(String category) { this.category = category; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public void setYoutubeUrl(String youtubeUrl) { this.youtubeUrl = youtubeUrl; }
}
