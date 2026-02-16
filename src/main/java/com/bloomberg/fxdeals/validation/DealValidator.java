package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;
import java.math.BigDecimal;
import java.util.Set;

public class DealValidator {
    
   
    private static final Set<String> VALID_CURRENCIES = Set.of(
        "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY", 
        "INR", "BRL", "ZAR", "SGD", "NZD", "MXN", "HKD", "NOK",
        "SEK", "DKK", "PLN", "TRY", "RUB", "KRW", "IDR", "MYR"
    );
    
    public static void validate(DealRequest request) {
        // Existing validations
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
        
        
        if (!isValidCurrencyCode(request.getFromCurrency())) {
            throw new IllegalArgumentException("Invalid fromCurrency: must be 3-letter ISO code");
        }
        if (!isValidCurrencyCode(request.getToCurrency())) {
            throw new IllegalArgumentException("Invalid toCurrency: must be 3-letter ISO code");
        }
    }
    
    private static boolean isValidCurrencyCode(String currency) {
        return currency != null && 
               currency.length() == 3 && 
               currency.matches("[A-Z]{3}") &&
               VALID_CURRENCIES.contains(currency);
    }
}