package com.jetbrains.jcp.backend.repository

import com.jetbrains.jcp.backend.entity.User
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface UserRepository : JpaRepository<User, Int>
