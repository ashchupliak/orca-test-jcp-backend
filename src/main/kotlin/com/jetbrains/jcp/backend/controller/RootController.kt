package com.jetbrains.jcp.backend.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class RootController {

    @GetMapping("/")
    fun root(): Map<String, Any> {
        return mapOf(
            "service" to "jcp-backend-service",
            "status" to "running",
            "endpoints" to listOf(
                "/api/health",
                "/api/ping",
                "/actuator/health"
            )
        )
    }
}
