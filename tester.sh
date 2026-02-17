#!/bin/bash

# =============================================
# COMPLETE WORKING API TEST SCRIPT
# Bloomberg FX Deals API
# =============================================

# Configuration
BASE_URL="http://localhost:8080/api/deals"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# =============================================
# Helper Functions
# =============================================
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}  ✅ $1${NC}"
}

print_error() {
    echo -e "${RED}  ❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}  ℹ️ $1${NC}"
}

# =============================================
# 1. HEALTH CHECK
# =============================================
print_header "🔍 HEALTH CHECK"

HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL/health)
if [ "$HEALTH_CHECK" -eq 200 ]; then
    print_success "Health check passed (200 OK)"
else
    print_error "Health check failed (HTTP $HEALTH_CHECK)"
fi

# =============================================
# 2. CREATE VALID DEALS (5 Different Deals)
# =============================================
print_header "💰 CREATING VALID DEALS"

# Array of currency pairs
CURRENCIES=("USD:EUR" "GBP:JPY" "EUR:USD" "USD:GBP" "JPY:EUR")

for i in {1..5}; do
    # Parse currency pair
    IFS=':' read -r FROM TO <<< "${CURRENCIES[$((i-1))]}"
    
    # Generate unique ID with timestamp
    UNIQUE_ID="DEAL_$(date +%s)_$i"
    AMOUNT=$((1000 + i * 100)).$((i * 10))
    
    print_info "Creating deal $i: $FROM → $TO for $AMOUNT"
    
    # Construct JSON properly with escaped quotes
    JSON_DATA="{
        \"dealUniqueId\": \"$UNIQUE_ID\",
        \"fromCurrency\": \"$FROM\",
        \"toCurrency\": \"$TO\",
        \"dealAmount\": $AMOUNT,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }"
    
    # Send request
    RESPONSE=$(curl -s -X POST "$BASE_URL" \
        -H "Content-Type: application/json" \
        -d "$JSON_DATA")
    
    # Check response
    if [[ "$RESPONSE" == *"$UNIQUE_ID"* ]]; then
        print_success "Deal $i created successfully"
        echo "     Response: $RESPONSE" | head -c 100
        echo "..."
    else
        print_error "Failed to create deal $i"
        echo "     Error: $RESPONSE"
    fi
    
    echo ""
    sleep 1
done

# =============================================
# 3. TEST VALIDATION (Error Cases)
# =============================================
print_header "⚠️  TESTING VALIDATION (Expected Errors)"

# Test 3.1: Missing field
print_info "Testing missing field..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d '{
        "fromCurrency": "USD",
        "toCurrency": "EUR",
        "dealAmount": 1000.50,
        "dealTimestamp": "2024-02-17T10:30:00"
    }')
if [[ "$RESPONSE" == *"required"* ]]; then
    print_success "Missing field correctly rejected"
else
    print_error "Missing field not caught"
fi

# Test 3.2: Negative amount
print_info "Testing negative amount..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"NEGATIVE_$(date +%s)\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": -100,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }")
if [[ "$RESPONSE" == *"greater than 0"* ]]; then
    print_success "Negative amount correctly rejected"
else
    print_error "Negative amount not caught"
fi

# Test 3.3: Invalid currency
print_info "Testing invalid currency (USDOLLAR)..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"INVALID_CURR_$(date +%s)\",
        \"fromCurrency\": \"USDOLLAR\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 1000.50,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }")
if [[ "$RESPONSE" == *"currency"* ]]; then
    print_success "Invalid currency correctly rejected"
else
    print_error "Invalid currency not caught"
fi

# Test 3.4: Invalid timestamp
print_info "Testing invalid timestamp format..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"INVALID_DATE_$(date +%s)\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 1000.50,
        \"dealTimestamp\": \"16-02-2024\"
    }")
if [[ "$RESPONSE" == *"timestamp"* ]]; then
    print_success "Invalid timestamp correctly rejected"
else
    print_error "Invalid timestamp not caught"
fi

# =============================================
# 4. TEST DUPLICATE PREVENTION
# =============================================
print_header "🔄 TESTING DUPLICATE PREVENTION"

DUPLICATE_ID="DUPLICATE_$(date +%s)"

# First request - should succeed
print_info "Creating first deal with ID: $DUPLICATE_ID"
RESPONSE1=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"$DUPLICATE_ID\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 1000.50,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }")

if [[ "$RESPONSE1" == *"$DUPLICATE_ID"* ]]; then
    print_success "First deal created"
else
    print_error "First deal failed"
fi

# Second request with same ID - should fail with 409
print_info "Attempting duplicate with same ID..."
RESPONSE2=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"$DUPLICATE_ID\",
        \"fromCurrency\": \"GBP\",
        \"toCurrency\": \"JPY\",
        \"dealAmount\": 2000.75,
        \"dealTimestamp\": \"2024-02-17T15:30:00\"
    }")

HTTP_CODE=$(echo "$RESPONSE2" | tail -n1)
BODY=$(echo "$RESPONSE2" | sed '$d')

if [ "$HTTP_CODE" -eq 409 ]; then
    print_success "Duplicate correctly rejected with 409"
elif [ "$HTTP_CODE" -eq 500 ]; then
    print_error "Got 500 instead of 409 - check error handling"
else
    print_error "Expected 409, got $HTTP_CODE"
fi

# =============================================
# 5. TEST DATABASE CONNECTION
# =============================================
print_header "🗄️  DATABASE VERIFICATION"

# Check if we can query the database
if docker ps | grep -q fx-deals-api-db-1; then
    print_success "Database container is running"
    
    # Count deals in database
    DEAL_COUNT=$(docker exec -it fx-deals-api-db-1 psql -U fxuser -d fxdb -t -c "SELECT COUNT(*) FROM deals;" 2>/dev/null | tr -d ' ' || echo "0")
    print_info "Total deals in database: $DEAL_COUNT"
else
    print_error "Database container not running"
fi

# =============================================
# 6. PERFORMANCE TEST (Concurrent)
# =============================================
print_header "⚡ PERFORMANCE TEST (5 concurrent requests)"

START_TIME=$(date +%s%N)

# Launch 5 concurrent requests
for i in {1..5}; do
    PERF_ID="PERF_$(date +%s)_$i"
    curl -s -X POST "$BASE_URL" \
        -H "Content-Type: application/json" \
        -d "{
            \"dealUniqueId\": \"$PERF_ID\",
            \"fromCurrency\": \"USD\",
            \"toCurrency\": \"EUR\",
            \"dealAmount\": 100$i,
            \"dealTimestamp\": \"2024-02-17T10:30:00\"
        }" > /dev/null &
done

# Wait for all to complete
wait

END_TIME=$(date +%s%N)
DURATION=$((($END_TIME - $START_TIME)/1000000))

if [ $DURATION -lt 2000 ]; then
    print_success "All 5 concurrent requests completed in ${DURATION}ms"
else
    print_info "All 5 concurrent requests completed in ${DURATION}ms"
fi

# =============================================
# 7. TEST EDGE CASES
# =============================================
print_header "🔧 EDGE CASE TESTS"

# Test minimum amount (0.01)
print_info "Testing minimum amount (0.01)..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"MIN_AMOUNT_$(date +%s)\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 0.01,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }")
if [[ "$RESPONSE" == *"0.01"* ]]; then
    print_success "Minimum amount accepted"
else
    print_error "Minimum amount failed"
fi

# Test large amount
print_info "Testing large amount (999999.99)..."
RESPONSE=$(curl -s -X POST "$BASE_URL" \
    -H "Content-Type: application/json" \
    -d "{
        \"dealUniqueId\": \"MAX_AMOUNT_$(date +%s)\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 999999.99,
        \"dealTimestamp\": \"2024-02-17T10:30:00\"
    }")
if [[ "$RESPONSE" == *"999999.99"* ]]; then
    print_success "Large amount accepted"
else
    print_error "Large amount failed"
fi

# =============================================
# SUMMARY
# =============================================
print_header "📊 TEST SUMMARY"

echo -e "${GREEN}✅ All tests completed!${NC}"
echo -e "${YELLOW}ℹ️  Check database for verification:${NC}"
echo "   docker exec -it fx-deals-api-db-1 psql -U fxuser -d fxdb -c 'SELECT COUNT(*) FROM deals;'"
echo ""
echo -e "${BLUE}To view application logs:${NC}"
echo "   docker logs fx-deals-api-app-1 --tail 50"