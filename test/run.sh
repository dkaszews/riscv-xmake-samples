#!/usr/bin/env bash
set -e

CNONE='\033[0m'
CFAIL='\033[31m'
CPASS='\033[32m'

# TODO: options
[[ -d "$1" ]] && cd "$1"

tests_passed=0
tests_failed=0
failed_tests="$(realpath ./failed_tests.log)"
echo -n > "$failed_tests"
implied_result="$(realpath ./implied_result.log)"
echo 0 > $implied_result

ls -1d *.suite/ > suites.log
suites="$(cat suites.log | wc -l)"
ls -1d *.suite/*.test/ > tests.log
total="$(cat tests.log | wc -l)"

# TODO: plurals
echo -e "${CPASS}[==========]${CNONE} Running ${total} tests from ${suites} suites."

while read suite; do
    pushd $suite > /dev/null
    runner="$(realpath ./test.sh)"
    ls -1d *.test/ > tests.log
    tests="$(cat tests.log | wc -l)"
    echo -e "${CPASS}[----------]${CNONE} ${tests} tests from ${suite%.suite/}"

    # TODO: functions
    while read test; do
        pushd $test > /dev/null
        # TODO: repeated name
        echo -e "${CPASS}[ RUN      ]${CNONE} ${suite%.suite/}.${test%.test/}"

        pass=1
        exit_code=0
        # TODO: configurable timeout
        # TODO: implied input
        timeout 10 "$runner" < input.txt > output.log || exit_code=$?
        echo $exit_code > result.log

        # TODO: implied output
        [[ -e result.txt ]] && result='result.txt' || result="${implied_result}"
        diff -u result.log $result > result.diff || [[ "$?" -eq 1 ]]
        diff -u output.log output.txt > output.diff || [[ "$?" -eq 1 ]]

        if [[ -s result.diff ]]; then
            pass=0
            cat result.diff
        fi
        if [[ -s output.diff ]]; then
            pass=0
            cat output.diff
        fi
        if [[ "$pass" -ne 0 ]]; then
            echo -e "${CPASS}[       OK ]${CNONE} ${suite%.suite/}.${test%.test/} (TODO ms)"
            ((tests_passed++)) || true
        else
            echo -e "${CFAIL}[  FAILED  ]${CNONE} ${suite%.suite/}.${test%.test/} (TODO ms)"
            ((tests_failed++)) || true
            echo "${suite%.suite/}.${test%.test/}" >> "$failed_tests"
        fi

        popd > /dev/null
    done < tests.log

    echo -e "${CPASS}[----------]${CNONE} ${tests} tests from ${suite%.suite/} (TODO ms total)"
    popd > /dev/null
done < suites.log

echo -e "${CPASS}[==========]${CNONE} ${total} tests from ${suites} suites ran. (TODO ms total)"
echo -e "${CPASS}[  PASSED  ]${CNONE} ${tests_passed} tests."
[[ "${tests_failed}" -eq 0 ]] && exit 0

echo -e "${CFAIL}[  FAILED  ]${CNONE} ${tests_failed} tests, listed below:"
while read test; do
    echo -e "${CFAIL}[  FAILED  ]${CNONE} $test"
done < "$failed_tests"

echo
echo " ${tests_failed} FAILED TESTS"
exit 1

