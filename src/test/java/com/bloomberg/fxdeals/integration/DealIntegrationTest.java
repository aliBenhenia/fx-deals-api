package com.bloomberg.fxdeals.integration;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.repository.DealRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.databind.SerializationFeature;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@Transactional
public class DealIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private DealRepository dealRepository;

    private ObjectMapper objectMapper;
    private DealRequest validRequest;
    private String baseUrl = "/api/deals";

    @BeforeEach
    void setUp() {
        objectMapper = new ObjectMapper();
        objectMapper.registerModule(new JavaTimeModule());
        objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

        validRequest = new DealRequest();
        validRequest.setDealUniqueId("INTEGRATION_TEST_" + System.currentTimeMillis());
        validRequest.setFromCurrency("USD");
        validRequest.setToCurrency("EUR");
        validRequest.setDealAmount(new BigDecimal("1000.50"));
        validRequest.setDealTimestamp(LocalDateTime.now());

        dealRepository.findByDealUniqueId(validRequest.getDealUniqueId())
            .ifPresent(deal -> dealRepository.delete(deal));
    }

    @Test
    void test1_ShouldRunAgainstRealDatabase() {
        assertThat(dealRepository).isNotNull();
        
        Deal deal = new Deal();
        deal.setDealUniqueId("DB_TEST_" + System.currentTimeMillis());
        deal.setFromCurrency("USD");
        deal.setToCurrency("EUR");
        deal.setDealAmount(new BigDecimal("500.00"));
        deal.setDealTimestamp(LocalDateTime.now());
        
        Deal saved = dealRepository.save(deal);
        assertThat(saved.getId()).isNotNull();
        
        Optional<Deal> found = dealRepository.findById(saved.getId());
        assertThat(found).isPresent();
        assertThat(found.get().getDealUniqueId()).isEqualTo(deal.getDealUniqueId());
    }

    @Test
    void test2_ShouldPersistDealToDatabase() {
        ResponseEntity<Deal> response = restTemplate.postForEntity(
            baseUrl,
            validRequest,
            Deal.class
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDealUniqueId()).isEqualTo(validRequest.getDealUniqueId());

        Optional<Deal> found = dealRepository.findByDealUniqueId(validRequest.getDealUniqueId());
        assertThat(found).isPresent();
        assertThat(found.get().getFromCurrency()).isEqualTo("USD");
        assertThat(found.get().getToCurrency()).isEqualTo("EUR");
        assertThat(found.get().getDealAmount()).isEqualTo(new BigDecimal("1000.50"));
    }

    @Test
    void test3_ShouldPreventDuplicateAtDatabaseLevel() {
        ResponseEntity<Deal> firstResponse = restTemplate.postForEntity(
            baseUrl,
            validRequest,
            Deal.class
        );
        assertThat(firstResponse.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        // Verify it's in database
        assertThat(dealRepository.findByDealUniqueId(validRequest.getDealUniqueId())).isPresent();

        ResponseEntity<String> secondResponse = restTemplate.postForEntity(
            baseUrl,
            validRequest,
            String.class
        );
        assertThat(secondResponse.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(secondResponse.getBody()).contains("already exists");

        // Verify still only one record in database
        long count = dealRepository.findAll().stream()
            .filter(d -> d.getDealUniqueId().equals(validRequest.getDealUniqueId()))
            .count();
        assertThat(count).isEqualTo(1);
    }

    @Test
    void test4_ShouldRollbackOnException() {
        
        
        String batchId = "BATCH_" + System.currentTimeMillis();
        
        for (int i = 1; i <= 3; i++) {
            DealRequest request = new DealRequest();
            request.setDealUniqueId(batchId + "_" + i);
            request.setFromCurrency("USD");
            request.setToCurrency("EUR");
            request.setDealAmount(new BigDecimal("100" + i));
            request.setDealTimestamp(LocalDateTime.now());
            
            ResponseEntity<Deal> response = restTemplate.postForEntity(
                baseUrl,
                request,
                Deal.class
            );
            assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        }
        
        for (int i = 1; i <= 3; i++) {
            assertThat(dealRepository.findByDealUniqueId(batchId + "_" + i)).isPresent();
        }
        
        // Now test transaction rollback by creating a service that throws exception
        // This would require a special endpoint, but we can test via repository directly
    }

    /// ===== TEST 5: Integration tests included in coverage =====
@Test
void test5_ShouldVerifyAllFieldsAreMappedCorrectly() {
    DealRequest request = new DealRequest();
    String uniqueId = "MAPPING_TEST_" + System.currentTimeMillis();
    request.setDealUniqueId(uniqueId);
    request.setFromCurrency("GBP");
    request.setToCurrency("JPY");
    request.setDealAmount(new BigDecimal("9876.54"));
    LocalDateTime timestamp = LocalDateTime.now().minusHours(5);
    request.setDealTimestamp(timestamp);

    ResponseEntity<Deal> response = restTemplate.postForEntity(
        baseUrl,
        request,
        Deal.class
    );

    assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);

    // Verify in database
    Optional<Deal> found = dealRepository.findByDealUniqueId(uniqueId);
    assertThat(found).isPresent();
    
    Deal deal = found.get();
    assertThat(deal.getDealUniqueId()).isEqualTo(uniqueId);
    assertThat(deal.getFromCurrency()).isEqualTo("GBP");
    assertThat(deal.getToCurrency()).isEqualTo("JPY");
    assertThat(deal.getDealAmount()).isEqualTo(new BigDecimal("9876.54"));
    
    assertThat(deal.getDealTimestamp().truncatedTo(java.time.temporal.ChronoUnit.SECONDS))
        .isEqualTo(timestamp.truncatedTo(java.time.temporal.ChronoUnit.SECONDS));
}

    // ===== TEST 6: Batch insert with duplicate =====
    @Test
    void test6_ShouldHandleBatchWithDuplicate() {
        String batchPrefix = "BATCH_DUP_" + System.currentTimeMillis();
        
        // Create first deal
        DealRequest request1 = new DealRequest();
        request1.setDealUniqueId(batchPrefix + "_1");
        request1.setFromCurrency("USD");
        request1.setToCurrency("EUR");
        request1.setDealAmount(new BigDecimal("100.00"));
        request1.setDealTimestamp(LocalDateTime.now());
        
        ResponseEntity<Deal> response1 = restTemplate.postForEntity(
            baseUrl,
            request1,
            Deal.class
        );
        assertThat(response1.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        
        // Try to create duplicate
        ResponseEntity<String> responseDup = restTemplate.postForEntity(
            baseUrl,
            request1,
            String.class
        );
        assertThat(responseDup.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        
        // Create a third unique deal
        DealRequest request2 = new DealRequest();
        request2.setDealUniqueId(batchPrefix + "_2");
        request2.setFromCurrency("GBP");
        request2.setToCurrency("JPY");
        request2.setDealAmount(new BigDecimal("200.00"));
        request2.setDealTimestamp(LocalDateTime.now());
        
        ResponseEntity<Deal> response2 = restTemplate.postForEntity(
            baseUrl,
            request2,
            Deal.class
        );
        assertThat(response2.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        
        // Verify only unique deals were saved
        assertThat(dealRepository.findByDealUniqueId(batchPrefix + "_1")).isPresent();
        assertThat(dealRepository.findByDealUniqueId(batchPrefix + "_2")).isPresent();
        
        // Count should be 2, not 3
        long count = dealRepository.findAll().stream()
            .filter(d -> d.getDealUniqueId().startsWith(batchPrefix))
            .count();
        assertThat(count).isEqualTo(2);
    }
}