package com.example.traditions;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TraditionRepository extends JpaRepository<Tradition, Long> {
}
