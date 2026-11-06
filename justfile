check:
    .gems/bin/reapack-index --check --ignore .gems --ignore .direnv --ignore stubs

index:
    .gems/bin/reapack-index --no-commit scripts
