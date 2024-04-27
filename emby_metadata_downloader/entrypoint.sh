#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC2068

cd /app || exit

while true; do
    python3 solid.py $@
    sleep "${CYCLE}"
done
