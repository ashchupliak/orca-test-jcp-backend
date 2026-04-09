package com.jetbrains.jcp.backend.controller

import com.jetbrains.jcp.backend.entity.Session
import com.jetbrains.jcp.backend.repository.SessionRepository
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/sessions")
class SessionController(private val sessionRepository: SessionRepository) {

    data class CreateSessionRequest(val userId: Int)

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    fun create(@RequestBody request: CreateSessionRequest): Session {
        return sessionRepository.save(Session(userId = request.userId))
    }

    @GetMapping("/{id}")
    fun getById(@PathVariable id: Int): Session {
        return sessionRepository.findById(id).orElseThrow {
            NoSuchElementException("Session $id not found")
        }
    }
}
