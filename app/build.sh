#!/bin/bash
set -Eeuxo pipefail # https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/

pushd .
trap "popd" EXIT HUP INT QUIT TERM

DIR=`mktemp -d`
APP=$1
CUR_GIT_ROOT=$(git rev-parse --show-toplevel)

cd ${DIR}
qmake ${CUR_GIT_ROOT}/app/${APP} -spec linux-g++ CONFIG+=debug CONFIG+=qml_debug && /usr/bin/make -j4 qmake_all && /usr/bin/make -j4

ls -la ${DIR}

popd >& /dev/null





