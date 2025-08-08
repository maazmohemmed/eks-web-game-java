package com.example.controllers;

import org.springframework.web.bind.annotation.*;

@RestController
public class GameController {
    @GetMapping("/hello")
    public String hello() {
        return "Welcome to the Java Game Web App!";
    }
}
