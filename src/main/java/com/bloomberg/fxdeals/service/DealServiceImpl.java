package com.bloomberg.fxdeals.service;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;
import org.springframework.stereotype.Service;

@Service
public class DealServiceImpl implements DealService {

    @Override
    public Deal createDeal(DealRequest request) {

        Deal deal = new Deal();
        deal.setDealUniqueId(request.getDealUniqueId());
        deal.setFromCurrency(request.getFromCurrency());
        deal.setToCurrency(request.getToCurrency());
        deal.setDealAmount(request.getDealAmount());
        deal.setDealTimestamp(request.getDealTimestamp());

        return deal;
    }
}
