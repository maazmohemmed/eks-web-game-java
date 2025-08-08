package com.example.services;

import com.example.models.Game;
import org.springframework.stereotype.Service;

@Service
public class GameService {
    public Game startGame(String player) {
        return new Game(player, "STARTED");
    }
}
