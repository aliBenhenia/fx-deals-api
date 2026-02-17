package com.bloomberg.fxdeals.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.UUID;

@Aspect
@Component
public class LoggingAspect {

    private static final Logger log = LoggerFactory.getLogger(LoggingAspect.class);

   
    @Pointcut("within(@org.springframework.web.bind.annotation.RestController *)")
    public void controllerMethods() {}

  
    @Pointcut("within(@org.springframework.stereotype.Service *)")
    public void serviceMethods() {}

    
    @Pointcut("within(@org.springframework.stereotype.Repository *)")
    public void repositoryMethods() {}

 
    @Pointcut("within(com.bloomberg.fxdeals.validation.*)")
    public void validationMethods() {}

   
    @Around("controllerMethods() || serviceMethods() || repositoryMethods() || validationMethods()")
    public Object logAround(ProceedingJoinPoint joinPoint) throws Throwable {
        
        
        String correlationId = UUID.randomUUID().toString();
        MDC.put("correlationId", correlationId);
        
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        String fullMethodName = className + "." + methodName;
        
       
        Object[] args = joinPoint.getArgs();
        String arguments = args.length > 0 ? Arrays.toString(args) : "no arguments";
        
        
        log.info("→ Entering: {}() | Args: {}", fullMethodName, arguments);
        
        
        if (className.contains("Service") || className.contains("Validator")) {
            log.debug("→ {} called with: {}", fullMethodName, arguments);
        }
        
        long startTime = System.currentTimeMillis();
        
        try {
            
            Object result = joinPoint.proceed();
            
            long duration = System.currentTimeMillis() - startTime;
            
            
            if (methodName.contains("create") || methodName.contains("save")) {
                log.info("✓ {} completed successfully in {}ms | Result: {}", 
                    fullMethodName, duration, result);
            } else {
                log.debug("✓ {} completed in {}ms", fullMethodName, duration);
            }
            
            return result;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            
          
            log.error("✗ {} failed after {}ms | Error: {}", 
                fullMethodName, duration, e.getMessage(), e);
            
         
            throw e;
            
        } finally {
            MDC.clear();
        }
    }

   
    @Around("validationMethods() && execution(* *(..))")
    public Object logValidation(ProceedingJoinPoint joinPoint) throws Throwable {
        try {
            return joinPoint.proceed();
        } catch (IllegalArgumentException e) {
            log.warn("Validation failed in {}: {}", 
                joinPoint.getSignature().getName(), e.getMessage());
            throw e;
        }
    }
}