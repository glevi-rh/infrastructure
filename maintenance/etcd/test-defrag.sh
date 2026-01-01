#!/bin/bash
#
# Test script for defrag.sh extraction logic
# Verifies grep extraction produces expected results
#

set -e

echo "=== Testing extraction logic ==="
echo ""

# Mock etcdctl endpoint status output
# To regenerate this mock data, run:
#
#   # Start etcd
#   podman run -d --name etcd-test -p 2379:2379 \
#       quay.io/coreos/etcd:v3.5.18 \
#       /usr/local/bin/etcd \
#       --advertise-client-urls http://0.0.0.0:2379 \
#       --listen-client-urls http://0.0.0.0:2379
#
#   # Get the JSON output
#   podman run --rm --network host quay.io/coreos/etcd:v3.5.18 \
#       etcdctl --endpoints=http://localhost:2379 endpoint status --write-out=json
#
#   # Cleanup
#   podman stop etcd-test && podman rm etcd-test
#
MOCK_STATUS='[{"Endpoint":"http://localhost:2379","Status":{"header":{"cluster_id":14841639068965178418,"member_id":10276657743932975437,"revision":1,"raft_term":2},"version":"3.5.18","dbSize":20480,"leader":10276657743932975437,"raftIndex":4,"raftTerm":2,"raftAppliedIndex":4,"dbSizeInUse":16384}}]'

# Expected values from mock data
EXPECTED_REVISION=1
EXPECTED_DBSIZE=20480
EXPECTED_DBSIZEINUSE=16384
EXPECTED_DIFF=4096

echo "Mock JSON:"
echo "$MOCK_STATUS"
echo ""

#######################################
# Extract using grep (same as defrag.sh)
#######################################
echo "=== Extracting with grep ==="
revision=$(echo "$MOCK_STATUS" | grep -oE '"revision":[0-9]*' | grep -oE '[0-9]*')
dbSize=$(echo "$MOCK_STATUS" | grep -oE '"dbSize":[0-9]*' | head -1 | grep -oE '[0-9]*')
dbSizeInUse=$(echo "$MOCK_STATUS" | grep -oE '"dbSizeInUse":[0-9]*' | head -1 | grep -oE '[0-9]*')
diff=$((dbSize - dbSizeInUse))

echo "  revision:    $revision"
echo "  dbSize:      $dbSize"
echo "  dbSizeInUse: $dbSizeInUse"
echo "  diff:        $diff"
echo ""

#######################################
# Assert against expected values
#######################################
echo "=== Validating results ==="
errors=0

if [ "$revision" = "$EXPECTED_REVISION" ]; then
    echo "✅ revision: $revision (expected: $EXPECTED_REVISION)"
else
    echo "❌ revision: $revision (expected: $EXPECTED_REVISION)"
    errors=$((errors + 1))
fi

if [ "$dbSize" = "$EXPECTED_DBSIZE" ]; then
    echo "✅ dbSize: $dbSize (expected: $EXPECTED_DBSIZE)"
else
    echo "❌ dbSize: $dbSize (expected: $EXPECTED_DBSIZE)"
    errors=$((errors + 1))
fi

if [ "$dbSizeInUse" = "$EXPECTED_DBSIZEINUSE" ]; then
    echo "✅ dbSizeInUse: $dbSizeInUse (expected: $EXPECTED_DBSIZEINUSE)"
else
    echo "❌ dbSizeInUse: $dbSizeInUse (expected: $EXPECTED_DBSIZEINUSE)"
    errors=$((errors + 1))
fi

if [ "$diff" = "$EXPECTED_DIFF" ]; then
    echo "✅ diff: $diff (expected: $EXPECTED_DIFF)"
else
    echo "❌ diff: $diff (expected: $EXPECTED_DIFF)"
    errors=$((errors + 1))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo "✅ All tests passed!"
    exit 0
else
    echo "❌ $errors test(s) failed!"
    exit 1
fi
