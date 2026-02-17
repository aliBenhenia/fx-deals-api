package com.bloomberg.fxdeals.aspect;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.Arrays;
import java.util.UUID;

@Aspect
@Component
public class EnhancedLoggingAspect {

    private static final Logger log = LoggerFactory.getLogger(EnhancedLoggingAspect.class);

    @Pointcut("@within(org.springframework.stereotype.Service) || " +
              "@within(org.springframework.web.bind.annotation.RestController) || " +
              "@within(org.springframework.stereotype.Repository)")
    public void allBeans() {}

    @Around("allBeans()")
    public Object logAll(ProceedingJoinPoint joinPoint) throws Throwable {
        
        String correlationId = UUID.randomUUID().toString();
        MDC.put("correlationId", correlationId);
        
        String className = joinPoint.getTarget().getClass().getSimpleName();
        String methodName = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        
      
        String logLevel = detectLogLevel(methodName);
        
    
        log.info("▶️ {}.{}() called | Args: {}", className, methodName, 
            args.length > 0 ? Arrays.toString(args) : "none");
        
        long start = System.currentTimeMillis();
        
        try {
            Object result = joinPoint.proceed();
            long duration = System.currentTimeMillis() - start;
            
            
            if (methodName.startsWith("create") || methodName.startsWith("save")) {
                log.info("✅ {}.{}() completed in {}ms | Result: {}", 
                    className, methodName, duration, result);
            } else if (methodName.startsWith("delete")) {
                log.info("🗑️ {}.{}() completed in {}ms", className, methodName, duration);
            } else if (methodName.startsWith("find") || methodName.startsWith("get")) {
                log.debug("📖 {}.{}() completed in {}ms | Found: {}", 
                    className, methodName, duration, result);
            } else {
                log.debug("✓ {}.{}() completed in {}ms", className, methodName, duration);
            }
            
            return result;
            
        } catch (Exception e) {
            long duration = System.currentTimeMillis() - start;
            log.error("❌ {}.{}() failed after {}ms | Error: {}", 
                className, methodName, duration, e.getMessage(), e);
            throw e;
        } finally {
            MDC.clear();
        }
    }
    
    private String detectLogLevel(String methodName) {
        if (methodName.contains("error") || methodName.contains("fail")) {
            return "ERROR";
        } else if (methodName.contains("warn")) {
            return "WARN";
        } else if (methodName.contains("debug")) {
            return "DEBUG";
        }
        return "INFO";
    }
}