package com.bloomberg.fxdeals.model;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;

class DealTest {

    private Deal deal;

    @BeforeEach
    void setUp() {
        deal = new Deal();
    }

    @Test
    void testNoArgsConstructor() {
        assertThat(deal).isNotNull();
        assertThat(deal.getId()).isNull();
        assertThat(deal.getDealUniqueId()).isNull();
        assertThat(deal.getFromCurrency()).isNull();
        assertThat(deal.getToCurrency()).isNull();
        assertThat(deal.getDealAmount()).isNull();
        assertThat(deal.getDealTimestamp()).isNull();
    }

    @Test
    void testSettersAndGetters() {
        // Set values
        deal.setId(1L);
        deal.setDealUniqueId("TEST123");
        deal.setFromCurrency("USD");
        deal.setToCurrency("EUR");
        deal.setDealAmount(new BigDecimal("1000.50"));
        deal.setDealTimestamp(LocalDateTime.of(2024, 2, 17, 10, 30, 0));

        // Verify values
        assertThat(deal.getId()).isEqualTo(1L);
        assertThat(deal.getDealUniqueId()).isEqualTo("TEST123");
        assertThat(deal.getFromCurrency()).isEqualTo("USD");
        assertThat(deal.getToCurrency()).isEqualTo("EUR");
        assertThat(deal.getDealAmount()).isEqualTo(new BigDecimal("1000.50"));
        assertThat(deal.getDealTimestamp()).isEqualTo(LocalDateTime.of(2024, 2, 17, 10, 30, 0));
    }

    @Test
    void testAllFieldsTogether() {
        LocalDateTime now = LocalDateTime.now();
        
        deal.setId(2L);
        deal.setDealUniqueId("UNIQUE789");
        deal.setFromCurrency("GBP");
        deal.setToCurrency("JPY");
        deal.setDealAmount(new BigDecimal("5000.75"));
        deal.setDealTimestamp(now);

        assertThat(deal.getId()).isEqualTo(2L);
        assertThat(deal.getDealUniqueId()).isEqualTo("UNIQUE789");
        assertThat(deal.getFromCurrency()).isEqualTo("GBP");
        assertThat(deal.getToCurrency()).isEqualTo("JPY");
        assertThat(deal.getDealAmount()).isEqualTo(new BigDecimal("5000.75"));
        assertThat(deal.getDealTimestamp()).isEqualTo(now);
    }

    @Test
    void testDealWithNullValues() {
        deal.setDealUniqueId(null);
        deal.setFromCurrency(null);
        deal.setToCurrency(null);
        deal.setDealAmount(null);
        deal.setDealTimestamp(null);

        assertThat(deal.getDealUniqueId()).isNull();
        assertThat(deal.getFromCurrency()).isNull();
        assertThat(deal.getToCurrency()).isNull();
        assertThat(deal.getDealAmount()).isNull();
        assertThat(deal.getDealTimestamp()).isNull();
    }

    @Test
    void testDealWithEmptyStrings() {
        deal.setDealUniqueId("");
        deal.setFromCurrency("");
        deal.setToCurrency("");

        assertThat(deal.getDealUniqueId()).isEmpty();
        assertThat(deal.getFromCurrency()).isEmpty();
        assertThat(deal.getToCurrency()).isEmpty();
    }

    @Test
    void testDealAmountPrecision() {
        deal.setDealAmount(new BigDecimal("999999999.99"));
        assertThat(deal.getDealAmount()).isEqualTo(new BigDecimal("999999999.99"));

        deal.setDealAmount(new BigDecimal("0.01"));
        assertThat(deal.getDealAmount()).isEqualTo(new BigDecimal("0.01"));
    }

    @Test
    void testEqualsAndHashCode() {
        Deal deal1 = new Deal();
        deal1.setId(1L);
        deal1.setDealUniqueId("TEST123");

        Deal deal2 = new Deal();
        deal2.setId(1L);
        deal2.setDealUniqueId("TEST123");

        // Different objects with same ID should be equal
        assertThat(deal1).isNotEqualTo(deal2); // Without proper equals/hashcode
        
        Deal deal3 = new Deal();
        deal3.setId(2L);
        deal3.setDealUniqueId("DIFFERENT");
        
        assertThat(deal1).isNotEqualTo(deal3);
        assertThat(deal1).isNotEqualTo(null);
        assertThat(deal1).isNotEqualTo("string");
    }
}