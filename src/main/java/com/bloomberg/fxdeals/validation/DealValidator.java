package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;

public class DealValidator {
    public static void validate(DealRequest request) {
        if (request.getDealUniqueId() == null || request.getDealUniqueId().isEmpty()) {
            throw new IllegalArgumentException("dealUniqueId is required");
        }
        if (request.getFromCurrency() == null || request.getFromCurrency().isEmpty()) {
            throw new IllegalArgumentException("fromCurrency is required");
        }
        if (request.getToCurrency() == null || request.getToCurrency().isEmpty()) {
            throw new IllegalArgumentException("toCurrency is required");
        }
        if (request.getDealAmount() == null || request.getDealAmount().doubleValue() <= 0) {
            throw new IllegalArgumentException("dealAmount must be > 0");
        }
        if (request.getDealTimestamp() == null) {
            throw new IllegalArgumentException("dealTimestamp is required");
        }
    }
}
