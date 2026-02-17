#!/bin/bash

echo "🚀 TESTING NO ROLLBACK BEHAVIOR"
echo "================================"

URL="http://localhost:8080/api/deals"
PREFIX="BATCH_$(date +%s)"
NOW=$(date +"%Y-%m-%dT%H:%M:%S")

echo -e "\n📌 Creating 3 valid deals..."

# Deal 1 - Valid
curl -s -X POST $URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"${PREFIX}_1\",
    \"fromCurrency\": \"USD\",
    \"toCurrency\": \"EUR\",
    \"dealAmount\": 100.00,
    \"dealTimestamp\": \"$NOW\"
  }" > /dev/null
echo "  ✅ Deal 1 created"

# Deal 2 - Valid
curl -s -X POST $URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"${PREFIX}_2\",
    \"fromCurrency\": \"GBP\",
    \"toCurrency\": \"JPY\",
    \"dealAmount\": 200.00,
    \"dealTimestamp\": \"$NOW\"
  }" > /dev/null
echo "  ✅ Deal 2 created"

# Try duplicate of Deal 2 (should fail)
echo -e "\n📌 Trying duplicate of Deal 2 (should fail with 409)"
curl -s -w "HTTP Status: %{http_code}\n" -X POST $URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"${PREFIX}_2\",
    \"fromCurrency\": \"GBP\",
    \"toCurrency\": \"JPY\",
    \"dealAmount\": 200.00,
    \"dealTimestamp\": \"$NOW\"
  }"

# Deal 3 - Valid
echo -e "\n📌 Creating Deal 3"
curl -s -X POST $URL \
  -H "Content-Type: application/json" \
  -d "{
    \"dealUniqueId\": \"${PREFIX}_3\",
    \"fromCurrency\": \"EUR\",
    \"toCurrency\": \"USD\",
    \"dealAmount\": 300.00,
    \"dealTimestamp\": \"$NOW\"
  }" > /dev/null
echo "  ✅ Deal 3 created"

# Check database
echo -e "\n📊 Checking database for deals with prefix: $PREFIX"
docker exec fx-deals-api-db-1 psql -U fxuser -d fxdb -c "SELECT deal_unique_id FROM deals WHERE deal_unique_id LIKE '${PREFIX}%' ORDER BY deal_unique_id;"