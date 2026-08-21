#!/bin/sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
test_dir=$(mktemp -d)
trap 'rm -rf "${test_dir}"' EXIT HUP INT TERM

mkdir -p "${test_dir}/iventoy/data" "${test_dir}/defaults"
printf 'image-data\n' > "${test_dir}/iventoy/data/iventoy.dat"
printf 'user-config\n' > "${test_dir}/iventoy/data/config.dat"
printf 'default-image-data\n' > "${test_dir}/defaults/iventoy.dat"
printf 'default-mac-data\n' > "${test_dir}/defaults/mac.db"

cat > "${test_dir}/probe" <<'EOF'
#!/bin/sh
printf '%s\n' "$PWD" > "${TEST_OUTPUT}/cwd"
printf '%s\n' "$IVENTOY_API_ALL" > "${TEST_OUTPUT}/api-all"
printf '%s\n' "${IVENTOY_AUTO_RUN-unset}" > "${TEST_OUTPUT}/auto-run"
printf '%s\n' "$IVENTOY_NO_DAEMON_MODE" > "${TEST_OUTPUT}/no-daemon"
printf '%s\n' "$LD_LIBRARY_PATH" > "${TEST_OUTPUT}/library-path"
EOF
chmod +x "${test_dir}/probe"

IVENTOY_DIR="${test_dir}/iventoy" \
IVENTOY_DEFAULT_DATA_DIR="${test_dir}/defaults" \
TEST_OUTPUT="${test_dir}" \
    "${project_dir}/files/docker-entrypoint.sh" "${test_dir}/probe"

assert_equal() {
    expected=$1
    actual=$2
    label=$3
    if [ "${actual}" != "${expected}" ]; then
        printf 'FAIL: %s: expected <%s>, got <%s>\n' "${label}" "${expected}" "${actual}" >&2
        exit 1
    fi
}

assert_equal 'default-image-data' "$(cat "${test_dir}/iventoy/data/iventoy.dat")" 'incompatible image data is refreshed'
assert_equal 'default-mac-data' "$(cat "${test_dir}/iventoy/data/mac.db")" 'missing MAC database is initialized'
assert_equal 'user-config' "$(cat "${test_dir}/iventoy/data/config.dat")" 'user config is preserved'
assert_equal "${test_dir}/iventoy" "$(cat "${test_dir}/cwd")" 'working directory'
assert_equal '1' "$(cat "${test_dir}/api-all")" 'API access'
assert_equal 'unset' "$(cat "${test_dir}/auto-run")" 'automatic startup is opt-in'
assert_equal '1' "$(cat "${test_dir}/no-daemon")" 'foreground mode'
assert_equal "${test_dir}/iventoy/lib/lin64" "$(cat "${test_dir}/library-path")" 'library path'

printf 'stale-image-data\n' > "${test_dir}/iventoy/data/iventoy.dat"
printf 'custom-mac-data\n' > "${test_dir}/iventoy/data/mac.db"
IVENTOY_DIR="${test_dir}/iventoy" \
IVENTOY_DEFAULT_DATA_DIR="${test_dir}/defaults" \
IVENTOY_AUTO_RUN=0 \
TEST_OUTPUT="${test_dir}" \
    "${project_dir}/files/docker-entrypoint.sh" "${test_dir}/probe"

assert_equal 'default-image-data' "$(cat "${test_dir}/iventoy/data/iventoy.dat")" 'stale image data is refreshed on every start'
assert_equal 'default-mac-data' "$(cat "${test_dir}/iventoy/data/mac.db")" 'stale MAC database is refreshed on every start'
assert_equal 'user-config' "$(cat "${test_dir}/iventoy/data/config.dat")" 'user config remains preserved'
assert_equal 'unset' "$(cat "${test_dir}/auto-run")" 'zero does not enable automatic startup'

IVENTOY_DIR="${test_dir}/iventoy" \
IVENTOY_DEFAULT_DATA_DIR="${test_dir}/defaults" \
IVENTOY_AUTO_RUN=1 \
TEST_OUTPUT="${test_dir}" \
    "${project_dir}/files/docker-entrypoint.sh" "${test_dir}/probe"

assert_equal '1' "$(cat "${test_dir}/auto-run")" 'automatic startup can be explicitly enabled'

printf 'PASS: container entrypoint\n'
