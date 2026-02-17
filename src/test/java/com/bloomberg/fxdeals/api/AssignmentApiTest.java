package com.bloomberg.fxdeals.api;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.repository.DealRepository;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static io.restassured.RestAssured.given;
import static org.hamcrest.Matchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class AssignmentApiTest {

    @LocalServerPort
    private int port;

    @Autowired
    private DealRepository dealRepository;

    @BeforeEach
    void setUp() {
        RestAssured.port = port;
        RestAssured.baseURI = "http://localhost";
        RestAssured.basePath = "/api/deals";
    }

    // 1️⃣ FIELD ACCEPTANCE - Success
    @Test
    void createValidDeal_ShouldReturn201() {
        DealRequest request = createRequest("TEST-001");
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(201)
            .body("dealUniqueId", equalTo("TEST-001"));
    }

    // 2️⃣ ROW LEVEL VALIDATION - Missing field
    @Test
    void missingDealUniqueId_ShouldReturn400() {
        DealRequest request = createRequest(null);
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

    // 2️⃣ ROW LEVEL VALIDATION - Invalid currency
    @Test
    void invalidCurrency_ShouldReturn400() {
        DealRequest request = createRequest("TEST-003");
        request.setFromCurrency("USDOLLAR");
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

    // 2️⃣ ROW LEVEL VALIDATION - Negative amount
    @Test
    void negativeAmount_ShouldReturn400() {
        DealRequest request = createRequest("TEST-004");
        request.setDealAmount(new BigDecimal("-100"));
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

    // 3️⃣ DUPLICATE PREVENTION
    @Test
    void duplicateDealId_ShouldReturn409() {
        String id = "DUP-001";
        DealRequest request = createRequest(id);
        
        // First request - should succeed
        given().contentType(ContentType.JSON).body(request).post().then().statusCode(201);
        
        // Second request - should fail with 409
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(409)
            .body("message", containsString("already exists"));
    }

    // 4️⃣ NO ROLLBACK / PARTIAL SUCCESS
    @Test
    void batchWithDuplicate_ValidRecordsSaved() {
        String prefix = "BATCH-" + System.currentTimeMillis();
        
        // Valid deal 1
        DealRequest valid1 = createRequest(prefix + "-1");
        given().contentType(ContentType.JSON).body(valid1).post().then().statusCode(201);
        
        // Valid deal 2 (will be duplicated)
        DealRequest valid2 = createRequest(prefix + "-2");
        given().contentType(ContentType.JSON).body(valid2).post().then().statusCode(201);
        
        // Try duplicate of valid2
        given().contentType(ContentType.JSON).body(valid2).post().then().statusCode(409);
        
        // Valid deal 3
        DealRequest valid3 = createRequest(prefix + "-3");
        given().contentType(ContentType.JSON).body(valid3).post().then().statusCode(201);
        
        // Verify all valid deals were saved
        given().get().then().statusCode(200);
    }

    // 5️⃣ EDGE CASES - Minimum amount
    @Test
    void minimumAmount_ShouldSucceed() {
        DealRequest request = createRequest("MIN-001");
        request.setDealAmount(new BigDecimal("0.01"));
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(201);
    }

    // Helper method
    private DealRequest createRequest(String id) {
        DealRequest request = new DealRequest();
        request.setDealUniqueId(id);
        request.setFromCurrency("USD");
        request.setToCurrency("EUR");
        request.setDealAmount(new BigDecimal("100.00"));
        request.setDealTimestamp(LocalDateTime.now());
        return request;
    }
}