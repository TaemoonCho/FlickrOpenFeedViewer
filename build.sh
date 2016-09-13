#! /bin/sh

RED=$(printf "\033[1;31m")
BLUE=$(printf "\033[1;34m")
BOLD=$(printf "\e[1;4m")
RESET=$(printf "\e[0m")

PROJECT_NAME=`printf '%s\n' "${PWD##*/}"`

function clear_pods {
  echo "Kill The Xcode process."
  PID=`ps -eaf | grep Xcode | grep -v grep | awk '{print $2}'`
  if [[ "" !=  "$PID" ]]; then
    echo "Xcode is running. Now shutting down Xcode"
    kill -9 $PID
  fi
  echo "Clear DerivedData of XCode builds"
  rm -Rf ~/Library/Developer/Xcode/DerivedData
  echo "Clear cocoa pod caches."
  rm -Rf "${HOME}/Library/Caches/CocoaPods"
  echo "Delete cocoa pods."
  rm -Rf "`pwd`/Pods/"
  echo "Delete `pwd`/${PROJECT_NAME}.xcworkspace"
  rm -Rf "`pwd`/${PROJECT_NAME}.xcworkspace"
  pod update
  echo "Starting pod install"
  pod install
  open ${PROJECT_NAME}.xcworkspace
}

function check_swift_lint {
  if which swiftlint >/dev/null
  then
    echo "Found ${BLUE}Swiftlint${RESET}."
  else
    echo "${RED}Should install 'Swiftlint' by homebrew before try to build.${RESET}"
    read -p "Would install the 'Swiftlint' now? (y/n) : " choice
    case "$choice" in
      y|Y ) install_homebrew_and_swiftlint;;
     * ) echo "Canceled";;
    esac
  fi
}

function install_homebrew_and_swiftlint {
  if which brew >/dev/null
  then
    brew install swiftlint
  else
    echo "${RED}Homebrew not found.${RESET}"
    echo "Please retry after install 'Homebrew'. Reference to ${BOLD}http://brew.sh/${RESET}"
    exit 1
  fi
}

check_swift_lint

read -p "If Continue this task, Quit Xcode and remove current pods. Are you sure (y/n)?" choice
case "$choice" in
  y|Y ) clear_pods;;
 * ) echo "Canceled";;
esac
