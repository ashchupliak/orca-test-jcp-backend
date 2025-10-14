package com.jetbrains.jcp.backend.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.Instant

@RestController
@RequestMapping("/api")
class HealthController {

    @GetMapping("/health")
    fun health(): Map<String, Any> {
        return mapOf(
            "status" to "UP",
            "timestamp" to Instant.now().toString(),
            "service" to "jcp-backend-service",
            "version" to "1.0.0-SNAPSHOT"
        )
    }

    @GetMapping("/ping")
    fun ping(): Map<String, String> {
        return mapOf("message" to "pong")
    }
}
