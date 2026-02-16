#!/bin/bash

# =============================================
# FX DEALS API - COMPLETE TEST SUITE
# =============================================

BASE_URL="http://localhost:8080/api/deals"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
PASS=0
FAIL=0

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🚀 FX DEALS API TEST SUITE${NC}"
echo -e "${BLUE}========================================${NC}\n"

# =============================================
# Helper Functions
# =============================================
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ PASS: $2${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}❌ FAIL: $2${NC}"
        FAIL=$((FAIL+1))
    fi
}

print_section() {
    echo -e "\n${YELLOW}📌 $1${NC}"
    echo -e "${YELLOW}--------------------${NC}"
}

# =============================================
# 1. HEALTH CHECK
# =============================================
print_section "1. HEALTH CHECK"

# Test GET endpoint
RESPONSE=$(curl -s -X GET $BASE_URL)
if [[ "$RESPONSE" == *"Deals endpoint working"* ]]; then
    print_result 0 "GET /api/deals - Health check"
else
    print_result 1 "GET /api/deals - Health check"
fi

# =============================================
# 2. CREATE VALID DEALS
# =============================================
print_section "2. CREATE VALID DEALS"

# Generate unique IDs
DEAL1_ID="DEAL_$(date +%s)_1"
DEAL2_ID="DEAL_$(date +%s)_2"
DEAL3_ID="DEAL_$(date +%s)_3"

# Create Deal 1: USD to EUR
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$DEAL1_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-16T10:30:00\"
  }")

if [[ "$RESPONSE" == *"$DEAL1_ID"* ]]; then
    print_result 0 "Create Deal 1: USD→EUR (1000.50)"
else
    print_result 1 "Create Deal 1: USD→EUR"
fi

# Create Deal 2: GBP to JPY
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$DEAL2_ID\",
    \"fromCurrency\": \"GBP\",
    \"toCurrency\": \"JPY\",
    \"dealAmount\": 250000.75,
    \"dealTimestamp\": \"2024-02-16T11:45:00\"
  }")

if [[ "$RESPONSE" == *"$DEAL2_ID"* ]]; then
    print_result 0 "Create Deal 2: GBP→JPY (250000.75)"
else
    print_result 1 "Create Deal 2: GBP→JPY"
fi

# Create Deal 3: EUR to USD
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$DEAL3_ID\",
    \"fromCurrency\": \"EUR\",
    \"toCurrency\": \"USD\",
    \"dealAmount\": 850.25,
    \"dealTimestamp\": \"2024-02-16T14:20:00\"
  }")

if [[ "$RESPONSE" == *"$DEAL3_ID"* ]]; then
    print_result 0 "Create Deal 3: EUR→USD (850.25)"
else
    print_result 1 "Create Deal 3: EUR→USD"
fi

# =============================================
# 3. VALIDATION TESTS (Should Fail)
# =============================================
print_section "3. VALIDATION TESTS (Expected Failures)"

# Test 3.1: Negative amount
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": "DEAL_NEGATIVE",
    "fromCurrency": "USD",
    "toCurrency": "EUR",
    "dealAmount": -100,
    "dealTimestamp": "2024-02-16T10:30:00"
  }')

if [[ "$RESPONSE" == *"greater than 0"* ]] || [[ "$RESPONSE" == *"400"* ]]; then
    print_result 0 "Validation: Negative amount (should fail)"
else
    print_result 1 "Validation: Negative amount"
fi

# Test 3.2: Missing required field (toCurrency)
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": "DEAL_MISSING",
    "fromCurrency": "USD",
    "dealAmount": 1000,
    "dealTimestamp": "2024-02-16T10:30:00"
  }')

if [[ "$RESPONSE" == *"required"* ]] || [[ "$RESPONSE" == *"400"* ]]; then
    print_result 0 "Validation: Missing toCurrency (should fail)"
else
    print_result 1 "Validation: Missing toCurrency"
fi

# Test 3.3: Empty dealUniqueId
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": "",
    "fromCurrency": "USD",
    "toCurrency": "EUR",
    "dealAmount": 1000,
    "dealTimestamp": "2024-02-16T10:30:00"
  }')

if [[ "$RESPONSE" == *"required"* ]] || [[ "$RESPONSE" == *"400"* ]]; then
    print_result 0 "Validation: Empty dealUniqueId (should fail)"
else
    print_result 1 "Validation: Empty dealUniqueId"
fi

# Test 3.4: Null dealAmount
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": "DEAL_NULL_AMOUNT",
    "fromCurrency": "USD",
    "toCurrency": "EUR",
    "dealTimestamp": "2024-02-16T10:30:00"
  }')

if [[ "$RESPONSE" == *"required"* ]] || [[ "$RESPONSE" == *"400"* ]]; then
    print_result 0 "Validation: Missing dealAmount (should fail)"
else
    print_result 1 "Validation: Missing dealAmount"
fi

# =============================================
# 4. DUPLICATE PREVENTION TESTS
# =============================================
print_section "4. DUPLICATE PREVENTION TESTS"

# Create original deal
UNIQUE_ID="DEAL_DUPLICATE_$(date +%s)"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 999.99,
    \"dealTimestamp\": \"2024-02-16T10:30:00\"
  }" > /dev/null

# Try to create duplicate
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"GBP\",
    \"toCurrency\": \"JPY\",
    \"dealAmount\": 5000,
    \"dealTimestamp\": \"2024-02-16T15:30:00\"
  }")

if [[ "$RESPONSE" == *"already exists"* ]] || [[ "$RESPONSE" == *"409"* ]]; then
    print_result 0 "Duplicate prevention: Same ID (should fail)"
else
    print_result 1 "Duplicate prevention: Same ID"
fi

# =============================================
# 5. EDGE CASE TESTS
# =============================================
print_section "5. EDGE CASE TESTS"

# Test 5.1: Minimum amount (0.01)
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"DEAL_MIN_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 0.01,
    \"dealTimestamp\": \"2024-02-16T10:30:00\"
  }")

if [[ "$RESPONSE" == *"0.01"* ]]; then
    print_result 0 "Edge case: Minimum amount (0.01)"
else
    print_result 1 "Edge case: Minimum amount"
fi

# Test 5.2: Large amount
LARGE_ID="DEAL_LARGE_$(date +%s)"
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$LARGE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 9999999.99,
    \"dealTimestamp\": \"2024-02-16T10:30:00\"
  }")

if [[ "$RESPONSE" == *"$LARGE_ID"* ]]; then
    print_result 0 "Edge case: Large amount (9999999.99)"
else
    print_result 1 "Edge case: Large amount"
fi

# =============================================
# 6. DATA INTEGRITY TESTS
# =============================================
print_section "6. DATA INTEGRITY TESTS"

# Check if deals are in database (if GET all implemented)
if curl -s -X GET $BASE_URL/all > /dev/null 2>&1; then
    DEAL_COUNT=$(curl -s -X GET $BASE_URL/all | grep -o "dealUniqueId" | wc -l)
    if [ $DEAL_COUNT -gt 0 ]; then
        print_result 0 "Database has $DEAL_COUNT deals"
    else
        print_result 1 "Database is empty"
    fi
else
    echo -e "${YELLOW}⚠️  GET /all not implemented - skipping${NC}"
fi

# =============================================
# 7. INVALID DATA TESTS
# =============================================
print_section "7. INVALID DATA TESTS"

# Test 7.1: Invalid JSON
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": "DEAL_INVALID",
    "fromCurrency": "USD",
    this is invalid json
  }')

if [[ "$RESPONSE" == *"error"* ]]; then
    print_result 0 "Invalid JSON handling"
else
    print_result 1 "Invalid JSON handling"
fi

# Test 7.2: Wrong data types
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "dealUniqueId": 12345,
    "fromCurrency": "USD",
    "toCurrency": "EUR",
    "dealAmount": "not a number",
    "dealTimestamp": "2024-02-16T10:30:00"
  }')

if [[ "$RESPONSE" == *"error"* ]]; then
    print_result 0 "Wrong data type handling"
else
    print_result 1 "Wrong data type handling"
fi

# =============================================
# 8. PERFORMANCE TEST (Optional)
# =============================================
print_section "8. PERFORMANCE TEST (10 concurrent requests)"

if command -v seq &> /dev/null; then
    START_TIME=$(date +%s%N)
    for i in {1..10}; do
        curl -s -X POST $BASE_URL \
          -H "Content-Type: application/json" \
          -d "{
            \"dealUniqueId\": \"DEAL_PERF_$(date +%s)_$i\",
            \"fromCurrency\": \"USD\",
            \"toCurrency\": \"EUR\",
            \"dealAmount\": 100$i,
            \"dealTimestamp\": \"2024-02-16T10:30:00\"
          }" > /dev/null &
    done
    wait
    END_TIME=$(date +%s%N)
    DURATION=$((($END_TIME - $START_TIME)/1000000))
    
    if [ $DURATION -lt 5000 ]; then
        print_result 0 "Performance: 10 requests in ${DURATION}ms"
    else
        print_result 1 "Performance: 10 requests in ${DURATION}ms (slow)"
    fi
else
    echo -e "${YELLOW}⚠️  seq command not found - skipping performance test${NC}"
fi

# =============================================
# SUMMARY
# =============================================
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}📊 TEST SUMMARY${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ PASSED: $PASS${NC}"
echo -e "${RED}❌ FAILED: $FAIL${NC}"
TOTAL=$((PASS+FAIL))
echo -e "${YELLOW}📋 TOTAL:  $TOTAL${NC}"

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! API IS WORKING PERFECTLY!${NC}"
else
    echo -e "\n${RED}⚠️  $FAIL TESTS FAILED. CHECK YOUR API!${NC}"
fi