package com.bloomberg.fxdeals.service;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;

public interface DealService {
    
    Deal createDeal(DealRequest request);
}