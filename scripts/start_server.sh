#!/bin/bash

mkdir -p "${SYMROOT}/pacts"
which pact-mock-service

pact-mock-service start --pact-specification-version 2.0.0 --log "${SYMROOT}/pact.log" --pact-dir "${SYMROOT}/pacts" -p 1234
