package com.bloomberg.fxdeals.dto;

import java.math.BigDecimal;

public class DealRequest {

    private String dealUniqueId;
    private String fromCurrency;
    private String toCurrency;
    private BigDecimal dealAmount;
    private String dealTimestamp;

    public String getDealUniqueId() {
        return dealUniqueId;
    }

    public void setDealUniqueId(String dealUniqueId) {
        this.dealUniqueId = dealUniqueId;
    }

    public String getFromCurrency() {
        return fromCurrency;
    }

    public void setFromCurrency(String fromCurrency) {
        this.fromCurrency = fromCurrency;
    }

    public String getToCurrency() {
        return toCurrency;
    }

    public void setToCurrency(String toCurrency) {
        this.toCurrency = toCurrency;
    }

    public BigDecimal getDealAmount() {
        return dealAmount;
    }

    public void setDealAmount(BigDecimal dealAmount) {
        this.dealAmount = dealAmount;
    }

    public String getDealTimestamp() {
        return dealTimestamp;
    }

    public void setDealTimestamp(String dealTimestamp) {
        this.dealTimestamp = dealTimestamp;
    }
}
