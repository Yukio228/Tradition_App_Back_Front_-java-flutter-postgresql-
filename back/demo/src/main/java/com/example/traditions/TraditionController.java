package com.example.traditions;

import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/traditions")
@CrossOrigin
public class TraditionController {

    private final TraditionRepository repo;

    public TraditionController(TraditionRepository repo) {
        this.repo = repo;
    }

    @GetMapping
    public List<Tradition> getAll() {
        return repo.findAll(
                Sort.by(Sort.Direction.ASC, "title")
        );
    }

    @GetMapping("/new")
    public List<Tradition> getNew() {
        return repo.findAll(
                Sort.by(Sort.Direction.DESC, "createdAt")
        );
    }

    @PostMapping
    public Tradition add(@RequestBody Tradition t) {
        return repo.save(t);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        repo.deleteById(id);
    }

    @PutMapping("/{id}")
    public Tradition update(
            @PathVariable Long id,
            @RequestBody Tradition updated
    ) {
        return repo.findById(id).map(t -> {
            t.setTitle(updated.getTitle());
            t.setDescription(updated.getDescription());
            t.setMeaning(updated.getMeaning());
            t.setCategory(updated.getCategory());
            t.setImageUrl(updated.getImageUrl());
            t.setYoutubeUrl(updated.getYoutubeUrl());
            return repo.save(t);
        }).orElseThrow(() ->
                new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Традиция не найдена"
                )
        );
    }
}
