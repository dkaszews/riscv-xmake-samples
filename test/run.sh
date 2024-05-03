#!/usr/bin/env bash
if [[ -z $1 ]]; then
    echo >&2 'Usage: $0 <target>'
    exit 1
fi

SCRIPT_ROOT="$(cd "$(dirname "$0")"; pwd -P)"
TARGET="$1"
TESTS_FAILED=0

pushd "${SCRIPT_ROOT}/${TARGET}" > /dev/null
while read test; do
    TEST_FAILED=0
    pushd "$test" > /dev/null
    echo "Running test: $(pwd)"

    # TODO: configurable timeout
    timeout 10 xmake run ${TARGET} < input.txt > actual_output.txt
    echo $? > actual_code.txt
    diff expected_code.txt actual_code.txt > diff_code.txt
    diff expected_output.txt actual_output.txt > diff_output.txt

    if [[ -s diff_code.txt ]]; then
        TEST_FAILED=1
        echo 'Exit code differs:'
        cat diff_code.txt
    fi
    if [[ -s diff_output.txt ]]; then
        TEST_FAILED=1
        echo 'Output differs:'
        cat diff_output.txt
    fi
    if [[ "${TEST_FAILED}" -eq 0 ]]; then
        echo 'Success'
    else
        echo 'Failed'
        TESTS_FAILED=1
    fi

    popd > /dev/null
done < <(ls -1)
popd > /dev/null

if [[ "${TEST_FAILED}" -eq 0 ]]; then
    echo 'All tests passed'
else
    echo 'Some tests failed'
fi
exit $TESTS_FAILED

