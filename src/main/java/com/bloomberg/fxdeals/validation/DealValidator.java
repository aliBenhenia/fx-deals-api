package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;
import java.math.BigDecimal;

public class DealValidator {

    public static void validate(DealRequest request) {

        if (request.getDealUniqueId() == null || request.getDealUniqueId().isEmpty()) {
            throw new IllegalArgumentException("Deal ID is required");
        }

        if (request.getFromCurrency() == null || request.getFromCurrency().isEmpty()) {
            throw new IllegalArgumentException("From currency is required");
        }

        if (request.getToCurrency() == null || request.getToCurrency().isEmpty()) {
            throw new IllegalArgumentException("To currency is required");
        }

        if (request.getDealAmount() == null || request.getDealAmount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Amount must be > 0");
        }

        if (request.getDealTimestamp() == null || request.getDealTimestamp().isEmpty()) {
            throw new IllegalArgumentException("Timestamp is required");
        }
    }
}
