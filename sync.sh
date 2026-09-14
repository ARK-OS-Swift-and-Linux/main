#!/bin/bash
# Copyright 2026 Aarav Ravindra Kharade
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

REPO_URL="https://github.com/ARK-OS-Swift-and-Linux/main.git"
DIR_NAME="ARK-OS"

echo "========================================"
echo "          ARK-OS Sync Script            "
echo "========================================"
echo ""
echo "Syncing the ARK-OS repository and all nested submodules..."

# The --recursive flag automatically clones the repository and all of its 
# submodules, including nested submodules (submodules of submodules) recursively.
git clone --recursive "$REPO_URL" "$DIR_NAME"

echo ""
echo "========================================"
echo "      Successfully synced ARK-OS!"
echo "========================================"
echo "You can now enter the directory and begin building:"
echo "  cd $DIR_NAME"
echo ""
