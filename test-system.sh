#!/usr/bin/env bash
# Bazzite Car Edge - Automated Test Script
# Tests wizard and system functionality

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0
FAILURES=()

# Print functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"
}

print_test() {
    echo -e "${YELLOW}→${NC} Testing: $1"
}

print_pass() {
    echo -e "${GREEN}✓${NC} PASS: $1"
    ((TESTS_PASSED++))
}

print_fail() {
    echo -e "${RED}✗${NC} FAIL: $1"
    ((TESTS_FAILED++))
    FAILURES+=("$1")
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Test function wrapper
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_RUN++))
    print_test "$test_name"
    
    if eval "$test_command"; then
        print_pass "$test_name"
        return 0
    else
        print_fail "$test_name"
        return 1
    fi
}

# Main test execution
main() {
    print_header "Bazzite Car Edge - Automated Tests"
    
    echo "Test Run: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Environment: $(uname -a)"
    echo ""
    
    #
    # Level 1: Smoke Tests
    #
    print_header "Level 1: Smoke Tests"
    
    run_test "Command exists: car-edge-setup-wizard" \
        "command -v car-edge-setup-wizard &> /dev/null"
    
    run_test "Command exists: car-edge-install-apps" \
        "command -v car-edge-install-apps &> /dev/null"
    
    run_test "Command exists: car-edge-backup" \
        "command -v car-edge-backup &> /dev/null"
    
    run_test "Command exists: car-edge-upgrade" \
        "command -v car-edge-upgrade &> /dev/null"
    
    run_test "Scripts are executable" \
        "[ -x /usr/bin/car-edge-setup-wizard ] && [ -x /usr/bin/car-edge-install-apps ]"
    
    run_test "Skel directory has autostart entry" \
        "[ -f /etc/skel/.config/autostart/car-edge-setup-wizard.desktop ]"
    
    run_test "Documentation exists" \
        "[ -f /usr/share/doc/bazzite-car-edge/README.txt ]"
    
    run_test "TLP config exists" \
        "[ -f /etc/tlp.d/90-car-edge.conf ]"
    
    run_test "RetroArch config exists" \
        "[ -f /var/config/retroarch/retroarch.cfg ]"
    
    run_test "Storage tmpfiles config exists" \
        "[ -f /etc/tmpfiles.d/bazzite-car-edge.conf ]"
    
    #
    # Level 2: Error Handling Tests (Simulated)
    #
    print_header "Level 2: Error Handling Tests"
    
    run_test "Wizard has error handling code" \
        "grep -q 'show_error' /usr/bin/car-edge-setup-wizard"
    
    run_test "Wizard has retry mechanism" \
        "grep -q 'retry_command' /usr/bin/car-edge-setup-wizard"
    
    run_test "Wizard has network check" \
        "grep -q 'check_network' /usr/bin/car-edge-setup-wizard"
    
    run_test "Wizard has disk space check" \
        "grep -q 'check_disk_space' /usr/bin/car-edge-setup-wizard"
    
    run_test "Wizard has logging" \
        "grep -q 'LOG_FILE' /usr/bin/car-edge-setup-wizard"
    
    #
    # Level 3: Integration Tests (Limited)
    #
    print_header "Level 3: Integration Tests (Limited)"
    
    run_test "System is rpm-ostree based" \
        "command -v rpm-ostree &> /dev/null"
    
    run_test "Flatpak is installed" \
        "command -v flatpak &> /dev/null"
    
    run_test "KDE Plasma is available" \
        "command -v kdialog &> /dev/null"
    
    run_test "Required tools: lsblk" \
        "command -v lsblk &> /dev/null"
    
    run_test "Required tools: parted" \
        "command -v parted &> /dev/null"
    
    run_test "Required tools: mkfs.ext4" \
        "command -v mkfs.ext4 &> /dev/null"
    
    run_test "Required tools: blkid" \
        "command -v blkid &> /dev/null"
    
    #
    # Level 4: Permission Checks
    #
    print_header "Level 4: Permission & Ownership Tests"
    
    run_test "User can read documentation" \
        "[ -r /usr/share/doc/bazzite-car-edge/README.txt ]"
    
    run_test "User can execute wizard" \
        "[ -x /usr/bin/car-edge-setup-wizard ]"
    
    run_test "TLP config is readable" \
        "[ -r /etc/tlp.d/90-car-edge.conf ]"
    
    #
    # Test Summary
    #
    print_header "Test Summary"
    
    echo "Tests Run:    $TESTS_RUN"
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed Tests:${NC}"
        for failure in "${FAILURES[@]}"; do
            echo -e "  ${RED}✗${NC} $failure"
        done
        echo ""
        echo -e "${RED}❌ OVERALL: FAIL${NC}"
        echo ""
        echo "Some tests failed. Please review the failures above."
        exit 1
    else
        echo -e "${GREEN}✅ OVERALL: PASS${NC}"
        echo ""
        echo "All automated tests passed!"
        echo ""
        echo "Next steps:"
        echo "1. Run manual wizard test in Desktop Mode"
        echo "2. Test error scenarios (no network, no drive)"
        echo "3. Test on real hardware"
        echo "4. Review TESTING.md for complete checklist"
        exit 0
    fi
}

# Run tests
main "$@"
