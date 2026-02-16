package com.bloomberg.fxdeals.controller;

import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/deals")
public class DealController {
    @GetMapping("/ping")
    public String ping() {
        return "FX Deals API is running!";
    }
}
