#!/bin/sh -e

. ../lib/sh-test-lib
OUTPUT="$(pwd)/output"
RESULT_FILE="${OUTPUT}/result.txt"
TEST_LOG="${OUTPUT}/stream-output.txt"

create_out_dir "${OUTPUT}"

# Run Test.
detect_abi
# shellcheck disable=SC2154
./bin/"${abi}"/stream 2>&1 | tee "${TEST_LOG}"

if [ $? = 0  ];then
    lava-test-case STREAM-Execute --result pass
else
    lava-test-case STREAM-Execute --result fail
fi


# Parse output.
for test in Copy Scale Add Triad; do
    ret=`grep "^${test}" "${TEST_LOG}" \
      | awk -v test="${test}" \
        '{printf("stream-uniprocessor-%s pass %s MB/s\n", test, $2)}' \
      | tee -a "${RESULT_FILE}"`
    lava-test-case STREAM-${test}-$ret --result pass
    
done
