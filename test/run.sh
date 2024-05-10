#!/usr/bin/env bash
set -e
if [[ -z $1 ]]; then
    echo >&2 'Usage: $0 <target>'
    exit 1
fi

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd -P)"
TARGET="$1"
TESTS_FAILED=0
IMPLIED_RESULT="$(mktemp -p /tmp implied_zero.XXXXXX)"

# TODO: make output more gtest-like
pushd "${SCRIPT_ROOT}/${TARGET}" > /dev/null
echo 0 > $IMPLIED_RESULT
while read TEST; do
    TEST_FAILED=0
    pushd "$TEST" > /dev/null
    echo "Running test: $(pwd)"

    # TODO: configurable timeout
    EXIT_CODE=0
    timeout 10 xmake run ci ${TARGET} < input.txt > output.log || EXIT_CODE=$?
    echo $EXIT_CODE > result.log
    [[ -e result.txt ]] && RESULT='result.txt' || RESULT="$IMPLIED_RESULT"
    diff -u result.log $RESULT > result.diff || true
    diff -u output.log output.txt > output.diff || true

    if [[ -s result.diff ]]; then
        TEST_FAILED=1
        echo 'Exit code differs:'
        cat result.diff
    fi
    if [[ -s output.diff ]]; then
        TEST_FAILED=1
        echo 'Output differs:'
        cat output.diff
    fi
    if [[ "${TEST_FAILED}" -eq 0 ]]; then
        echo 'Success'
    else
        echo 'Failed'
        TESTS_FAILED=1
    fi

    popd > /dev/null
done < <(ls -d */)

popd > /dev/null
rm $IMPLIED_RESULT

if [[ "${TESTS_FAILED}" -eq 0 ]]; then
    echo 'All tests passed'
else
    echo 'Some tests failed'
fi
exit $TESTS_FAILED

