package com.bloomberg.fxdeals.validation;

import com.bloomberg.fxdeals.dto.DealRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.assertThatCode;

class DealValidatorTest {

    private DealRequest validRequest;

    @BeforeEach
    void setUp() {
        validRequest = new DealRequest();
        validRequest.setDealUniqueId("TEST123");
        validRequest.setFromCurrency("USD");
        validRequest.setToCurrency("EUR");
        validRequest.setDealAmount(new BigDecimal("1000.50"));
        validRequest.setDealTimestamp(LocalDateTime.now());  // Use current time
    }

    @Test
    void validate_ShouldPass_WhenAllFieldsValid() {
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    // ===== REQUIRED FIELD TESTS =====
    @Test
    void validate_ShouldThrow_WhenDealUniqueIdNull() {
        validRequest.setDealUniqueId(null);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("dealUniqueId is required");
    }

    @Test
    void validate_ShouldThrow_WhenDealUniqueIdEmpty() {
        validRequest.setDealUniqueId("");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("dealUniqueId is required");
    }

    @Test
    void validate_ShouldThrow_WhenDealUniqueIdBlank() {
        validRequest.setDealUniqueId("   ");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("dealUniqueId is required");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyNull() {
        validRequest.setFromCurrency(null);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("fromCurrency is required");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyEmpty() {
        validRequest.setFromCurrency("");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("fromCurrency is required");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyNull() {
        validRequest.setToCurrency(null);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("toCurrency is required");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyEmpty() {
        validRequest.setToCurrency("");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("toCurrency is required");
    }

    @Test
    void validate_ShouldThrow_WhenDealAmountNull() {
        validRequest.setDealAmount(null);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("dealAmount is required");
    }

    @Test
    void validate_ShouldThrow_WhenDealAmountZero() {
        validRequest.setDealAmount(BigDecimal.ZERO);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("greater than 0");
    }

    @Test
    void validate_ShouldThrow_WhenDealAmountNegative() {
        validRequest.setDealAmount(new BigDecimal("-100"));
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("greater than 0");
    }

    @Test
    void validate_ShouldThrow_WhenDealTimestampNull() {
        validRequest.setDealTimestamp(null);
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("dealTimestamp is required");
    }

    // ===== CURRENCY VALIDATION TESTS =====
    @Test
    void validate_ShouldThrow_WhenFromCurrencyTooLong() {
        validRequest.setFromCurrency("USDOLLAR");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyTooShort() {
        validRequest.setFromCurrency("US");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyLowerCase() {
        validRequest.setFromCurrency("usd");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyContainsNumbers() {
        validRequest.setFromCurrency("US1");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyInvalidCode() {
        validRequest.setFromCurrency("XXX");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyTooLong() {
        validRequest.setToCurrency("EUROPE");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyTooShort() {
        validRequest.setToCurrency("EU");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyLowerCase() {
        validRequest.setToCurrency("eur");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyContainsNumbers() {
        validRequest.setToCurrency("EU1");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenToCurrencyInvalidCode() {
        validRequest.setToCurrency("YYY");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    @ParameterizedTest
    @ValueSource(strings = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY"})
    void validate_ShouldPass_WhenFromCurrencyValid(String currency) {
        validRequest.setFromCurrency(currency);
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    @ParameterizedTest
    @ValueSource(strings = {"USD", "EUR", "GBP", "JPY", "CHF", "CAD", "AUD", "CNY"})
    void validate_ShouldPass_WhenToCurrencyValid(String currency) {
        validRequest.setToCurrency(currency);
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    // ===== COMBINATION TESTS =====
    @Test
    void validate_ShouldThrow_WhenBothCurrenciesInvalid() {
        validRequest.setFromCurrency("ABC");
        validRequest.setToCurrency("DEF");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid fromCurrency");
    }

    @Test
    void validate_ShouldThrow_WhenFromCurrencyValidToCurrencyInvalid() {
        validRequest.setFromCurrency("USD");
        validRequest.setToCurrency("XYZ");
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid toCurrency");
    }

    // ===== TIMESTAMP VALIDATION TESTS =====
    @Test
    void validate_ShouldPass_WithCurrentTimestamp() {
        validRequest.setDealTimestamp(LocalDateTime.now());
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    @Test
    void validate_ShouldPass_WithPastTimestampWithinRange() {
        validRequest.setDealTimestamp(LocalDateTime.now().minusDays(1));  // 1 day past
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    @Test
    void validate_ShouldPass_WithFutureTimestampWithinRange() {
        validRequest.setDealTimestamp(LocalDateTime.now().plusHours(23));  // 23 hours future
        assertThatCode(() -> DealValidator.validate(validRequest))
            .doesNotThrowAnyException();
    }

    @Test
    void validate_ShouldThrow_WhenTimestampTooOld() {
        validRequest.setDealTimestamp(LocalDateTime.now().minusDays(31));  // 31 days past
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid timestamp");
    }

    @Test
    void validate_ShouldThrow_WhenTimestampTooFuture() {
        validRequest.setDealTimestamp(LocalDateTime.now().plusDays(2));  // 2 days future
        assertThatThrownBy(() -> DealValidator.validate(validRequest))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("Invalid timestamp");
    }
    @Test
void validate_ShouldThrow_WhenTimestampInvalid() {
    // Use a timestamp that fails validation (e.g., 31 days old)
    validRequest.setDealTimestamp(LocalDateTime.now().minusDays(31));
    assertThatThrownBy(() -> DealValidator.validate(validRequest))
        .isInstanceOf(IllegalArgumentException.class)
        .hasMessageContaining("Invalid timestamp");
}


}