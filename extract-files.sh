#!/bin/bash

set -e

DEVICE=even
VENDOR=realme

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

ANDROID_ROOT="$MY_DIR/../../.."

HELPER="$ANDROID_ROOT/tools/extract-utils/extract_utils.sh"
if [ ! -f "$HELPER" ]; then
    echo "Unable to find helper script at $HELPER"
    exit 1
fi
source "$HELPER"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

SECTION=
SRC=

while [ "$#" -gt 0 ]; do
    case "$1" in
        --only-common )
            ONLY_COMMON=true
            ;;
        --only-target )
            ONLY_TARGET=true
            ;;
        --section )
            SECTION="$2"; shift
            CLEAN_VENDOR=false
            ;;
        --no-cleanup )
            CLEAN_VENDOR=false
            ;;
        -n | --no-cleanup )
            CLEAN_VENDOR=false
            ;;
        -s | --src )
            SRC="$2"; shift
            ;;
        * )
            SRC="$1"
            ;;
    esac
    shift
done

if [ -z "$SRC" ]; then
    SRC=adb
fi

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" true "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" \
    --section "${SECTION}"

"$PWD/setup-makefiles.sh"
