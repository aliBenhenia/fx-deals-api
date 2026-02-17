#!/bin/bash

# =============================================
# JACOCO COVERAGE ANALYZER
# Tells you exactly which lines are missing
# =============================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📊 JACOCO COVERAGE ANALYZER${NC}"
echo -e "${BLUE}========================================${NC}"

# Check if we're in the right directory
if [ ! -f "index.html" ]; then
    echo -e "${RED}❌ Not in a JaCoCo report directory!${NC}"
    echo -e "${YELLOW}Please run this script from the jacoco-report folder${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found JaCoCo report${NC}\n"

# =============================================
# Check each package
# =============================================
echo -e "${YELLOW}📦 Package Coverage Summary:${NC}"
echo "------------------------"

for package in com.bloomberg.fxdeals.controller com.bloomberg.fxdeals.service com.bloomberg.fxdeals.validation com.bloomberg.fxdeals.model; do
    if [ -d "$package" ]; then
        echo -e "${BLUE}$package${NC}"
        
        # Extract coverage percentage from the package's index.html
        if [ -f "$package/index.html" ]; then
            COVERAGE=$(grep -o "Total.*instruction.*[0-9]*%" "$package/index.html" | head -1)
            if [ ! -z "$COVERAGE" ]; then
                echo -e "  ${GREEN}$COVERAGE${NC}"
            else
                echo -e "  ${YELLOW}Coverage data not found${NC}"
            fi
        fi
    fi
done

echo ""

# =============================================
# Deep dive into DealValidator (the problematic one)
# =============================================
if [ -d "com.bloomberg.fxdeals.validation" ]; then
    echo -e "${YELLOW}🔍 Deep dive into DealValidator.java${NC}"
    echo "----------------------------------------"
    
    VALIDATOR_HTML="com.bloomberg.fxdeals.validation/DealValidator.java.html"
    
    if [ -f "$VALIDATOR_HTML" ]; then
        # Count total lines
        TOTAL_LINES=$(grep -c '<tr>' "$VALIDATOR_HTML" || true)
        
        # Count covered lines (green)
        COVERED_LINES=$(grep -c 'class="fc"' "$VALIDATOR_HTML" || true)
        
        # Count partially covered (yellow)
        PARTIAL_LINES=$(grep -c 'class="pc"' "$VALIDATOR_HTML" || true)
        
        # Count not covered (red)
        NOT_COVERED=$(grep -c 'class="nc"' "$VALIDATOR_HTML" || true)
        
        echo -e "  ${GREEN}Covered lines: $COVERED_LINES${NC}"
        echo -e "  ${YELLOW}Partially covered: $PARTIAL_LINES${NC}"
        echo -e "  ${RED}Not covered: $NOT_COVERED${NC}"
        echo -e "  ${BLUE}Total lines: $TOTAL_LINES${NC}"
        
        echo ""
        echo -e "${YELLOW}📋 Lines not covered (red):${NC}"
        
        # Extract line numbers that are not covered
        grep -n 'class="nc"' "$VALIDATOR_HTML" | while read -r line; do
            LINE_NUM=$(echo "$line" | cut -d: -f1)
            # Get the line content
            LINE_CONTENT=$(sed -n "${LINE_NUM}p" "$VALIDATOR_HTML" | grep -o '>.*<' | sed 's/[><]//g' | head -1)
            echo -e "  ${RED}Line ~$LINE_NUM:${NC} $LINE_CONTENT"
        done
    else
        echo -e "${RED}DealValidator.java.html not found${NC}"
    fi
fi

echo ""
echo -e "${YELLOW}📊 CSV Summary (if you want detailed numbers):${NC}"
if [ -f "jacoco.csv" ]; then
    echo -e "  ${BLUE}Total classes: $(tail -n +2 jacoco.csv | wc -l)${NC}"
    echo -e "  ${GREEN}Coverage data available in jacoco.csv${NC}"
    echo -e "\n${YELLOW}To see full details:${NC}"
    echo "  column -s, -t < jacoco.csv | head -20"
else
    echo -e "${RED}jacoco.csv not found${NC}"
fi

echo ""
echo -e "${YELLOW}💡 Recommendations:${NC}"
echo "  Based on your previous 92% coverage, the missing lines are likely:"
echo "  1. The branch conditions in isValidCurrencyCode()"
echo "  2. The throw statements for invalid currencies"
echo "  3. The timestamp validation logic"
echo ""
echo -e "${BLUE}Add these tests to DealValidatorTest.java:${NC}"
echo "  @Test"
echo "  void validate_ShouldThrow_WhenCurrencyHasNumbers() {"
echo "      validRequest.setFromCurrency(\"US1\");"
echo "      assertThatThrownBy(() -> DealValidator.validate(validRequest))"
echo "          .isInstanceOf(IllegalArgumentException.class);"
echo "  }"