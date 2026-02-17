package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.Set;

public class DealValidator {
    
    private static final Set<String> VALID_CURRENCIES = Set.of(
        "USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY", 
        "INR", "BRL", "ZAR", "SGD", "NZD", "MXN", "HKD", "NOK",
        "SEK", "DKK", "PLN", "TRY", "RUB", "KRW", "IDR", "MYR"
    );
    
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
        
        if (!isValidCurrencyCode(request.getFromCurrency())) {
            throw new IllegalArgumentException("Invalid fromCurrency: must be 3-letter ISO code (e.g., USD, EUR)");
        }
        if (!isValidCurrencyCode(request.getToCurrency())) {
            throw new IllegalArgumentException("Invalid toCurrency: must be 3-letter ISO code (e.g., USD, EUR)");
        }
        
        if (!isValidTimestamp(request.getDealTimestamp())) {
            throw new IllegalArgumentException("Invalid timestamp format. Use: yyyy-MM-ddTHH:mm:ss (e.g., 2024-02-16T10:30:00)");
        }
    }
    
    private static boolean isValidCurrencyCode(String currency) {
        return currency != null && 
               currency.length() == 3 && 
               currency.matches("[A-Z]{3}") &&
               VALID_CURRENCIES.contains(currency.toUpperCase());
    }
    
    private static boolean isValidTimestamp(LocalDateTime timestamp) {
        LocalDateTime now = LocalDateTime.now();
        
        // Allow timestamps within last 30 days and next 1 day
        boolean notTooOld = !timestamp.isBefore(now.minusDays(30));
        boolean notTooFuture = !timestamp.isAfter(now.plusDays(1));
        
        return notTooOld && notTooFuture;
    }
}