package com.bloomberg.fxdeals.service;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;
import java.util.List;  

public interface DealService {
    
    Deal createDeal(DealRequest request);
    List<Deal> getAllDeals();  
}