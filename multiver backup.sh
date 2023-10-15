#!/bin/bash

ver="v1.0"
githubAPI="https://api.github.com/repos/unethicalteam/multiverbackup/releases/latest"
githubURL="https://github.com/unethicalteam/multiverbackup/releases/latest"

echo -ne "\033]0;multiver backup: $ver\007"

# Check for latest GitHub release
latestTag=$(curl -s "$githubAPI" | grep '"tag_name":' | sed -E 's/.*"tag_name": "([^"]+)".*/\1/')

if [[ "$latestTag" != "$ver" ]]; then
  echo -e "A new version of multiver backup: $latestTag was found on GitHub!"
  echo -e "You can download it from: \033[36m$githubURL\033[0m"
  read -n 1 -s -r -p "Press any key to exit..."
  exit 0
fi

# Check Lunar Client's launcher version
LAUNCHER_VERSION=$(curl -s "https://launcherupdates.lunarclientcdn.com/latest.yml" | grep "version:" | awk '{print $2}')

# Check for output.txt and rename if exists
if [ -f "output.txt" ]; then
  [ -f "previous_output.txt" ] && rm -f "previous_output.txt"
  mv "output.txt" "previous_output.txt"
fi

# Make a cURL request to Lunar Client's API
curl -s -X POST -H "Content-Type: application/json; charset=UTF-8" -H "User-Agent: Lunar Client Launcher v$LAUNCHER_VERSION" -d "{\"version\":\"1.8.9\",\"branch\":\"master\",\"os\":\"win32\",\"arch\":\"x64\",\"launcher_version\":\"$LAUNCHER_VERSION\",\"hwid\":\"0\"}" "https://api.lunarclientprod.com/launcher/launch" > "output.txt" && echo "Successfully requested from Lunar Client's API." || { echo "Request unsuccessful."; exit 1; }

# Check for updates and make backups
if [ -f "previous_output.txt" ]; then
  if ! cmp -s "output.txt" "previous_output.txt"; then
    LunarUpdated=true
  else
    LunarUpdated=false
  fi
  
  if [[ "$LunarUpdated" == "true" ]]; then
    echo "Lunar has updated."
    timestamp=$(date +"%Y%m%d_%H%M%S")
    folderToBackup="$HOME/.lunarclient/offline/multiver"

    echo "Creating backup: multiver $timestamp backup.zip"
    cd "$folderToBackup"
    zip -r "multiver $timestamp backup.zip" . > /dev/null
    mv "multiver $timestamp backup.zip" "$OLDPWD"
    cd "$OLDPWD"

    if [ -f "multiver $timestamp backup.zip" ]; then
      echo "Backup created successfully."
      echo -e "\033[40;31mDo not delete output.txt or previous_output.txt, this is for change detection from the API.\033[0m"
      read -n 1 -s -r -p "Press any key to continue..."
    else
      echo "Failed to create the backup."
    fi
  else
    echo "No update detected."
    echo -e "\033[40;31mDo not delete output.txt or previous_output.txt, this is for change detection from the API.\033[0m"
  fi
else
  if [ -f "output.txt" ]; then
    timestamp=$(date +"%Y%m%d_%H%M%S")
    folderToBackup="$HOME/.lunarclient/offline/multiver"
    
    echo "Creating backup: multiver $timestamp backup.zip"
    cd "$folderToBackup"
    zip -r "multiver $timestamp backup.zip" . > /dev/null
    mv "multiver $timestamp backup.zip" "$OLDPWD"
    cd "$OLDPWD"

    if [ -f "multiver $timestamp backup.zip" ]; then
      echo "Backup created successfully."
      echo -e "\033[40;31mDo not delete output.txt, this is for change detection from the API.\033[0m"
      read -n 1 -s -r -p "Press any key to continue..."
    fi
  fi
fi

# Credits screen, only shows on the first run
if [ -f "output.txt" ] && [ ! -f "previous_output.txt" ]; then
  clear
  echo "Special thanks to decencies for API direction."
  echo "Made possible by a very good conversation:"
  echo "\"I want to add automated multiver backups in lcbud\" -uchks 2023, 09-24"
  echo "\"Then do it\" -Syz 2023, 09-24"
  echo
  echo "This isn't lcbud, but I did it."
  echo "Made by uchks. Unethicalteam."
  read -n 1 -s -r -p "Press any key to continue..."
fi
