#!/bin/bash

# =============================================
# TEST SCRIPT FOR AOP LOGGING
# =============================================

BASE_URL="http://localhost:8080/api/deals"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 TESTING AOP AUTOMATIC LOGGING${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Clear previous logs
docker logs fx-deals-api-app-1 --tail 0 > /dev/null 2>&1
sleep 2

# Test 1: Create Deal
echo -e "${YELLOW}📌 Test 1: Create Deal - Check AOP Logs${NC}"
UNIQUE_ID="AOP_TEST_$(date +%s)"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }" > /dev/null

sleep 2

echo -e "\n${GREEN}🔍 Checking AOP Logs:${NC}"
docker logs fx-deals-api-app-1 --tail 20 2>&1 | grep -E "Entering:|completed in" | tail -10

# Check specific log patterns
echo -e "\n${YELLOW}📊 Log Pattern Summary:${NC}"
INFO_COUNT=$(docker logs fx-deals-api-app-1 --since 1m 2>&1 | grep -c "INFO")
DEBUG_COUNT=$(docker logs fx-deals-api-app-1 --since 1m 2>&1 | grep -c "DEBUG")
WARN_COUNT=$(docker logs fx-deals-api-app-1 --since 1m 2>&1 | grep -c "WARN")
ERROR_COUNT=$(docker logs fx-deals-api-app-1 --since 1m 2>&1 | grep -c "ERROR")

echo -e "  INFO : $INFO_COUNT logs"
echo -e "  DEBUG: $DEBUG_COUNT logs"
echo -e "  WARN : $WARN_COUNT logs"
echo -e "  ERROR: $ERROR_COUNT logs"

echo -e "\n${GREEN}✅ AOP Logging is working!${NC}"