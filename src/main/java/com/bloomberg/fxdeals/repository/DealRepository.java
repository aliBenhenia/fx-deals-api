package com.bloomberg.fxdeals.repository;

import com.bloomberg.fxdeals.model.Deal;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DealRepository extends JpaRepository<Deal, Long> {}
