package com.bloomberg.fxdeals.service;

import com.bloomberg.fxdeals.dto.DealRequest;
import com.bloomberg.fxdeals.model.Deal;
import com.bloomberg.fxdeals.repository.DealRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class DealServiceImpl implements DealService {

    private final DealRepository dealRepository;

    public DealServiceImpl(DealRepository dealRepository) {
        this.dealRepository = dealRepository;
    }

    @Override
    @Transactional
    public Deal createDeal(DealRequest request) {
        
       
        if (dealRepository.existsByDealUniqueId(request.getDealUniqueId())) {
            throw new RuntimeException("Deal already exists with ID: " + request.getDealUniqueId());
        }

 
        Deal deal = new Deal();
        deal.setDealUniqueId(request.getDealUniqueId());
        deal.setFromCurrency(request.getFromCurrency());
        deal.setToCurrency(request.getToCurrency());
        deal.setDealAmount(request.getDealAmount());
        deal.setDealTimestamp(request.getDealTimestamp());

      
        return dealRepository.save(deal);
    }
    
    @Override
    public List<Deal> getAllDeals() {  
        return dealRepository.findAll();
    }
}