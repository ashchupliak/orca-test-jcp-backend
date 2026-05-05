package com.jetbrains.jcp.backend

import com.jetbrains.jcp.backend.controller.HealthController
import com.jetbrains.jcp.backend.controller.RootController
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get

@WebMvcTest(controllers = [HealthController::class, RootController::class])
class CapabilityProbeTest {

    @Autowired
    private lateinit var mockMvc: MockMvc

    @Test
    fun `GET root returns service info`() {
        mockMvc.get("/")
            .andExpect {
                status { isOk() }
                content { contentTypeCompatibleWith(MediaType.APPLICATION_JSON) }
                jsonPath("$.service") { value("jcp-backend-service") }
                jsonPath("$.status") { value("running") }
                jsonPath("$.endpoints") { isArray() }
            }
    }

    @Test
    fun `GET api health returns UP status`() {
        mockMvc.get("/api/health")
            .andExpect {
                status { isOk() }
                content { contentTypeCompatibleWith(MediaType.APPLICATION_JSON) }
                jsonPath("$.status") { value("UP") }
                jsonPath("$.service") { value("jcp-backend-service") }
                jsonPath("$.timestamp") { exists() }
                jsonPath("$.version") { exists() }
            }
    }

    @Test
    fun `GET api ping returns pong`() {
        mockMvc.get("/api/ping")
            .andExpect {
                status { isOk() }
                content { contentTypeCompatibleWith(MediaType.APPLICATION_JSON) }
                jsonPath("$.message") { value("pong") }
            }
    }
}
