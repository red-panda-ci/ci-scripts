#!/bin/bash
cd "$(dirname $0)/../../.."
echo "cd /tmp/project; bash ci-scripts/common/bin/_install.sh $@" | docker run -v `pwd`/:/tmp/project --rm -i redpandaci/duing /bin/bash
