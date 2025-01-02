#!/usr/bin/env bash

fruits=(
    "bilberry" "blackberry" "blueberry" "boysenberry" "cloudberry" "dewberry" "elderberry" "gooseberry"
    "huckleberry" "mulberry" "raspberry" "salal berry" "strawberry"
)

case $1 in
    "pi")
       name="cake";
       prefix="${fruits[$RANDOM % ${#fruits[@]}]}";
    ;;
esac

echo "${prefix}-${name}"
