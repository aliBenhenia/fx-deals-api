package com.bloomberg.fxdeals.dto;

public class DealResponse {
    private String dealId;
    private String status;

    public DealResponse(String dealId, String status) {
        this.dealId = dealId;
        this.status = status;
    }


    public String getDealId() {  return dealId; }
    public String getStatus() { return status; }
}
