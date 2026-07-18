#!/usr/bin/env bash
set -e

echo "========================================"
echo "Setting up Business Reservation Platform"
echo "========================================"

echo
echo "Go version:"
go version

echo
echo "Node version:"
node -v

echo
echo "NPM version:"
npm -v

echo
echo "Installing backend dependencies..."
cd backend
go mod download

echo
echo "Installing frontend dependencies..."
cd ../frontend
npm install

echo
echo "Setup completed successfully."