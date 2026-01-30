#!/bin/bash

# ==========================================
# FUNCTION DEFINITIONS
# ==========================================

# FEATURE 1: Pretty Printing Function
# Uses printf for reliable formatting and visual separation
pretty_print() {
    local message="$1"
    printf "\n%s\n\n" ">>> $message"
}

# FEATURE 2: Operating System Detection
# Detects OS to determine the correct package manager
detect_os() {
    pretty_print "Detecting Operating System..."
    
    case "$OSTYPE" in
        linux-gnu*)
            echo "OS Detected: Linux"
            PKG_MANAGER="sudo apt-get install -y"
            UPDATE_CMD="sudo apt-get update"
            ;;
        darwin*)
            echo "OS Detected: macOS"
            PKG_MANAGER="brew install"
            UPDATE_CMD="brew update"
            ;;
        *)
            echo "Unknown OS: $OSTYPE"
            echo "This script supports Linux (apt) and macOS (brew)."
            exit 1
            ;;
    esac
}

# FEATURE 3: Python Install Check
# Checks for python3; installs it if missing
check_and_install_python() {
    pretty_print "Checking for Python 3..."

    if command -v python3 &> /dev/null; then
        echo "Python 3 is already installed."
        python3 --version
    else
        echo "Python 3 not found. Installing..."
        $UPDATE_CMD
        $PKG_MANAGER python3
    fi
}

# FEATURE 4: Pip Version Verification
# Verifies pip is available and prints the version
check_pip() {
    pretty_print "Checking for Pip (Python Package Manager)..."

    if command -v pip3 &> /dev/null; then
        echo "Pip is available."
        pip3 --version
    else
        echo "Pip is missing. Attempting to install pip..."
        # On many systems, python3-pip is a separate package
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            sudo apt-get install -y python3-pip
        else
            echo "Please install pip manually for your system."
            exit 1
        fi
    fi
}

#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
VENV_NAME="jupyter_env"

# ==========================================
# FUNCTION DEFINITIONS
# ==========================================

pretty_print() {
    local message="$1"
    printf "\n%s\n\n" ">>> $message"
}

detect_os() {
    pretty_print "Detecting Operating System..."
    case "$OSTYPE" in
        linux-gnu*)
            echo "OS Detected: Linux"
            # We add python3-venv here because it is required to create environments
            PKG_MANAGER="sudo apt-get install -y"
            UPDATE_CMD="sudo apt-get update"
            VENV_PACKAGE="python3-venv"
            ;;
        darwin*)
            echo "OS Detected: macOS"
            PKG_MANAGER="brew install"
            UPDATE_CMD="brew update"
            VENV_PACKAGE="python3" # usually included with python in brew
            ;;
        *)
            echo "Unknown OS: $OSTYPE"
            exit 1
            ;;
    esac
}

check_and_install_python() {
    pretty_print "Checking for Python 3 and Venv support..."

    if command -v python3 &> /dev/null; then
        echo "Python 3 is installed."
    else
        echo "Python 3 not found. Installing..."
        $UPDATE_CMD
        $PKG_MANAGER python3
    fi

    # Ensure venv module is installed (Critical for Linux)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        dpkg -s $VENV_PACKAGE &> /dev/null
        if [ $? -ne 0 ]; then
            echo "Installing python3-venv..."
            $PKG_MANAGER $VENV_PACKAGE
        fi
    fi
}

create_virtual_env() {
    pretty_print "Creating Virtual Environment ($VENV_NAME)..."
    
    # Check if the directory already exists
    if [ -d "$VENV_NAME" ]; then
        echo "Virtual environment '$VENV_NAME' already exists."
    else
        # Create the venv
        python3 -m venv "$VENV_NAME"
        
        if [ $? -eq 0 ]; then
             echo "Successfully created '$VENV_NAME'."
        else
             echo "Failed to create virtual environment."
             exit 1
        fi
    fi
}

install_jupyter_in_venv() {
    pretty_print "Installing Jupyter Notebook inside Virtual Environment..."
    
    # We use the pip executable INSIDE the venv folder
    # This bypasses the 'externally-managed-environment' error
    ./$VENV_NAME/bin/pip install notebook
    
    if [ $? -eq 0 ]; then
        echo "Jupyter Notebook successfully installed in '$VENV_NAME'."
    else
        echo "Jupyter installation failed."
        exit 1
    fi
}

# ==========================================
# MAIN LOGIC
# ==========================================

pretty_print "Starting Setup (Safe Mode)"

# 1. Detect OS
detect_os

# 2. Ensure Python and Venv tools are installed
check_and_install_python

# 3. Create the isolated environment
create_virtual_env

# 4. Install Jupyter into that environment
install_jupyter_in_venv

pretty_print "Setup Complete!"
echo "To use Jupyter, run this command:"
echo "source $VENV_NAME/bin/activate && jupyter notebook"
}

# ==========================================
# MAIN LOGIC
# ==========================================

pretty_print "Starting Environment Setup"

# 1. Identify the OS and set package manager variables
detect_os

# 2. Ensure Python is present
check_and_install_python

# 3. Ensure Pip is present
check_pip

# 4. Install Jupyter Notebook
install_jupyter

pretty_print "Setup Complete!
