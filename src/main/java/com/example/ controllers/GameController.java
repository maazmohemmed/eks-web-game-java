package com.example.controllers;

import com.example.models.Game;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/api/games")
public class GameController {

    private final Map<Long, Game> store = Collections.synchronizedMap(new LinkedHashMap<>());
    private final AtomicLong idSeq = new AtomicLong(1L);

    public GameController() {
        // sample data
        Game g1 = new Game(idSeq.getAndIncrement(), "Space Invaders", "Arcade", 1);
        Game g2 = new Game(idSeq.getAndIncrement(), "Battle Royale", "Shooter", 100);
        store.put(g1.getId(), g1);
        store.put(g2.getId(), g2);
    }

    @GetMapping
    public ResponseEntity<List<Game>> list() {
        return ResponseEntity.ok(new ArrayList<>(store.values()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Game> get(@PathVariable("id") Long id) {
        Game g = store.get(id);
        if (g == null) return ResponseEntity.notFound().build();
        return ResponseEntity.ok(g);
    }

    @PostMapping
    public ResponseEntity<Game> create(@Valid @RequestBody Game game) {
        Long id = idSeq.getAndIncrement();
        game.setId(id);
        store.put(id, game);
        return ResponseEntity.status(HttpStatus.CREATED).body(game);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Game> update(@PathVariable("id") Long id, @Valid @RequestBody Game game) {
        if (!store.containsKey(id)) return ResponseEntity.notFound().build();
        game.setId(id);
        store.put(id, game);
        return ResponseEntity.ok(game);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable("id") Long id) {
        if (store.remove(id) == null) return ResponseEntity.notFound().build();
        return ResponseEntity.noContent().build();
    }
}
