#!/bin/bash

set -e

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

REQUIRED_RUBY_VERSION="3.0.0"
REQUIRED_OPENSSL_VERSION="1.1"
REQUIRED_OPENNEBULA_CLI_VERSION="6.10.2"

# Function to compare version strings using sort
version_ge() {
    # Split versions into components
    IFS='.' read -r -a ver1 <<< "$1"
    IFS='.' read -r -a ver2 <<< "$2"
    for i in 0 1 2; do
        # Pad missing components with 0
        v1=${ver1[i]:-0}
        v2=${ver2[i]:-0}
        if ((v1 > v2)); then
            return 0
        elif ((v1 < v2)); then
            return 1
        fi
    done
    return 0
}

# Check Ruby version
log "Checking Ruby version..."
if command -v ruby &> /dev/null; then
    ruby_version=$(ruby -e 'print RUBY_VERSION')
    if version_ge "$ruby_version" "$REQUIRED_RUBY_VERSION"; then
        log "Correct Ruby version ($ruby_version) is already installed."
    else
        log "Ruby version is $ruby_version, which is less than the required version ($REQUIRED_RUBY_VERSION)."
        INSTALL_RUBY=true
    fi
else
    log "Ruby is not installed."
    INSTALL_RUBY=true
fi

# Install RVM if necessary
if [[ "$INSTALL_RUBY" == true ]]; then
    log "Installing Ruby $REQUIRED_RUBY_VERSION with OpenSSL support..."
    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v rvm &> /dev/null; then
            log "Installing RVM..."
            curl -sSL https://get.rvm.io | bash -s stable --ruby || error_exit "Failed to install RVM."
        else
            log "RVM is already installed."
        fi

        export PATH="$PATH:$HOME/.rvm/bin"
        if ! xcode-select -p &> /dev/null; then
            log "Installing Xcode Command Line Tools..."
            xcode-select --install || log "Xcode Command Line Tools are already installed."
        else
            log "Xcode Command Line Tools are already installed."
        fi
        log "Checking OpenSSL version..."
        if ! brew list openssl@$REQUIRED_OPENSSL_VERSION &> /dev/null; then
            log "Installing OpenSSL $REQUIRED_OPENSSL_VERSION..."
            brew install openssl@$REQUIRED_OPENSSL_VERSION || error_exit "Failed to install OpenSSL."
        fi
        OPENSSL_DIR=$(brew --prefix openssl@$REQUIRED_OPENSSL_VERSION)
        rvm install "$REQUIRED_RUBY_VERSION" --with-openssl-dir="$OPENSSL_DIR" || error_exit "Failed to install Ruby $REQUIRED_RUBY_VERSION."
        rvm use "$REQUIRED_RUBY_VERSION" --default || error_exit "Failed to set Ruby $REQUIRED_RUBY_VERSION as default."
    elif [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
        apt update && apt install -y ruby ruby-dev || error_exit "Failed to install Ruby."
    else
        log "Cannot identify OS and install Ruby." 
        exit 1
    fi
    log "Ruby $REQUIRED_RUBY_VERSION is set as default."
else
    log "Skipping Ruby installation."
fi

# Check if OpenNebula CLI is installed
log "Checking if OpenNebula CLI is installed..."
if gem list opennebula-cli -i &> /dev/null; then
    log "OpenNebula CLI is already installed. Checking version..."
    nebula_cli_version=$(gem list opennebula-cli --local | grep opennebula-cli | awk '{print $2}' | tr -d '()')
    if version_ge "$nebula_cli_version" "$REQUIRED_OPENNEBULA_CLI_VERSION"; then
        log "Correct OpenNebula CLI version ($nebula_cli_version) is already installed."
    else
        log "Updating OpenNebula CLI to version $REQUIRED_OPENNEBULA_CLI_VERSION..."
        gem install opennebula-cli -v "$REQUIRED_OPENNEBULA_CLI_VERSION" || error_exit "Failed to update OpenNebula CLI."
    fi
else
    log "Installing OpenNebula CLI version $REQUIRED_OPENNEBULA_CLI_VERSION..."
    gem install opennebula-cli -v "$REQUIRED_OPENNEBULA_CLI_VERSION" || error_exit "Failed to install OpenNebula CLI."
fi

# Prompt for frontend configuration
read -p "Enter the OpenNebula frontend hostname or IP: " FRONTEND_HOST
read -p "Enter the OpenNebula user: " ONE_USER
read -s -p "Enter the OpenNebula password: " ONE_PASSWORD
echo

# Configure OpenNebula CLI
CONFIG_DIR="$HOME/.one"
if [[ ! -d "$CONFIG_DIR" ]]; then
    log "Creating configuration directory..."
    mkdir -p "$CONFIG_DIR" || error_exit "Failed to create configuration directory."
fi

log "Setting up authentication file..."
echo "$ONE_USER:$ONE_PASSWORD" > "$CONFIG_DIR/one_auth" || error_exit "Failed to create authentication file."

# Set environment variables
log "Setting environment variables..."
export ONE_XMLRPC="http://$FRONTEND_HOST:2633/RPC2"
export ONE_AUTH="$CONFIG_DIR/one_auth"
export ONEFLOW_URL="http://$FRONTEND_HOST:2474"

# Verify installation
if command -v onevm &> /dev/null; then
    log "OpenNebula CLI has been successfully configured."
    log "For convenience, add the following lines to your ~/.bashrc or ~/.zshrc file:"
    echo "export ONE_XMLRPC=\"http://$FRONTEND_HOST:2633/RPC2\""
    echo "export ONE_AUTH=\"$CONFIG_DIR/one_auth\"" 
    echo "export ONEFLOW_URL=\"http://$FRONTEND_HOST:2474\""
    log "Don't forget to reload your shell configuration file or restart your terminal."
else
    error_exit "Failed to verify OpenNebula CLI installation. Ensure the CLI is installed."
fi
