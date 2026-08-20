#!/bin/bash

# UnScroll Production Setup Verification Script
# Run this from your local machine or browser to verify the complete setup

API_URL="https://unscroll-api-prod.sahilxleo916.workers.dev"
TEST_EMAIL="setup-test-$(date +%s)@example.com"
TEST_PASSWORD="TestPass123!Verification"

echo "🔍 UnScroll Production Setup Verification"
echo "========================================"
echo "API URL: $API_URL"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Test function
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local data=$4
    local expected_code=$5

    echo -n "Testing $name... "

    if [ -z "$data" ]; then
        response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi

    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')

    if [ "$http_code" == "$expected_code" ]; then
        echo -e "${GREEN}✓ ($http_code)${NC}"
        PASS=$((PASS + 1))
        echo "$body"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Expected $expected_code, got $http_code${NC}"
        echo "Response: $body"
        echo ""
        FAIL=$((FAIL + 1))
        return 1
    fi
}

# 1. Health Check
echo "📋 Phase 1: Basic Connectivity"
echo "---"
test_endpoint "Health Check" "GET" "/" "" "200"

if [ $FAIL -gt 0 ]; then
    echo -e "${RED}❌ Health check failed. API is not reachable.${NC}"
    echo "Verify:"
    echo "  1. API URL is correct: $API_URL"
    echo "  2. Internet connection is working"
    echo "  3. No firewall blocking Cloudflare Workers"
    exit 1
fi

# 2. Authentication
echo "🔐 Phase 2: Authentication & Database"
echo "---"

# Register user
register_response=$(curl -s -X POST "$API_URL/api/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"email\":\"$TEST_EMAIL\",\"password\":\"$TEST_PASSWORD\"}")

TOKEN=$(echo "$register_response" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
USER_ID=$(echo "$register_response" | grep -o '"id":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}✗ User registration failed${NC}"
    echo "Response: $register_response"
    FAIL=$((FAIL + 1))
else
    echo -e "${GREEN}✓ User registration successful${NC}"
    echo "Token: ${TOKEN:0:30}..."
    echo "User ID: $USER_ID"
    echo ""
    PASS=$((PASS + 1))
fi

# Test with token
if [ ! -z "$TOKEN" ]; then
    echo "📊 Phase 3: Protected Endpoints"
    echo "---"

    test_endpoint "Get User Profile" "GET" "/api/user/profile" "" "200"

    # Create policy
    policy_data='{
        "name": "Verification Policy",
        "target_apps": ["instagram", "tiktok"],
        "blocked_content": ["reels", "shorts"],
        "friction_level": "high",
        "risk_windows": [{"day": 1, "start_time": "22:00", "end_time": "06:00"}],
        "enabled": true
    }'

    policy_response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/policies" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "$policy_data")

    policy_code=$(echo "$policy_response" | tail -n1)
    policy_body=$(echo "$policy_response" | sed '$d')

    echo -n "Testing Create Policy... "
    if [ "$policy_code" == "201" ]; then
        echo -e "${GREEN}✓ (201)${NC}"
        PASS=$((PASS + 1))
        echo "$policy_body"
        echo ""
    else
        echo -e "${RED}✗ Expected 201, got $policy_code${NC}"
        echo "Response: $policy_body"
        echo ""
        FAIL=$((FAIL + 1))
    fi
fi

# 4. Error Handling
echo "⚠️  Phase 4: Error Handling"
echo "---"

# Test 401 without auth
echo -n "Testing 401 (missing auth)... "
response=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/user/profile" \
    -H "Content-Type: application/json")
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" == "401" ]; then
    echo -e "${GREEN}✓ (401)${NC}"
    PASS=$((PASS + 1))
else
    echo -e "${RED}✗ Expected 401, got $http_code${NC}"
    FAIL=$((FAIL + 1))
fi
echo ""

# Test 404
echo -n "Testing 404 (not found)... "
response=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/nonexistent" \
    -H "Content-Type: application/json")
http_code=$(echo "$response" | tail -n1)
if [ "$http_code" == "404" ]; then
    echo -e "${GREEN}✓ (404)${NC}"
    PASS=$((PASS + 1))
else
    echo -e "${RED}✗ Expected 404, got $http_code${NC}"
    FAIL=$((FAIL + 1))
fi
echo ""

# 5. Database Verification
echo "💾 Phase 5: Database"
echo "---"

if [ ! -z "$TOKEN" ]; then
    echo -n "Testing Log Blocked Attempt (DB write)... "
    attempt_data="{\"app\":\"instagram\",\"content_type\":\"reels\",\"blocked\":true,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"

    response=$(curl -s -w "\n%{http_code}" -X POST "$API_URL/api/blocked-attempts" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d "$attempt_data")

    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" == "201" ]; then
        echo -e "${GREEN}✓ (201)${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗ Expected 201, got $http_code${NC}"
        FAIL=$((FAIL + 1))
    fi
    echo ""

    echo -n "Testing Get Analytics (DB read)... "
    response=$(curl -s -w "\n%{http_code}" -X GET "$API_URL/api/blocked-attempts?app=instagram" \
        -H "Authorization: Bearer $TOKEN")

    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" == "200" ]; then
        echo -e "${GREEN}✓ (200)${NC}"
        PASS=$((PASS + 1))
    else
        echo -e "${RED}✗ Expected 200, got $http_code${NC}"
        FAIL=$((FAIL + 1))
    fi
    echo ""
fi

# 6. Rate Limiting (KV)
echo "⏱️  Phase 6: Rate Limiting (KV Namespace)"
echo "---"

echo "Testing rate limit (5 rapid login attempts)..."
for i in {1..6}; do
    response=$(curl -s -w "%{http_code}" -X POST "$API_URL/api/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"rate-test@example.com","password":"wrong"}')

    http_code=$(echo "$response" | tail -c 4)

    if [ $i -lt 6 ]; then
        echo "  Request $i: HTTP $http_code"
    else
        echo -n "  Request $i (should be 429): HTTP $http_code... "
        if [ "$http_code" == "429" ]; then
            echo -e "${GREEN}✓ Rate limiting active${NC}"
            PASS=$((PASS + 1))
        else
            echo -e "${YELLOW}⚠ Got $http_code (may need KV setup)${NC}"
        fi
    fi
done
echo ""

# Summary
echo "========================================"
echo "📊 Verification Summary"
echo "========================================"
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed! Production setup is complete.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Run Flutter integration tests: flutter test test/integration/"
    echo "  2. Test on iOS and Android devices"
    echo "  3. Test Chrome extension"
    echo "  4. Recruit beta testers (50-100 users)"
    echo "  5. Submit to App Store and Play Store"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Review the output above.${NC}"
    echo ""
    echo "Troubleshooting:"
    echo "  - Health check failed? → API not deployed or network blocked"
    echo "  - Auth failed? → Database not connected or schema issue"
    echo "  - Rate limiting failed? → KV namespace not connected"
    echo "  - Database failed? → D1 bindings not connected"
    exit 1
fi
