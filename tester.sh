#!/bin/bash

# =============================================
# JACOCO COVERAGE TEST SUITE
# Tests all parts of JaCoCo coverage
# =============================================

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Initialize counters
PASS=0
FAIL=0
TOTAL=0

# =============================================
# Helper Functions (MUST be defined first!)
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
# 1. CHECK JACOCO IS CONFIGURED IN POM.XML
# =============================================
print_section "1. CHECKING JACOCO CONFIGURATION"

if grep -q "jacoco-maven-plugin" pom.xml; then
    print_result 0 "JaCoCo plugin configured in pom.xml"
else
    print_result 1 "JaCoCo plugin NOT found in pom.xml"
fi

if grep -q "<minimum>1.00</minimum>" pom.xml; then
    print_result 0 "100% coverage target configured"
else
    print_result 1 "100% coverage target NOT configured"
fi

# =============================================
# 2. RUN TESTS WITH COVERAGE
# =============================================
print_section "2. RUNNING TESTS WITH COVERAGE"

echo "Running mvn clean test..."
docker-compose run --rm app mvn clean test > test-output.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "Tests executed successfully"
else
    print_result 1 "Tests failed to execute"
    cat test-output.log | tail -20
fi

# =============================================
# 3. CHECK JACOCO EXECUTION DATA FILE
# =============================================
print_section "3. CHECKING JACOCO EXECUTION DATA"

if grep -q "Loading execution data file" test-output.log; then
    print_result 0 "JaCoCo execution data file loaded"
else
    print_result 1 "JaCoCo execution data file NOT found"
fi

# =============================================
# 4. GENERATE COVERAGE REPORT
# =============================================
print_section "4. GENERATING COVERAGE REPORT"

docker-compose run --rm app mvn jacoco:report > report-output.log 2>&1

if [ $? -eq 0 ]; then
    print_result 0 "Coverage report generated"
else
    print_result 1 "Coverage report generation failed"
fi

# =============================================
# 5. CHECK REPORT FILES
# =============================================
print_section "5. CHECKING REPORT FILES"

# Create reports directory
mkdir -p target/coverage

# Try to copy report from container
if docker cp $(docker-compose ps -q app):/app/target/site/jacoco ./target/coverage 2>/dev/null; then
    if [ -f "./target/coverage/jacoco/index.html" ]; then
        print_result 0 "HTML coverage report found"
    else
        print_result 1 "HTML coverage report NOT found"
    fi
    
    if [ -f "./target/coverage/jacoco/jacoco.xml" ]; then
        print_result 0 "XML coverage report found"
    else
        print_result 1 "XML coverage report NOT found"
    fi
else
    # Check if report exists locally
    if [ -f "./target/site/jacoco/index.html" ]; then
        print_result 0 "HTML coverage report found locally"
        cp -r ./target/site/jacoco ./target/coverage/
    else
        print_result 1 "HTML coverage report NOT found anywhere"
    fi
    
    if [ -f "./target/site/jacoco/jacoco.xml" ]; then
        print_result 0 "XML coverage report found locally"
    else
        print_result 1 "XML coverage report NOT found anywhere"
    fi
fi

# =============================================
# 6. CHECK COVERAGE PERCENTAGES
# =============================================
print_section "6. CHECKING COVERAGE PERCENTAGES"

if [ -f "./target/coverage/jacoco/jacoco.xml" ] || [ -f "./target/site/jacoco/jacoco.xml" ]; then
    print_result 0 "Coverage data available"
    
    # Extract and display coverage info
    REPORT_FILE="./target/coverage/jacoco/jacoco.xml"
    [ ! -f "$REPORT_FILE" ] && REPORT_FILE="./target/site/jacoco/jacoco.xml"
    
    if [ -f "$REPORT_FILE" ]; then
        INSTRUCTION_COVERED=$(grep -o 'instruction covered="[0-9]*"' "$REPORT_FILE" | head -1 | grep -o '[0-9]*')
        INSTRUCTION_MISSED=$(grep -o 'instruction missed="[0-9]*"' "$REPORT_FILE" | head -1 | grep -o '[0-9]*')
        echo -e "  ${YELLOW}Coverage metrics found${NC}"
    fi
else
    print_result 1 "Cannot check coverage - report missing"
fi

# =============================================
# 7. VERIFY 100% COVERAGE TARGET
# =============================================
print_section "7. VERIFYING 100% COVERAGE TARGET"

docker-compose run --rm app mvn clean verify > verify-output.log 2>&1
VERIFY_EXIT=$?

if [ $VERIFY_EXIT -eq 0 ]; then
    print_result 0 "Coverage check passed (meets 100% target)"
else
    if grep -q "Coverage checks have failed" verify-output.log; then
        print_result 1 "Coverage check FAILED - below 100%"
        echo -e "${RED}  ⚠️  Some packages have less than 100% coverage${NC}"
    else
        print_result 1 "Coverage check failed for other reasons"
    fi
fi

# =============================================
# 8. CHECK EXCLUDED CLASSES
# =============================================
print_section "8. CHECKING EXCLUDED CLASSES"

EXCLUSIONS=("FxDealsApplication" "dto" "config" "aspect" "exception")
EXCLUSIONS_FOUND=0

for EXCLUSION in "${EXCLUSIONS[@]}"; do
    if grep -q "<exclude>.*$EXCLUSION.*</exclude>" pom.xml; then
        EXCLUSIONS_FOUND=$((EXCLUSIONS_FOUND+1))
    fi
done

if [ $EXCLUSIONS_FOUND -eq 5 ]; then
    print_result 0 "All excluded classes configured properly"
else
    print_result 1 "Some exclusions missing (found $EXCLUSIONS_FOUND/5)"
fi

# =============================================
# 9. CHECK MAKEFILE COVERAGE COMMANDS
# =============================================
print_section "9. CHECKING MAKEFILE COVERAGE COMMANDS"

if [ -f "Makefile" ]; then
    if grep -q "^coverage:" Makefile; then
        print_result 0 "Makefile has 'coverage' command"
    else
        print_result 1 "Makefile missing 'coverage' command"
    fi
    
    if grep -q "^coverage-report:" Makefile; then
        print_result 0 "Makefile has 'coverage-report' command"
    else
        print_result 1 "Makefile missing 'coverage-report' command"
    fi
    
    if grep -q "^coverage-check:" Makefile; then
        print_result 0 "Makefile has 'coverage-check' command"
    else
        print_result 1 "Makefile missing 'coverage-check' command"
    fi
else
    print_result 1 "Makefile not found"
fi

# =============================================
# 10. CHECK README DOCUMENTATION
# =============================================
print_section "10. CHECKING README DOCUMENTATION"

if [ -f "README.md" ]; then
    if grep -q "JaCoCo" README.md; then
        print_result 0 "README mentions JaCoCo"
    else
        print_result 1 "README missing JaCoCo documentation"
    fi
    
    if grep -q "100% coverage" README.md; then
        print_result 0 "README mentions 100% coverage target"
    else
        print_result 1 "README missing 100% coverage target"
    fi
    
    if grep -q "excluded classes" README.md; then
        print_result 0 "README explains excluded classes"
    else
        print_result 1 "README missing exclusions explanation"
    fi
else
    print_result 1 "README.md not found"
fi

# =============================================
# 11. COVERAGE REPORT PREVIEW
# =============================================
print_section "11. COVERAGE REPORT PREVIEW"

if [ -f "./target/coverage/jacoco/index.html" ]; then
    echo -e "${GREEN}  📊 Coverage report available at:${NC}"
    echo -e "     ./target/coverage/jacoco/index.html"
    echo -e "\n${YELLOW}  To view in browser:${NC}"
    echo "     open ./target/coverage/jacoco/index.html"
elif [ -f "./target/site/jacoco/index.html" ]; then
    echo -e "${GREEN}  📊 Coverage report available at:${NC}"
    echo -e "     ./target/site/jacoco/index.html"
else
    echo -e "${YELLOW}  ⚠️  Report not available - run 'make coverage' first${NC}"
fi

# =============================================
# SUMMARY
# =============================================
print_header "📊 JACOCO COVERAGE TEST SUMMARY"

echo -e "\n${GREEN}✅ PASSED: $PASS${NC}"
echo -e "${RED}❌ FAILED: $FAIL${NC}"
echo -e "${BLUE}📋 TOTAL:  $TOTAL${NC}"

if [ $TOTAL -gt 0 ]; then
    PERCENT=$((PASS * 100 / TOTAL))
    echo -e "${YELLOW}📈 SUCCESS RATE: ${PERCENT}%${NC}"
fi

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL JACOCO TESTS PASSED! Coverage is properly configured!${NC}"
elif [ $FAIL -le 2 ]; then
    echo -e "\n${YELLOW}⚠️  Minor issues found - check the failures above${NC}"
else
    echo -e "\n${RED}❌ Multiple failures - JaCoCo configuration needs work${NC}"
fi

# Cleanup
rm -f test-output.log report-output.log verify-output.log 2>/dev/null