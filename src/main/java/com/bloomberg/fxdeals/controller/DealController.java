package com.bloomberg.fxdeals.controller;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.dto.DealResponse;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.service.DealService;
import com.bloomberg.fxdeals.validation.DealValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/deals")
public class DealController {

    private final DealService dealService;

    @Autowired
    public DealController(DealService dealService) {
        this.dealService = dealService;
    }

    @PostMapping
    public ResponseEntity<DealResponse> createDeal(@RequestBody DealRequest request) {

        // Validate request
        DealValidator.validate(request);

        // Process deal
        Deal deal = dealService.createDeal(request);

        // Build response
        DealResponse response = new DealResponse();
        response.setDealUniqueId(deal.getDealUniqueId());
        response.setFromCurrency(deal.getFromCurrency());
        response.setToCurrency(deal.getToCurrency());
        response.setDealAmount(deal.getDealAmount());
        response.setDealTimestamp(deal.getDealTimestamp());

        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping
    public String getAllDeals() {
        return "Deals endpoint working!";
    }
}