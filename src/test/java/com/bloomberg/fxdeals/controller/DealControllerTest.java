package com.bloomberg.fxdeals.controller;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.dto.DealResponse;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.service.DealService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.mockito.Mockito.doThrow;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DealController.class)
class DealControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private DealService dealService;

    private ObjectMapper objectMapper;
    private DealRequest validRequest;
    private Deal validDeal;
    private LocalDateTime now;

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
    
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
        
        now = LocalDateTime.now();
        
        validRequest = new DealRequest();
        validRequest.setDealUniqueId("TEST123");
        validRequest.setFromCurrency("USD");
        validRequest.setToCurrency("EUR");
        validRequest.setDealAmount(new BigDecimal("1000.50"));
        validRequest.setDealTimestamp(now);  // Use current time

        validDeal = new Deal();
        validDeal.setId(1L);
        validDeal.setDealUniqueId("TEST123");
        validDeal.setFromCurrency("USD");
        validDeal.setToCurrency("EUR");
        validDeal.setDealAmount(new BigDecimal("1000.50"));
        validDeal.setDealTimestamp(now);
    }

    @Test
    void createDeal_ShouldReturn201_WhenValidRequest() throws Exception {
        when(dealService.createDeal(any(DealRequest.class))).thenReturn(validDeal);

        String jsonRequest = objectMapper.writeValueAsString(validRequest);
        System.out.println("JSON Request: " + jsonRequest); // Debug: Should show timestamp as string

        mockMvc.perform(post("/api/deals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(jsonRequest))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.dealUniqueId").value("TEST123"))
                .andExpect(jsonPath("$.fromCurrency").value("USD"))
                .andExpect(jsonPath("$.toCurrency").value("EUR"))
                .andExpect(jsonPath("$.dealAmount").value(1000.50))
                .andExpect(jsonPath("$.dealTimestamp").exists());
    }

    @Test
    void createDeal_ShouldReturn400_WhenValidationFails() throws Exception {
        DealRequest invalidRequest = new DealRequest();
        invalidRequest.setFromCurrency("USD"); // Missing dealUniqueId

        mockMvc.perform(post("/api/deals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(invalidRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void createDeal_ShouldReturn500_WhenServiceThrowsException() throws Exception {
        when(dealService.createDeal(any(DealRequest.class)))
            .thenThrow(new RuntimeException("Database error"));

        mockMvc.perform(post("/api/deals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(validRequest)))
                .andExpect(status().isInternalServerError());
    }

    @Test
    void getAllDeals_ShouldReturn200_WithListOfDeals() throws Exception {
        List<Deal> deals = Arrays.asList(validDeal, validDeal);
        when(dealService.getAllDeals()).thenReturn(deals);

        mockMvc.perform(get("/api/deals"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].dealUniqueId").value("TEST123"));
    }

    @Test
    void getAllDeals_ShouldReturn200_WithEmptyList_WhenNoDeals() throws Exception {
        when(dealService.getAllDeals()).thenReturn(Arrays.asList());

        mockMvc.perform(get("/api/deals"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void convertToResponse_ShouldMapAllFields() throws Exception {
        when(dealService.createDeal(any(DealRequest.class))).thenReturn(validDeal);

        mockMvc.perform(post("/api/deals")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(validRequest)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.dealUniqueId").value(validDeal.getDealUniqueId()))
                .andExpect(jsonPath("$.fromCurrency").value(validDeal.getFromCurrency()))
                .andExpect(jsonPath("$.toCurrency").value(validDeal.getToCurrency()))
                .andExpect(jsonPath("$.dealAmount").value(validDeal.getDealAmount().doubleValue()))
                .andExpect(jsonPath("$.dealTimestamp").exists());
    }
}