package com.bloomberg.fxdeals.model;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.Column;

import java.math.BigDecimal;

@Entity
@Table(name = "deals")
public class Deal {

    @Id
    @Column(name = "deal_unique_id", nullable = false, unique = true)
    private String dealUniqueId;

    @Column(name = "from_currency", nullable = false)
    private String fromCurrency;

    @Column(name = "to_currency", nullable = false)
    private String toCurrency;

    @Column(name = "deal_amount", nullable = false)
    private BigDecimal dealAmount;

    @Column(name = "deal_timestamp", nullable = false)
    private String dealTimestamp;

    // ===== Getters & Setters =====

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
