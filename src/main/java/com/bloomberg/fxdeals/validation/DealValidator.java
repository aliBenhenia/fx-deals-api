package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;
import java.math.BigDecimal;

public class DealValidator {
    
    public static void validate(DealRequest request) {
        if (request.getDealUniqueId() == null || request.getDealUniqueId().trim().isEmpty()) {
            throw new IllegalArgumentException("dealUniqueId is required");
        }
        if (request.getFromCurrency() == null || request.getFromCurrency().trim().isEmpty()) {
            throw new IllegalArgumentException("fromCurrency is required");
        }
        if (request.getToCurrency() == null || request.getToCurrency().trim().isEmpty()) {
            throw new IllegalArgumentException("toCurrency is required");
        }
        if (request.getDealAmount() == null) {
            throw new IllegalArgumentException("dealAmount is required");
        }
        if (request.getDealAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("dealAmount must be greater than 0");
        }
        if (request.getDealTimestamp() == null) {
            throw new IllegalArgumentException("dealTimestamp is required");
        }
    }
}