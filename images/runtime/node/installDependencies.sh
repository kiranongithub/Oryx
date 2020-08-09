#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

set -ex

# All users need access to node_modules at the root, as this is the location
# for packages valid for all apps.
mkdir -p /node_modules
chmod 777 /node_modules

# Since older versions of npm cli have security vulnerabilities, we try upgrading it
# to the latest available version. However latest versions of npm do not work with very
# old versions of Node (for example: 4 or 6), so we special case here to limit the upgrade
# to only versions 8 or above
currentNodeVersion=$(node --version)
currentNodeVersion=${currentNodeVersion#?}
echo "Current Node version is $currentNodeVersion"
IFS='.' read -ra NODE_VERSION_PARTS <<< "$currentNodeVersion"
nodeVersionMajor="${NODE_VERSION_PARTS[0]}"
# v10 => 10
nodeVersionMajor="${nodeVersionMajor:1}"

currentNpmVersion=$(npm --version)
echo "Version of npm: $currentNpmVersion"

# Upgrade npm to the latest available version
if [[ $nodeVersionMajor -ge 8  ]]; then
    echo "Upgrading npm..."
    npm install npm -g
    echo "Done upgrading npm."
    currentNpmVersion=$(npm --version)
    echo "Version of npm after upgrade: $currentNpmVersion"
fi

# Do NOT install PM2 from Node 14 onwards
if [ "$nodeVersionMajor" -lt "14" ]; then
    echo "Installing PM2..."
    # PM2 is supported as an option when running the app,
    # so we need to make sure it is available in our images.
    npm install -g pm2@3.5.1
else
    echo "Skipping PM2 installation..."
fi

# Application-Insights is supported as an option for telemetry when running the app,
# so we need to make sure it is available in our images.
# Updated to 1.8.3 that doesn't emit json payload in stdout which is causing issues to customers in ant-88
npm install -g applicationinsights@1.8.3
