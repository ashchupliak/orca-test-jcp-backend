package com.jetbrains.jcp.backend.repository

import com.jetbrains.jcp.backend.entity.Session
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface SessionRepository : JpaRepository<Session, Int>
