#!/usr/bin/env bash

set -e

cd backend
go run . &
BACKEND_PID=$!

cd ../frontend
npm run dev

kill $BACKEND_PID