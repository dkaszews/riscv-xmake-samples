#!/usr/bin/env bash
set -e

# TODO: multiple targets
if [[ -z $1 ]]; then
    echo >&2 'Usage: $0 <target>'
    exit 1
fi

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd -P)"
TARGET="$1"
TESTS_PASSED=0
TESTS_FAILED=0
IMPLIED_RESULT="$(mktemp -p /tmp implied_zero.XXXXXX)"

RESET='\033[0m'
RED='\033[31m'
GREEN='\033[32m'

echo 0 > $IMPLIED_RESULT
pushd "${SCRIPT_ROOT}/${TARGET}" > /dev/null

TESTS="$(ls -1d */ | wc -l)"
echo -e "${GREEN}[==========]${RESET} Running ${TESTS} from 1 test case."
echo -e "${GREEN}[----------]${RESET} Global test environment set-up."
echo -e "${GREEN}[==========]${RESET} ${TESTS} from ${TARGET}"

while read TEST; do
    TEST_FAILED=0
    pushd "$TEST" > /dev/null
    echo -e "${GREEN}[ RUN      ]${RESET} ${TARGET}.${TEST%%/}"

    # TODO: configurable timeout
    # TODO: measure time
    EXIT_CODE=0
    timeout 10 xmake run ci ${TARGET} < input.txt > output.log || EXIT_CODE=$?
    echo $EXIT_CODE > result.log
    [[ -e result.txt ]] && RESULT='result.txt' || RESULT="$IMPLIED_RESULT"
    diff -u result.log $RESULT > result.diff || true
    diff -u output.log output.txt > output.diff || true

    if [[ -s result.diff ]]; then
        TEST_FAILED=1
        cat result.diff
    fi
    if [[ -s output.diff ]]; then
        TEST_FAILED=1
        cat output.diff
    fi
    if [[ "${TEST_FAILED}" -eq 0 ]]; then
        echo -e "${GREEN}[       OK ]${RESET} ${TARGET}.${TEST%%/} (TODO ms)"
        ((TESTS_PASSED++)) || true
    else
        echo -e "${RED}[  FAILED  ]${RESET} ${TARGET}.${TEST%%/} (TODO ms)"
        ((TESTS_FAILED++)) || true
    fi

    popd > /dev/null
done < <(ls -d */)

popd > /dev/null
rm $IMPLIED_RESULT

echo -e "${GREEN}[==========]${RESET} ${TESTS} from ${TARGET} (TODO ms total)"
echo -e "${GREEN}[----------]${RESET} Global test environment tear-down."
# TODO: plurals
echo -e "${GREEN}[==========]${RESET} ${TESTS} from 1 test case ran."
echo -e "${GREEN}[  PASSED  ]${RESET} ${TESTS_PASSED} tests."

if [[ "${TESTS_FAILED}" -eq 0 ]]; then
    exit 0
fi

# TODO: plurals
echo -e "${RED}[  FAILED  ]${RESET} ${TESTS_FAILED} tests, listed below:"
# TODO: enumerate
echo
echo " ${TESTS_FAILED} FAILED TESTS"
exit 1

