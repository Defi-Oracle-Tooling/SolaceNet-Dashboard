#!/bin/bash

# This script runs npm commands without showing the CommonJS/ES Module warnings

# Run npm with the NODE_OPTIONS environment variable set to ignore warnings
NODE_OPTIONS="--no-warnings" npm "$@"
