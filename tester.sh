#!/bin/bash

# =============================================
# COMPLETE API TEST SUITE USING CURL
# FIXED TIMESTAMP FORMAT
# =============================================

BASE_URL="http://localhost:8080/api/deals"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper function to get timestamp in correct format (no timezone)
get_timestamp() {
    # Format: YYYY-MM-DDTHH:MM:SS
    date +"%Y-%m-%dT%H:%M:%S"
}

get_timestamp_days_ago() {
    days=$1
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -v-${days}d +"%Y-%m-%dT%H:%M:%S"
    else
        # Linux
        date -d "$days days ago" +"%Y-%m-%dT%H:%M:%S"
    fi
}

get_timestamp_days_ahead() {
    days=$1
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        date -v+${days}d +"%Y-%m-%dT%H:%M:%S"
    else
        # Linux
        date -d "$days days" +"%Y-%m-%dT%H:%M:%S"
    fi
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}  ✅ $2${NC}"
    else
        echo -e "${RED}  ❌ $2${NC}"
    fi
}

# =============================================
# 1. HEALTH CHECK
# =============================================
print_header "1. HEALTH CHECK"

RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
if [ "$RESPONSE" -eq 200 ]; then
    print_result 0 "Health check passed (200 OK)"
else
    print_result 1 "Health check failed (got $RESPONSE)"
fi

# =============================================
# 2. CREATE VALID DEALS
# =============================================
print_header "2. CREATE VALID DEALS"

# Test 2.1: Valid deal with current timestamp
echo -e "\n${YELLOW}Test 2.1: Valid deal with current time${NC}"
UNIQUE_ID="VALID_$(date +%s)"
CURRENT_TIME=$(get_timestamp)
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$CURRENT_TIME\"
  }")
if [[ "$RESPONSE" == *"$UNIQUE_ID"* ]]; then
    print_result 0 "Created deal with ID: $UNIQUE_ID"
else
    print_result 1 "Failed to create deal"
    echo "$RESPONSE"
fi

# Test 2.2: Valid deal with yesterday's date (within 30 days)
echo -e "\n${YELLOW}Test 2.2: Valid deal with yesterday's date${NC}"
UNIQUE_ID="YESTERDAY_$(date +%s)"
YESTERDAY=$(get_timestamp_days_ago 1)
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"GBP\",
    \"toCurrency\": \"JPY\",
    \"dealAmount\": 2500.75,
    \"dealTimestamp\": \"$YESTERDAY\"
  }")
if [[ "$RESPONSE" == *"$UNIQUE_ID"* ]]; then
    print_result 0 "Created deal with yesterday's date"
else
    print_result 1 "Failed with yesterday's date"
fi

# Test 2.3: Valid deal with tomorrow's date (within 1 day)
echo -e "\n${YELLOW}Test 2.3: Valid deal with tomorrow's date${NC}"
UNIQUE_ID="TOMORROW_$(date +%s)"
TOMORROW=$(get_timestamp_days_ahead 1)
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"EUR\",
    \"toCurrency\": \"USD\",
    \"dealAmount\": 800.25,
    \"dealTimestamp\": \"$TOMORROW\"
  }")
if [[ "$RESPONSE" == *"$UNIQUE_ID"* ]]; then
    print_result 0 "Created deal with tomorrow's date"
else
    print_result 1 "Failed with tomorrow's date"
fi

# =============================================
# 3. VALIDATION TESTS (Should Fail with 400)
# =============================================
print_header "3. VALIDATION TESTS (Expected 400)"

# Test 3.1: Missing dealUniqueId
echo -e "\n${YELLOW}Test 3.1: Missing dealUniqueId${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d '{
    "fromCurrency": "USD",
    "toCurrency": "EUR",
    "dealAmount": 1000.50,
    "dealTimestamp": "2024-02-17T10:30:00"
  }')
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Correctly rejected - missing dealUniqueId"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 3.2: Missing fromCurrency
echo -e "\n${YELLOW}Test 3.2: Missing fromCurrency${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"MISSING_FROM_$(date +%s)\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Correctly rejected - missing fromCurrency"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 3.3: Negative amount
echo -e "\n${YELLOW}Test 3.3: Negative amount${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"NEG_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": -100,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Correctly rejected - negative amount"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 3.4: Zero amount
echo -e "\n${YELLOW}Test 3.4: Zero amount${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"ZERO_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 0,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Correctly rejected - zero amount"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# =============================================
# 4. CURRENCY VALIDATION TESTS
# =============================================
print_header "4. CURRENCY VALIDATION TESTS"

# Test 4.1: Invalid currency (too long)
echo -e "\n${YELLOW}Test 4.1: Invalid currency (USDOLLAR)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"CURR_LONG_$(date +%s)\",
    \"fromCurrency\": \"USDOLLAR\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - currency too long"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 4.2: Invalid currency (too short)
echo -e "\n${YELLOW}Test 4.2: Invalid currency (US)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"CURR_SHORT_$(date +%s)\",
    \"fromCurrency\": \"US\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - currency too short"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 4.3: Invalid currency (lowercase)
echo -e "\n${YELLOW}Test 4.3: Invalid currency (usd)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"CURR_LOW_$(date +%s)\",
    \"fromCurrency\": \"usd\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - lowercase currency"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 4.4: Invalid currency (not in list)
echo -e "\n${YELLOW}Test 4.4: Invalid currency (XXX)${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"CURR_XXX_$(date +%s)\",
    \"fromCurrency\": \"XXX\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"2024-02-17T10:30:00\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - currency not in list"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# =============================================
# 5. TIMESTAMP VALIDATION TESTS
# =============================================
print_header "5. TIMESTAMP VALIDATION TESTS"

# Test 5.1: Timestamp too old (31 days ago)
echo -e "\n${YELLOW}Test 5.1: Timestamp too old (31 days ago)${NC}"
OLD_DATE=$(get_timestamp_days_ago 31)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"OLD_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$OLD_DATE\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - timestamp too old"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# Test 5.2: Timestamp too future (2 days ahead)
echo -e "\n${YELLOW}Test 5.2: Timestamp too future (2 days ahead)${NC}"
FUTURE_DATE=$(get_timestamp_days_ahead 2)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"FUTURE_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$FUTURE_DATE\"
  }")
if [ "$HTTP_CODE" -eq 400 ]; then
    print_result 0 "Rejected - timestamp too future"
else
    print_result 1 "Expected 400, got $HTTP_CODE"
fi

# =============================================
# 6. DUPLICATE PREVENTION TEST
# =============================================
print_header "6. DUPLICATE PREVENTION TEST"

# Create a deal
DUPLICATE_ID="DUP_$(date +%s)"
CURRENT_TIME=$(get_timestamp)
echo -e "\n${YELLOW}Creating first deal with ID: $DUPLICATE_ID${NC}"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$DUPLICATE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$CURRENT_TIME\"
  }" > /dev/null

# Try to create duplicate
echo -e "\n${YELLOW}Attempting duplicate with same ID${NC}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$DUPLICATE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$CURRENT_TIME\"
  }")
if [ "$HTTP_CODE" -eq 409 ]; then
    print_result 0 "Duplicate correctly rejected with 409"
elif [ "$HTTP_CODE" -eq 400 ]; then
    print_result 1 "Got 400 instead of 409 - check error handling"
else
    print_result 1 "Expected 409, got $HTTP_CODE"
fi

# =============================================
# 7. BATCH TEST - MULTIPLE CURRENCY PAIRS
# =============================================
print_header "7. BATCH TEST - MULTIPLE CURRENCIES"

CURRENCIES=("USD:EUR" "GBP:JPY" "EUR:CHF" "CAD:AUD" "CNY:USD")
PASSED=0
CURRENT_TIME=$(get_timestamp)

for i in {1..5}; do
    IFS=':' read -r FROM TO <<< "${CURRENCIES[$((i-1))]}"
    UNIQUE_ID="BATCH_$(date +%s)_$i"
    
    echo -e "\n${YELLOW}Testing $FROM → $TO${NC}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
      -H "Content-Type: application/json" \
      -d "{
        \"dealUniqueId\": \"$UNIQUE_ID\",
        \"fromCurrency\": \"$FROM\",
        \"toCurrency\": \"$TO\",
        \"dealAmount\": 100$i,
        \"dealTimestamp\": \"$CURRENT_TIME\"
      }")
    
    if [ "$HTTP_CODE" -eq 201 ]; then
        PASSED=$((PASSED+1))
        echo "    ✓ $FROM→$TO: $HTTP_CODE"
    else
        echo "    ✗ $FROM→$TO: $HTTP_CODE"
    fi
    sleep 1
done

if [ "$PASSED" -eq 5 ]; then
    print_result 0 "All 5 currency pairs accepted"
else
    print_result 1 "Only $PASSED/5 currency pairs accepted"
fi

# =============================================
# SUMMARY
# =============================================
print_header "✅ TEST SUMMARY"
echo -e "\n${GREEN}All curl tests completed!${NC}"
echo -e "${YELLOW}Check the results above for any failures${NC}"