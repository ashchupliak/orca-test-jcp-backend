package com.jetbrains.jcp.backend.controller

import com.jetbrains.jcp.backend.entity.User
import com.jetbrains.jcp.backend.repository.SessionRepository
import com.jetbrains.jcp.backend.repository.UserRepository
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.http.MediaType
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.*

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class SessionControllerTest {

    @Autowired lateinit var mockMvc: MockMvc
    @Autowired lateinit var userRepository: UserRepository
    @Autowired lateinit var sessionRepository: SessionRepository

    private lateinit var testUser: User

    @BeforeEach
    fun setup() {
        sessionRepository.deleteAll()
        userRepository.deleteAll()
        testUser = userRepository.save(User(username = "testuser", email = "test@example.com"))
    }

    @AfterEach
    fun teardown() {
        sessionRepository.deleteAll()
        userRepository.deleteAll()
    }

    @Test
    fun `POST api-sessions creates session and returns 201`() {
        mockMvc.perform(
            post("/api/sessions")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"userId": ${testUser.id}}""")
        )
            .andExpect(status().isCreated)
            .andExpect(jsonPath("$.id").isNumber)
            .andExpect(jsonPath("$.userId").value(testUser.id))
            .andExpect(jsonPath("$.token").isString)
            .andExpect(jsonPath("$.createdAt").isString)
            .andExpect(jsonPath("$.expiresAt").isString)
    }

    @Test
    fun `GET api-sessions-id returns created session`() {
        val createResult = mockMvc.perform(
            post("/api/sessions")
                .contentType(MediaType.APPLICATION_JSON)
                .content("""{"userId": ${testUser.id}}""")
        )
            .andExpect(status().isCreated)
            .andReturn()

        val responseBody = createResult.response.contentAsString
        val sessionId = com.fasterxml.jackson.databind.ObjectMapper()
            .readTree(responseBody)["id"].asInt()

        mockMvc.perform(get("/api/sessions/$sessionId"))
            .andExpect(status().isOk)
            .andExpect(jsonPath("$.id").value(sessionId))
            .andExpect(jsonPath("$.userId").value(testUser.id))
    }
}
