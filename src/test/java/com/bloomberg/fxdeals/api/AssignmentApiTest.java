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
        // Clean database before each test
        dealRepository.deleteAll();
    }

    // 1️⃣ FIELD ACCEPTANCE - Success (FIXED: dynamic ID)
    @Test
    void createValidDeal_ShouldReturn201() {
        String uniqueId = "TEST-001-" + System.currentTimeMillis();  // ← FIXED
        DealRequest request = createRequest(uniqueId);
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(201)
            .body("dealUniqueId", equalTo(uniqueId));
    }

    
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

   
    @Test
    void invalidCurrency_ShouldReturn400() {
        String uniqueId = "TEST-003-" + System.currentTimeMillis();  // ← FIXED
        DealRequest request = createRequest(uniqueId);
        request.setFromCurrency("USDOLLAR");
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

    
    @Test
    void negativeAmount_ShouldReturn400() {
        String uniqueId = "TEST-004-" + System.currentTimeMillis();  // ← FIXED
        DealRequest request = createRequest(uniqueId);
        request.setDealAmount(new BigDecimal("-100"));
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(400);
    }

   
    @Test
    void duplicateDealId_ShouldReturn409() {
        String id = "DUP-001-" + System.currentTimeMillis();  
        DealRequest request = createRequest(id);
        
       
        given().contentType(ContentType.JSON).body(request).post().then().statusCode(201);
        
      
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(409)
            .body("message", containsString("already exists"));
    }

   
    @Test
    void batchWithDuplicate_ValidRecordsSaved() {
        String prefix = "BATCH-" + System.currentTimeMillis();
        
       
        DealRequest valid1 = createRequest(prefix + "-1");
        given().contentType(ContentType.JSON).body(valid1).post().then().statusCode(201);
        
       
        DealRequest valid2 = createRequest(prefix + "-2");
        given().contentType(ContentType.JSON).body(valid2).post().then().statusCode(201);
        
       
        given().contentType(ContentType.JSON).body(valid2).post().then().statusCode(409);
        
        
        DealRequest valid3 = createRequest(prefix + "-3");
        given().contentType(ContentType.JSON).body(valid3).post().then().statusCode(201);
        
       
        given().get().then().statusCode(200);
    }

    /
    @Test
    void minimumAmount_ShouldSucceed() {
        String uniqueId = "MIN-001-" + System.currentTimeMillis();  // ← FIXED
        DealRequest request = createRequest(uniqueId);
        request.setDealAmount(new BigDecimal("0.01"));
        
        given()
            .contentType(ContentType.JSON)
            .body(request)
        .when()
            .post()
        .then()
            .statusCode(201);
    }

    
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