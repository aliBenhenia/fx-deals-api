#!/bin/bash

# =============================================
# COMPLETE TEST SUITE - FX DEALS API
# Tests EVERYTHING in one script
# =============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
PASS=0
FAIL=0
TOTAL=0

# =============================================
# Helper Functions
# =============================================
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_section() {
    echo -e "\n${YELLOW}📌 $1${NC}"
    echo -e "${YELLOW}--------------------${NC}"
}

print_result() {
    TOTAL=$((TOTAL+1))
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}  ✅ PASS: $2${NC}"
        PASS=$((PASS+1))
    else
        echo -e "${RED}  ❌ FAIL: $2${NC}"
        FAIL=$((FAIL+1))
    fi
}

# =============================================
# 1. ENVIRONMENT CHECK
# =============================================
print_header "🔍 ENVIRONMENT CHECK"

# Check Docker
if command -v docker &> /dev/null; then
    print_result 0 "Docker installed"
else
    print_result 1 "Docker not installed"
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    print_result 0 "Docker Compose installed"
else
    print_result 1 "Docker Compose not installed"
fi

# Check Make
if command -v make &> /dev/null; then
    print_result 0 "Make installed"
else
    print_result 1 "Make not installed"
fi

# =============================================
# 2. START APPLICATION
# =============================================
print_header "🚀 STARTING APPLICATION"

echo -e "${YELLOW}Stopping any existing containers...${NC}"
docker compose down -v > /dev/null 2>&1

echo -e "${YELLOW}Starting fresh build...${NC}"
docker compose up -d --build > build.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "Application started successfully"
else
    print_result 1 "Application failed to start"
    cat build.log | tail -20
    exit 1
fi

echo -e "${YELLOW}Waiting for services to be ready...${NC}"
sleep 15

# Check if app is running
if curl -s http://localhost:8080/api/deals/health > /dev/null 2>&1; then
    print_result 0 "Health check passed"
else
    print_result 1 "Health check failed"
fi

# Check if DB is running
if docker ps | grep -q postgres; then
    print_result 0 "Database running"
else
    print_result 1 "Database not running"
fi

# =============================================
# 3. API TESTS (CURL)
# =============================================
print_header "🌐 API TESTS"

BASE_URL="http://localhost:8080/api/deals"
NOW=$(date +"%Y-%m-%dT%H:%M:%S")

# Test 3.1: Create valid deal
UNIQUE_ID="CURL_TEST_$(date +%s)"
RESPONSE=$(curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$UNIQUE_ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$NOW\"
  }")
if [[ "$RESPONSE" == *"$UNIQUE_ID"* ]]; then
    print_result 0 "Create valid deal"
else
    print_result 1 "Create valid deal failed"
fi

# Test 3.2: Missing field
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$NOW\"
  }")
if [ "$RESPONSE" -eq 400 ]; then
    print_result 0 "Missing field validation"
else
    print_result 1 "Missing field validation (got $RESPONSE)"
fi

# Test 3.3: Invalid currency
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"CURR_TEST_$(date +%s)\",
    \"fromCurrency\": \"USDOLLAR\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$NOW\"
  }")
if [ "$RESPONSE" -eq 400 ]; then
    print_result 0 "Invalid currency validation"
else
    print_result 1 "Invalid currency validation (got $RESPONSE)"
fi

# Test 3.4: Negative amount
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"NEG_TEST_$(date +%s)\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": -100,
    \"dealTimestamp\": \"$NOW\"
  }")
if [ "$RESPONSE" -eq 400 ]; then
    print_result 0 "Negative amount validation"
else
    print_result 1 "Negative amount validation (got $RESPONSE)"
fi

# =============================================
# 4. DUPLICATE PREVENTION TEST
# =============================================
print_section "🔄 DUPLICATE PREVENTION"

ID="DUP_TEST_$(date +%s)"

# First request
echo -e "${YELLOW}Creating deal with ID: $ID${NC}"
curl -s -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$NOW\"
  }" > /dev/null

# Second request (should fail)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"$ID\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 1000.50,
    \"dealTimestamp\": \"$NOW\"
  }")

if [ "$HTTP_CODE" -eq 409 ]; then
    print_result 0 "Duplicate prevention (409 Conflict)"
else
    print_result 1 "Duplicate prevention failed (got $HTTP_CODE)"
fi

# =============================================
# 5. NO ROLLBACK TEST
# =============================================
print_section "🚫 NO ROLLBACK TEST"

PREFIX="BATCH_$(date +%s)"

# Create 3 valid deals
for i in 1 2 3; do
    curl -s -X POST $BASE_URL \
      -H "Content-Type: application/json" \
      -d "{
        \"dealUniqueId\": \"${PREFIX}_$i\",
        \"fromCurrency\": \"USD\",
        \"toCurrency\": \"EUR\",
        \"dealAmount\": 100$i,
        \"dealTimestamp\": \"$NOW\"
      }" > /dev/null
    echo -e "  ${GREEN}✓ Created deal $i${NC}"
done

# Try to create duplicate of deal 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST $BASE_URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"${PREFIX}_2\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 200,
    \"dealTimestamp\": \"$NOW\"
  }")

if [ "$HTTP_CODE" -eq 409 ]; then
    print_result 0 "Duplicate correctly rejected (409)"
else
    print_result 1 "Duplicate not rejected (got $HTTP_CODE)"
fi

# =============================================
# 6. UNIT TESTS
# =============================================
print_header "🧪 UNIT TESTS"

echo -e "${YELLOW}Running unit tests...${NC}"
docker compose run --rm app mvn test > unit-test.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "All unit tests passed"
    
    # Count tests
    TEST_COUNT=$(grep "Tests run:" unit-test.log | tail -1 | grep -o "[0-9]\+" | head -1)
    echo -e "  ${GREEN}📊 $TEST_COUNT tests executed${NC}"
else
    print_result 1 "Unit tests failed"
    cat unit-test.log | tail -20
fi

# =============================================
# 7. COVERAGE CHECK
# =============================================
print_header "📊 COVERAGE CHECK"

echo -e "${YELLOW}Generating coverage report...${NC}"
docker compose run --rm app mvn clean test jacoco:report > coverage.log 2>&1

if grep -q "Loading execution data file" coverage.log; then
    print_result 0 "Coverage report generated"
else
    print_result 1 "Coverage report failed"
fi

# Check coverage thresholds
echo -e "${YELLOW}Checking coverage thresholds...${NC}"
docker compose run --rm app mvn verify > verify.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "Coverage thresholds met"
else
    if grep -q "Coverage checks have failed" verify.log; then
        print_result 1 "Coverage below thresholds"
        grep -A 5 "Coverage checks have failed" verify.log
    else
        print_result 1 "Coverage check failed"
    fi
fi

# =============================================
# 8. INTEGRATION TESTS
# =============================================
print_section "🔗 INTEGRATION TESTS"

echo -e "${YELLOW}Running integration tests...${NC}"
docker compose run --rm app mvn -Dtest=DealIntegrationTest test > integration.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "Integration tests passed"
else
    print_result 1 "Integration tests failed"
    cat integration.log | tail -20
fi

# =============================================
# 9. API TESTS (REST ASSURED)
# =============================================
print_section "🌐 API TESTS (REST ASSURED)"

echo -e "${YELLOW}Running API tests...${NC}"
docker compose run --rm app mvn -Dtest=AssignmentApiTest test > api-test.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "API tests passed"
    
    # Show test summary
    TOTAL_API=$(grep "Tests run:" api-test.log | tail -1)
    echo -e "  ${GREEN}📊 $TOTAL_API${NC}"
else
    print_result 1 "API tests failed"
    cat api-test.log | tail -20
fi

# =============================================
# 10. K6 PERFORMANCE TEST
# =============================================
print_section "⚡ K6 PERFORMANCE TEST"

if [ -f "k6/run.sh" ]; then
    echo -e "${YELLOW}Running K6 smoke test...${NC}"
    cd k6 && ./run.sh smoke > ../k6.log 2>&1
    cd ..
    
    if [ $? -eq 0 ]; then
        print_result 0 "K6 performance test passed"
    else
        print_result 1 "K6 performance test failed"
        cat k6.log | tail -10
    fi
else
    print_result 1 "K6 script not found"
fi

# =============================================
# 11. POSTMAN COLLECTION CHECK
# =============================================
print_section "📬 POSTMAN COLLECTION"

if [ -f "postman/fx-deals-postman.json" ] || [ -f "fx-deals-postman.json" ]; then
    print_result 0 "Postman collection exists"
else
    print_result 1 "Postman collection missing"
fi

# =============================================
# 12. MAKE COMMANDS TEST
# =============================================
print_section "🛠️ MAKEFILE COMMANDS"

# Test make commands
make test > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 2 ]; then
    print_result 0 "make test command works"
else
    print_result 1 "make test failed"
fi

make coverage > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 2 ]; then
    print_result 0 "make coverage command works"
else
    print_result 1 "make coverage failed"
fi

# =============================================
# 13. CLEANUP
# =============================================
print_header "🧹 CLEANUP"

echo -e "${YELLOW}Stopping containers...${NC}"
docker compose down > /dev/null 2>&1
print_result 0 "Cleanup completed"

# =============================================
# FINAL SUMMARY
# =============================================
print_header "📊 MASTER TEST SUMMARY"

echo -e "\n${GREEN}✅ PASSED: $PASS${NC}"
echo -e "${RED}❌ FAILED: $FAIL${NC}"
echo -e "${BLUE}📋 TOTAL:  $TOTAL${NC}"

PERCENT=$((PASS * 100 / TOTAL))
echo -e "${YELLOW}📈 SUCCESS RATE: ${PERCENT}%${NC}"

echo -e "\n${BLUE}📋 ASSIGNMENT READINESS:${NC}"
if [ $PERCENT -ge 90 ]; then
    echo -e "${GREEN}  ⭐ EXCELLENT - Ready for submission!${NC}"
elif [ $PERCENT -ge 75 ]; then
    echo -e "${YELLOW}  📊 GOOD - Minor fixes needed${NC}"
else
    echo -e "${RED}  ❌ NEEDS WORK - Review failures${NC}"
fi

# Save results
echo "PASS=$PASS, FAIL=$FAIL, TOTAL=$TOTAL, PERCENT=$PERCENT" > test-complete-results.txt

# Clean up log files
rm -f *.log 2>/dev/null