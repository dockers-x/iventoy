#!/bin/sh
set -eu

readonly iventoy_dir="${IVENTOY_DIR:-/iventoy}"
readonly data_dir="${iventoy_dir}/data"
readonly defaults_dir="${IVENTOY_DEFAULT_DATA_DIR:-/usr/share/iventoy/data}"

mkdir -p "${data_dir}"

# Official upgrades retain only config.dat and ISO files. These bundled data
# files are tied to the installed release and must never survive an upgrade.
for file in iventoy.dat mac.db; do
    echo "Refreshing ${data_dir}/${file}"
    cp "${defaults_dir}/${file}" "${data_dir}/${file}"
done

export IVENTOY_API_ALL="${IVENTOY_API_ALL:-1}"
export IVENTOY_AUTO_RUN="${IVENTOY_AUTO_RUN:-1}"
export IVENTOY_NO_DAEMON_MODE=1
export LD_LIBRARY_PATH="${iventoy_dir}/lib/lin64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"

cd "${iventoy_dir}"
if [ "$#" -eq 0 ]; then
    set -- "${iventoy_dir}/lib/iventoy"
fi
exec "$@"
