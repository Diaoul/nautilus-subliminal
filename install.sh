#!/bin/bash
# heavily inspired oh-my-zsh install script
# see https://github.com/robbyrussell/oh-my-zsh/

main() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if which tput >/dev/null 2>&1; then
      ncolors=$(tput colors)
  fi
  if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    BOLD="$(tput bold)"
    NORMAL="$(tput sgr0)"
  else
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    BOLD=""
    NORMAL=""
  fi

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  # Install required packages
  printf "${BLUE}Installing necessary packages...${NORMAL}\n"
  apt-get install -y git python-pip python-nautilus || dnf install -y git python-pip nautilus-python || {
    printf "Error: failed to install required packages\n"
    exit 1
  }

  # Clone the repository if called from the web and start operations from there
  if [ ! -f "nautilus-subliminal.py" ]; then
    printf "${BLUE}Cloning subliminal-nautilus...${NORMAL}\n"
    TMP_DIR=$(mktemp -d)
    git clone --depth=1 https://github.com/Diaoul/nautilus-subliminal.git ${TMP_DIR} || {
      printf "Error: git clone of subliminal-nautilus repo failed\n"
      exit 1
    }
    pushd ${TMP_DIR}
  fi

  # Install requirements
  printf "${BLUE}Installing python requirements...${NORMAL}\n"
  pip install --upgrade -r requirements.txt || {
    printf "Error: failed to install requirements\n"
    exit 1
  }

  # Install extension
  printf "${BLUE}Installing extension...${NORMAL}\n"
  install -m 755 nautilus-subliminal.py /usr/share/nautilus-python/extensions/
  install -d /usr/share/nautilus-python/extensions/subliminal
  cp -r ui /usr/share/nautilus-python/extensions/subliminal/
  for filepath in i18n/*.po; do
    filename=$(basename "$filepath")
    install -d /usr/share/nautilus-python/extensions/subliminal/locale/${filename##*.}/LC_MESSAGES/
    msgfmt ${filepath} -o /usr/share/nautilus-python/extensions/subliminal/locale/${filename##*.}/LC_MESSAGES/subliminal.mo
  done

  # Clean up
  if [ ! -z ${TMP_DIR+x} ]; then
    popd
    rm -r ${TMP_DIR}
  fi

  printf "${GREEN}"
  echo ''
  echo 'Subliminal extension for Nautilus is now installed!'
  echo ''
  echo 'Please visit https://github.com/Diaoul/nautilus-subliminal for any issue'
  echo ''
  printf "${NORMAL}"
}

main
