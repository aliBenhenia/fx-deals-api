package com.bloomberg.fxdeals.controller;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.dto.DealResponse;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.service.DealService;
import com.bloomberg.fxdeals.validation.DealValidator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/deals")
public class DealController {

    @Autowired
    private DealService dealService;

    @PostMapping
    public DealResponse createDeal(@RequestBody DealRequest request) {

        DealValidator.validate(request);

        Deal deal = dealService.createDeal(request);

        DealResponse response = new DealResponse();
        response.setDealUniqueId(deal.getDealUniqueId());
        response.setFromCurrency(deal.getFromCurrency());
        response.setToCurrency(deal.getToCurrency());
        response.setDealAmount(deal.getDealAmount());
        response.setDealTimestamp(deal.getDealTimestamp());

        return response;
    }
            @GetMapping
        public String getAllDeals() {
            return "Deals endpoint working!";
}
}
