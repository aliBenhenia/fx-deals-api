#!/bin/bash

echo "Running K6 performance test..."
echo "================================="


BASE_URL="http://localhost:8080"

docker run --rm -i \
  --network="host" \
  grafana/k6 run - <<EOF
import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '30s', target: 10 },
    { duration: '1m', target: 10 },
    { duration: '30s', target: 0 },
  ],
};

export default function() {
  const res = http.post('${BASE_URL}/api/deals', JSON.stringify({
    dealUniqueId: \`K6_\${Date.now()}_\${__VU}\`,  // JS-only variables
    fromCurrency: 'USD',
    toCurrency: 'EUR',
    dealAmount: 1000.50,
    dealTimestamp: new Date().toISOString()
  }), {
    headers: { 'Content-Type': 'application/json' },
  });

  check(res, { 'status is 201': (r) => r.status === 201 });
  sleep(1);
}
EOF

echo "✅ K6 test complete!"
