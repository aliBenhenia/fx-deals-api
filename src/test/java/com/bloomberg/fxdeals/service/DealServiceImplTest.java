package com.bloomberg.fxdeals.service;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.repository.DealRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DealServiceImplTest {

    @Mock
    private DealRepository dealRepository;

    @InjectMocks
    private DealServiceImpl dealService;

    private DealRequest validRequest;
    private Deal validDeal;

    @BeforeEach
    void setUp() {
        validRequest = new DealRequest();
        validRequest.setDealUniqueId("TEST123");
        validRequest.setFromCurrency("USD");
        validRequest.setToCurrency("EUR");
        validRequest.setDealAmount(new BigDecimal("1000.50"));
        validRequest.setDealTimestamp(LocalDateTime.now());

        validDeal = new Deal();
        validDeal.setId(1L);
        validDeal.setDealUniqueId("TEST123");
        validDeal.setFromCurrency("USD");
        validDeal.setToCurrency("EUR");
        validDeal.setDealAmount(new BigDecimal("1000.50"));
        validDeal.setDealTimestamp(LocalDateTime.now());
    }

    @Test
    void createDeal_ShouldSaveAndReturnDeal_WhenValid() {
        when(dealRepository.existsByDealUniqueId("TEST123")).thenReturn(false);
        when(dealRepository.save(any(Deal.class))).thenReturn(validDeal);

        Deal result = dealService.createDeal(validRequest);

        assertThat(result).isNotNull();
        assertThat(result.getDealUniqueId()).isEqualTo("TEST123");
        assertThat(result.getFromCurrency()).isEqualTo("USD");
        assertThat(result.getToCurrency()).isEqualTo("EUR");
        assertThat(result.getDealAmount()).isEqualTo(new BigDecimal("1000.50"));
        
        verify(dealRepository).existsByDealUniqueId("TEST123");
        verify(dealRepository).save(any(Deal.class));
    }

    @Test
    void createDeal_ShouldThrowException_WhenDealAlreadyExists() {
        when(dealRepository.existsByDealUniqueId("TEST123")).thenReturn(true);

        assertThatThrownBy(() -> dealService.createDeal(validRequest))
            .isInstanceOf(RuntimeException.class)
            .hasMessageContaining("already exists");

        verify(dealRepository, never()).save(any());
    }

    @Test
    void createDeal_ShouldHandleRepositoryException() {
        when(dealRepository.existsByDealUniqueId("TEST123")).thenReturn(false);
        when(dealRepository.save(any(Deal.class)))
            .thenThrow(new RuntimeException("Database error"));

        assertThatThrownBy(() -> dealService.createDeal(validRequest))
            .isInstanceOf(RuntimeException.class)
            .hasMessageContaining("Database error");
    }

    @Test
    void getAllDeals_ShouldReturnListOfDeals() {
        List<Deal> expectedDeals = Arrays.asList(validDeal, validDeal);
        when(dealRepository.findAll()).thenReturn(expectedDeals);

        List<Deal> result = dealService.getAllDeals();

        assertThat(result).hasSize(2);
        verify(dealRepository).findAll();
    }

    @Test
    void getAllDeals_ShouldReturnEmptyList_WhenNoDeals() {
        when(dealRepository.findAll()).thenReturn(Collections.emptyList());

        List<Deal> result = dealService.getAllDeals();

        assertThat(result).isEmpty();
        verify(dealRepository).findAll();
    }

    @Test
    void getAllDeals_ShouldCallRepositoryOnce() {
        when(dealRepository.findAll()).thenReturn(Collections.emptyList());

        dealService.getAllDeals();

        verify(dealRepository, times(1)).findAll();
    }

    @Test
    void createDeal_ShouldSetAllFieldsCorrectly() {
        when(dealRepository.existsByDealUniqueId("TEST123")).thenReturn(false);
        when(dealRepository.save(any(Deal.class))).thenAnswer(i -> i.getArgument(0));

        Deal result = dealService.createDeal(validRequest);

        assertThat(result.getDealUniqueId()).isEqualTo(validRequest.getDealUniqueId());
        assertThat(result.getFromCurrency()).isEqualTo(validRequest.getFromCurrency());
        assertThat(result.getToCurrency()).isEqualTo(validRequest.getToCurrency());
        assertThat(result.getDealAmount()).isEqualTo(validRequest.getDealAmount());
        assertThat(result.getDealTimestamp()).isEqualTo(validRequest.getDealTimestamp());
    }
}