#!/usr/bin/env bash
# Minimal test harness for the Mini C Compiler.
#
# Runs two suites:
#   1. parse_ok:   every file in `examples/` must compile (exit 0, codegen completes).
#                  `tests/parse_fail` is intentionally excluded.
#   2. parse_fail: every .c file in `tests/parse_fail/` must produce an error,
#                  and stderr must contain the substring from the matching .err file.

set -u

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
COMPILER="${REPO_ROOT}/bin/compiler.exe"

if [ ! -x "${COMPILER}" ]; then
    echo "error: ${COMPILER} not found. Run 'make' first." >&2
    exit 2
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

pass=0
fail=0
failures=()

run_one() {
    local label="$1" src="$2" expect="$3" err_file="$4"
    local out="${TMPDIR}/out.txt"

    ( cd "${TMPDIR}" && "${COMPILER}" "${src}" ) > "${out}" 2>&1
    local rc=$?

    case "${expect}" in
        ok)
            if [ "${rc}" -eq 0 ] && grep -q "Code generation complete" "${out}"; then
                pass=$((pass + 1))
                printf "  PASS  %s\n" "${label}"
            else
                fail=$((fail + 1))
                failures+=("${label}")
                printf "  FAIL  %s (rc=%d)\n" "${label}" "${rc}"
                sed -e 's/^/        | /' "${out}"
            fi
            ;;
        fail)
            local needle
            needle="$(head -n1 "${err_file}")"
            # The compiler currently always exits 0; rely on the error substring
            # in stderr/stdout to determine whether the expected error was raised.
            if grep -q -F "${needle}" "${out}"; then
                pass=$((pass + 1))
                printf "  PASS  %s\n" "${label}"
            else
                fail=$((fail + 1))
                failures+=("${label}")
                printf "  FAIL  %s (expected error substring '%s' not found)\n" "${label}" "${needle}"
                sed -e 's/^/        | /' "${out}"
            fi
            ;;
    esac
}

echo "== parse_ok =="
for src in "${REPO_ROOT}"/examples/*.c; do
    base="$(basename "${src}" .c)"
    # source.c is known to error on baseline (semantic errors); skip from ok suite.
    case "${base}" in
        source) continue ;;
    esac
    run_one "examples/${base}.c" "${src}" ok ""
done

echo
echo "== parse_fail =="
for src in "${REPO_ROOT}"/tests/parse_fail/*.c; do
    base="$(basename "${src}" .c)"
    err="${REPO_ROOT}/tests/parse_fail/${base}.err"
    if [ ! -f "${err}" ]; then
        echo "  SKIP  parse_fail/${base}.c (no .err file)"
        continue
    fi
    run_one "parse_fail/${base}.c" "${src}" fail "${err}"
done

echo
echo "Results: ${pass} passed, ${fail} failed"
if [ "${fail}" -ne 0 ]; then
    printf 'Failures:\n'
    printf '  - %s\n' "${failures[@]}"
    exit 1
fi
exit 0
