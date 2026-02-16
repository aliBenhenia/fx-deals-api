package com.bloomberg.fxdeals.repository;

import com.bloomberg.fxdeals.model.Deal;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DealRepository extends JpaRepository<Deal, Long> {
    boolean existsByDealUniqueId(String dealUniqueId);
}
