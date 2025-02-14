#!/bin/bash
# file: install.sh
#
# This script will install required software for Witty Pi.
# It is recommended to run it in your home directory.
#
# Includes modifications from https://github.com/maxsitt/Witty-Pi-4

# Set strict error handling
set -euo pipefail

# Check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

# Set home directory as target directory for wittypi software
DIR="/home/${SUDO_USER}/wittypi"

# Create error counter
ERR=0

# Set path to config.txt file
BOOT_CONFIG_FILE='/boot/firmware/config.txt'
[ ! -e "${BOOT_CONFIG_FILE}" ] && BOOT_CONFIG_FILE='/boot/config.txt'

# Function for error handling
handle_error() {
  echo "Error: $1" >&2
  ((ERR++))
}

# Function for package installation
install_package() {
  local package="$1"
  if ! command -v "${package}" &> /dev/null; then
    echo
    echo ">>> Installing ${package}..."
    apt install -y "${package}" || handle_error "Failed to install ${package}"
  else
    echo "${package} is already installed"
  fi
}

echo '================================================================================'
echo '|                                                                              |'
echo '|                   Witty Pi Software Installation Script                      |'
echo '|                                                                              |'
echo '================================================================================'

# Make sure en_GB.UTF-8 locale is installed
echo
echo '>>> Make sure en_GB.UTF-8 locale is installed...'
if locale -a | grep -q 'en_GB.utf8'; then
  echo 'en_GB.UTF-8 locale is already installed.'
else
  echo '>>> Installing en_GB.UTF-8 locale...'
  sed -i.bak '/en_GB.UTF-8/s/^#//g' /etc/locale.gen
  locale-gen || ((ERR++))
fi

# Enable I2C on Raspberry Pi
echo
echo '>>> Enabling I2C...'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q 'i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi

active_i2c="$(grep -E '^[^#]*dtparam=i2c_arm=on' "${BOOT_CONFIG_FILE}" || true)"
if [ -n "${active_i2c}" ]; then
    echo 'Seems i2c_arm parameter already set, skip this step'
else
    commented_i2c="$(grep -E '^#.*dtparam=i2c_arm=on' "${BOOT_CONFIG_FILE}" || true)"
    if [ -n "${commented_i2c}" ]; then
        sed -i 's/^#.*\(dtparam=i2c_arm=on\)/\1/' "${BOOT_CONFIG_FILE}"
    else
        echo 'dtparam=i2c_arm=on' >> "${BOOT_CONFIG_FILE}"
    fi
fi

# Setting Bluetooth to use mini-UART
echo
echo '>>> Setting Bluetooth to use mini-UART...'
active_uart="$(grep -E '^[^#]*dtoverlay=miniuart-bt' "${BOOT_CONFIG_FILE}" || true)"
if [ -n "${active_uart}" ]; then
    echo 'Seems setting Bluetooth to use mini-UART is done already, skip this step'
else
    commented_uart="$(grep -E '^#.*dtoverlay=miniuart-bt' "${BOOT_CONFIG_FILE}" || true)"
    if [ -n "${commented_uart}" ]; then
        sed -i 's/^#.*\(dtoverlay=miniuart-bt\)/\1/' "${BOOT_CONFIG_FILE}"
    else
        echo 'dtoverlay=miniuart-bt' >> "${BOOT_CONFIG_FILE}"
    fi
fi

# Install i2c-tools and git
echo
apt update || handle_error "Failed to update package list"
install_package i2c-tools
install_package git

# Install WiringPi
echo
echo '>>> Installing WiringPi...'
if ! command -v gpio &> /dev/null; then
  os="$(lsb_release -r | grep 'Release:' | sed 's/Release:\s*//')"
  arch="$(dpkg --print-architecture)"

  if [ "${os}" -le 10 ]; then
    install_package wiringpi
  else
    WIRINGPI_VERSION='3.14'
    [ "${os}" -eq 11 ] && WIRINGPI_VERSION='3.2'

    WIRINGPI_DEB="wiringpi_${WIRINGPI_VERSION}_${arch}.deb"
    [ "${os}" -eq 11 ] && WIRINGPI_DEB="wiringpi_${WIRINGPI_VERSION}-bullseye_armhf.deb"

    wget -q "https://github.com/WiringPi/WiringPi/releases/download/${WIRINGPI_VERSION}/${WIRINGPI_DEB}" -O wiringpi.deb || handle_error "Failed to download WiringPi"
    apt install -y ./wiringpi.deb || handle_error "Failed to install WiringPi"
    rm wiringpi.deb
  fi
else
  echo 'WiringPi is already installed'
fi

# Install wittypi from forked repository
if [ "${ERR}" -eq 0 ]; then
  echo
  echo '>>> Installing wittypi...'
  if [ ! -d 'wittypi' ]; then
    git clone --depth 1 --single-branch --branch main --no-tags \
        https://github.com/maxsitt/Witty-Pi-4.git tmp_wittypi || handle_error 'Git clone failed'

    if [ -d "tmp_wittypi/Software/wittypi" ]; then
      mv tmp_wittypi/Software/wittypi .
      rm -rf tmp_wittypi

      # Make scripts executable
      find wittypi -name "*.sh" -exec chmod +x {} \;

      # Set up service
      sed -e "s#/home/pi/wittypi#${DIR}#g" wittypi/init.sh > /etc/init.d/wittypi
      chmod +x /etc/init.d/wittypi
      update-rc.d wittypi defaults || handle_error "Failed to set up service"

      # Create log files
      touch wittypi/{wittyPi,schedule}.log
      chown -R "$SUDO_USER:$(id -g -n "$SUDO_USER")" wittypi || handle_error "Failed to set permissions"
    else
      handle_error "Required directory not found in cloned repository"
    fi
  else
    echo 'WittyPi is already installed'
  fi
fi

echo
if [ "${ERR}" -eq 0 ]; then
  echo 'Installation successful. Please reboot your Pi :-)'
  exit 0
else
  echo "Installation failed with ${ERR} errors. Please check the messages above :-("
  exit 1
fi
