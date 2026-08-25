#!/usr/bin/env bash

# ============================================================
# Luxury Touch Massage
# Linux V1 Bootstrap / Project Setup
#
# Purpose:
#   1. Bootstrap basic Linux development requirements
#   2. Download the source repository
#   3. Inspect the project
#   4. Locate the project setup/control center
#   5. Prepare for future dependency installation
#
# Repository:
#   https://github.com/Personal-kung/junko-san_project
#
# IMPORTANT:
#   This script does NOT modify Firebase data.
#   This script does NOT authenticate Firebase automatically.
#   This script does NOT deploy anything.
# ============================================================

set -Eeuo pipefail

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

REPO_URL="https://github.com/Personal-kung/junko-san_project"

DEFAULT_PROJECT_DIR="${HOME}/junko-san_project"

SETUP_VERSION="1.0.0"

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

SCRIPT_START="$(date '+%Y-%m-%d %H:%M:%S')"

log_info() {
    echo -e "${BLUE}ℹ${RESET} $*"
}

log_success() {
    echo -e "${GREEN}✓${RESET} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${RESET} $*"
}

log_error() {
    echo -e "${RED}✗${RESET} $*" >&2
}

log_step() {
    echo
    echo -e "${CYAN}${BOLD}==> $*${RESET}"
}

# ------------------------------------------------------------
# Error handling
# ------------------------------------------------------------

on_error() {
    local exit_code=$?
    local line_number=$1

    echo
    log_error "Setup failed."
    log_error "Line: ${line_number}"
    log_error "Exit code: ${exit_code}"
    echo

    echo "Nothing in Firebase has been modified by this bootstrap."
    echo

    exit "${exit_code}"
}

trap 'on_error ${LINENO}' ERR

# ------------------------------------------------------------
# Banner
# ------------------------------------------------------------

show_banner() {
    clear 2>/dev/null || true

    echo
    echo "============================================================"
    echo "              LUXURY TOUCH MASSAGE"
    echo "              PROJECT BOOTSTRAP"
    echo "============================================================"
    echo
    echo "Linux V1"
    echo "Setup version: ${SETUP_VERSION}"
    echo
    echo "Repository:"
    echo "${REPO_URL}"
    echo
}

# ------------------------------------------------------------
# OS Detection
# ------------------------------------------------------------

detect_os() {
    log_step "Detecting operating system"

    if [[ ! -f /etc/os-release ]]; then
        log_warning "Could not identify Linux distribution."
        return
    fi

    # shellcheck disable=SC1091
    source /etc/os-release

    OS_NAME="${NAME:-Unknown}"
    OS_ID="${ID:-unknown}"
    OS_VERSION="${VERSION_ID:-unknown}"

    log_success "Operating system: ${OS_NAME}"
    log_info "Distribution ID: ${OS_ID}"
    log_info "Version: ${OS_VERSION}"

    ARCH="$(uname -m)"

    log_success "Architecture: ${ARCH}"
}

# ------------------------------------------------------------
# Privilege detection
# ------------------------------------------------------------

detect_privileges() {
    log_step "Checking user privileges"

    if [[ "${EUID}" -eq 0 ]]; then
        log_warning "Running as root."

        echo
        echo "Running project setup as root is not recommended."
        echo "The script will continue, but project files may become"
        echo "owned by root."
        echo
    else
        log_success "Running as user: ${USER:-unknown}"
    fi

    if command -v sudo >/dev/null 2>&1; then
        log_success "sudo available"
    else
        log_warning "sudo not found"
    fi
}

# ------------------------------------------------------------
# Package manager detection
# ------------------------------------------------------------

PACKAGE_MANAGER=""

detect_package_manager() {
    log_step "Detecting Linux package manager"

    if command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
        log_success "Package manager: apt"
        return
    fi

    if command -v dnf >/dev/null 2>&1; then
        PACKAGE_MANAGER="dnf"
        log_success "Package manager: dnf"
        return
    fi

    if command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
        log_success "Package manager: yum"
        return
    fi

    if command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER="pacman"
        log_success "Package manager: pacman"
        return
    fi

    if command -v zypper >/dev/null 2>&1; then
        PACKAGE_MANAGER="zypper"
        log_success "Package manager: zypper"
        return
    fi

    if command -v apk >/dev/null 2>&1; then
        PACKAGE_MANAGER="apk"
        log_success "Package manager: apk"
        return
    fi

    log_warning "No supported package manager detected."
}

# ------------------------------------------------------------
# Privileged command helper
# ------------------------------------------------------------

run_privileged() {
    if [[ "${EUID}" -eq 0 ]]; then
        "$@"
    elif command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        log_error "This operation requires administrator privileges."
        log_error "sudo is not installed."
        return 1
    fi
}

# ------------------------------------------------------------
# Package installation
# ------------------------------------------------------------

install_package() {
    local package="$1"

    case "${PACKAGE_MANAGER}" in

        apt)
            run_privileged apt-get update
            run_privileged apt-get install -y "${package}"
            ;;

        dnf)
            run_privileged dnf install -y "${package}"
            ;;

        yum)
            run_privileged yum install -y "${package}"
            ;;

        pacman)
            run_privileged pacman -Sy --noconfirm "${package}"
            ;;

        zypper)
            run_privileged zypper --non-interactive install "${package}"
            ;;

        apk)
            run_privileged apk add "${package}"
            ;;

        *)
            log_error "No supported package manager available."
            return 1
            ;;
    esac
}

# ------------------------------------------------------------
# Command availability
# ------------------------------------------------------------

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ------------------------------------------------------------
# Git bootstrap
# ------------------------------------------------------------

ensure_git() {
    log_step "Checking Git"

    if command_exists git; then
        log_success "Git already installed"

        git --version

        return
    fi

    log_warning "Git is not installed."

    if [[ -z "${PACKAGE_MANAGER}" ]]; then
        log_error "A supported package manager was not found."
        echo
        echo "Please install Git manually and run this script again."
        echo
        echo "Repository:"
        echo "${REPO_URL}"
        echo
        exit 1
    fi

    echo
    echo "Git is required to download the project."
    echo

    read -r -p "Install Git now? [Y/n]: " answer

    answer="${answer:-Y}"

    if [[ "${answer}" =~ ^[Yy]$ ]]; then
        install_package git

        if command_exists git; then
            log_success "Git installed successfully"
            git --version
        else
            log_error "Git installation completed but Git is not available."
            log_error "You may need to restart the terminal."
            exit 1
        fi
    else
        log_error "Git is required."
        exit 1
    fi
}

# ------------------------------------------------------------
# Basic bootstrap tools
# ------------------------------------------------------------

ensure_basic_tools() {
    log_step "Checking basic command-line tools"

    local missing=()

    command_exists curl || missing+=("curl")
    command_exists unzip || missing+=("unzip")

    if [[ "${#missing[@]}" -eq 0 ]]; then
        log_success "Basic tools available"
        return
    fi

    log_warning "Missing tools: ${missing[*]}"

    if [[ -z "${PACKAGE_MANAGER}" ]]; then
        log_warning "Cannot automatically install missing tools."
        return
    fi

    echo
    read -r -p "Install missing basic tools? [Y/n]: " answer

    answer="${answer:-Y}"

    if [[ ! "${answer}" =~ ^[Yy]$ ]]; then
        log_warning "Continuing without installing optional tools."
        return
    fi

    for package in "${missing[@]}"; do
        install_package "${package}" || {
            log_warning "Could not install ${package}"
        }
    done
}

# ------------------------------------------------------------
# Project directory selection
# ------------------------------------------------------------

select_project_directory() {
    log_step "Selecting project directory"

    echo
    echo "Where should the project be downloaded?"
    echo
    echo "Default:"
    echo "  ${DEFAULT_PROJECT_DIR}"
    echo

    read -r -p "Project directory [Enter for default]: " PROJECT_DIR

    PROJECT_DIR="${PROJECT_DIR:-${DEFAULT_PROJECT_DIR}}"

    # Expand ~ manually if supplied.
    if [[ "${PROJECT_DIR}" == "~/"* ]]; then
        PROJECT_DIR="${HOME}/${PROJECT_DIR#~/}"
    fi

    PROJECT_DIR="$(cd "$(dirname "${PROJECT_DIR}")" 2>/dev/null && pwd)/$(basename "${PROJECT_DIR}")" \
        2>/dev/null || echo "${PROJECT_DIR}"

    echo
    log_info "Project directory:"
    echo "  ${PROJECT_DIR}"
}

# ------------------------------------------------------------
# Existing project detection
# ------------------------------------------------------------

is_project_directory() {
    local directory="$1"

    [[ -d "${directory}/.git" ]] &&
    [[ -d "${directory}/massage_admin_app" ]]
}

# ------------------------------------------------------------
# Clone repository
# ------------------------------------------------------------

download_project() {
    log_step "Obtaining source project"

    if is_project_directory "${PROJECT_DIR}"; then
        log_success "Existing project detected"

        cd "${PROJECT_DIR}"

        if git remote get-url origin >/dev/null 2>&1; then
            CURRENT_REMOTE="$(git remote get-url origin)"

            log_info "Git remote:"
            echo "  ${CURRENT_REMOTE}"

            if [[ "${CURRENT_REMOTE}" != "${REPO_URL}" ]]; then
                log_warning "Existing project has a different Git remote."
                log_warning "The bootstrap will NOT change it."
            fi
        fi

        return
    fi

    if [[ -e "${PROJECT_DIR}" ]]; then
        log_error "Target directory already exists but is not recognized as the project:"
        echo
        echo "  ${PROJECT_DIR}"
        echo
        log_error "Choose another directory or inspect it manually."
        exit 1
    fi

    mkdir -p "$(dirname "${PROJECT_DIR}")"

    log_info "Cloning repository..."

    git clone "${REPO_URL}" "${PROJECT_DIR}"

    cd "${PROJECT_DIR}"

    log_success "Project downloaded"
}

# ------------------------------------------------------------
# Git information
# ------------------------------------------------------------

show_git_information() {
    log_step "Reading source project information"

    cd "${PROJECT_DIR}"

    echo
    echo "Repository:"
    git remote get-url origin 2>/dev/null || echo "Unknown"

    echo
    echo "Branch:"
    git branch --show-current 2>/dev/null || echo "Unknown"

    echo
    echo "Commit:"
    git rev-parse --short HEAD 2>/dev/null || echo "Unknown"

    echo
    echo "Latest commit:"
    git log -1 --pretty=format:'%h - %s (%an, %ad)' --date=short 2>/dev/null || true

    echo
    echo
}

# ------------------------------------------------------------
# Project structure inspection
# ------------------------------------------------------------

inspect_project() {
    log_step "Inspecting project structure"

    cd "${PROJECT_DIR}"

    echo

    local required_paths=(
        "massage_admin_app"
        "massage_admin_app/lib"
        "massage_admin_app/client_site"
        "massage_admin_app/pubspec.yaml"
    )

    local path

    for path in "${required_paths[@]}"; do
        if [[ -e "${path}" ]]; then
            log_success "${path}"
        else
            log_warning "Missing: ${path}"
        fi
    done

    echo

    local legacy_paths=(
        "server.js"
        "data.json"
        "bookings.json"
    )

    for path in "${legacy_paths[@]}"; do
        if [[ -e "${path}" ]]; then
            log_warning "Legacy file detected: ${path}"
        fi
    done
}

# ------------------------------------------------------------
# Project documentation
# ------------------------------------------------------------

show_project_information() {
    log_step "Reading available project documentation"

    cd "${PROJECT_DIR}"

    local docs=(
        "README.md"
        "DEVELOPER_GUIDE.md"
        "USER_MANUAL.md"
    )

    local found=0

    for doc in "${docs[@]}"; do
        if [[ -f "${doc}" ]]; then
            log_success "Found ${doc}"
            found=1
        fi
    done

    if [[ "${found}" -eq 0 ]]; then
        log_warning "No top-level project documentation found."
    fi
}

# ------------------------------------------------------------
# Firebase configuration detection
# ------------------------------------------------------------

inspect_firebase_configuration() {
    log_step "Inspecting Firebase configuration"

    cd "${PROJECT_DIR}"

    local firebase_files=(
        "firebase.json"
        ".firebaserc"
        "firestore.rules"
        "firestore.indexes.json"
        "massage_admin_app/lib/firebase_options.dart"
    )

    local found=0

    for file in "${firebase_files[@]}"; do
        if [[ -f "${file}" ]]; then
            log_success "${file}"
            found=1
        fi
    done

    if [[ "${found}" -eq 0 ]]; then
        log_warning "No standard Firebase configuration files detected."
    fi

    if [[ -f "massage_admin_app/client_site/index.html" ]]; then
        if grep -qi "firebase" "massage_admin_app/client_site/index.html"; then
            log_success "Firebase references detected in customer site"
        else
            log_warning "Customer site Firebase configuration not detected"
        fi
    fi
}

# ------------------------------------------------------------
# Local project state
# ------------------------------------------------------------

initialize_local_state() {
    log_step "Initializing local project state"

    cd "${PROJECT_DIR}"

    mkdir -p \
        ".project/state" \
        ".project/logs" \
        ".project/backups"

    if [[ ! -f ".project/state/setup.json" ]]; then
        cat > ".project/state/setup.json" <<EOF
{
  "setup_version": "${SETUP_VERSION}",
  "repository": "${REPO_URL}",
  "initialized_at": "$(date -Iseconds)"
}
EOF

        log_success "Created local project state"
    else
        log_success "Local project state already exists"
    fi

    # Ensure .project is ignored.
    if [[ -f ".gitignore" ]]; then
        if ! grep -qxF ".project/" ".gitignore"; then
            echo ".project/" >> ".gitignore"
            log_success "Added .project/ to .gitignore"
        else
            log_success ".project/ already ignored"
        fi
    else
        cat > ".gitignore" <<'EOF'
.project/
EOF
        log_success "Created .gitignore"
    fi
}

# ------------------------------------------------------------
# Dependency status
# ------------------------------------------------------------

show_dependency_status() {
    log_step "Development dependency status"

    echo

    check_command() {
        local name="$1"
        local command="$2"

        if command_exists "${command}"; then
            printf "${GREEN}✓${RESET} %-18s" "${name}"

            case "${command}" in
                git)
                    git --version 2>/dev/null | head -n 1
                    ;;
                curl)
                    curl --version 2>/dev/null | head -n 1
                    ;;
                python3)
                    python3 --version 2>/dev/null
                    ;;
                node)
                    node --version 2>/dev/null
                    ;;
                flutter)
                    flutter --version 2>/dev/null | head -n 1
                    ;;
                firebase)
                    firebase --version 2>/dev/null | head -n 1
                    ;;
                *)
                    echo
                    ;;
            esac
        else
            printf "${YELLOW}⚠${RESET} %-18s not installed\n" "${name}"
        fi
    }

    check_command "Git" "git"
    check_command "Curl" "curl"
    check_command "Python 3" "python3"
    check_command "Node.js" "node"
    check_command "Flutter" "flutter"
    check_command "Firebase CLI" "firebase"
}

# ------------------------------------------------------------
# Firebase CLI detection
# ------------------------------------------------------------

check_firebase_cli() {
    log_step "Checking Firebase CLI"

    if command_exists firebase; then
        log_success "Firebase CLI installed"
        firebase --version || true
        return
    fi

    log_warning "Firebase CLI is not installed."

    if command_exists npm; then
        echo
        echo "npm is available."
        echo
        read -r -p "Install Firebase CLI using npm? [y/N]: " answer

        if [[ "${answer}" =~ ^[Yy]$ ]]; then
            npm install -g firebase-tools

            if command_exists firebase; then
                log_success "Firebase CLI installed"
            else
                log_warning "Firebase CLI installed but is not visible in PATH."
            fi
        fi
    else
        log_info "Node.js/npm are not currently installed."
        log_info "Firebase CLI installation will be available from the Control Center."
    fi
}

# ------------------------------------------------------------
# Flutter dependency check
# ------------------------------------------------------------

check_flutter_project() {
    log_step "Checking Flutter project"

    local flutter_project="${PROJECT_DIR}/massage_admin_app"

    if [[ ! -f "${flutter_project}/pubspec.yaml" ]]; then
        log_warning "Flutter pubspec.yaml not found."
        return
    fi

    if ! command_exists flutter; then
        log_warning "Flutter is not installed."
        return
    fi

    cd "${flutter_project}"

    log_info "Running flutter pub get..."

    if flutter pub get; then
        log_success "Flutter dependencies resolved"
    else
        log_warning "Flutter dependency installation failed."
    fi
}

# ------------------------------------------------------------
# Project status
# ------------------------------------------------------------

project_status() {
    echo
    echo "============================================================"
    echo "                    PROJECT STATUS"
    echo "============================================================"
    echo

    echo "Project:"
    echo "  ${PROJECT_DIR}"
    echo

    echo "Repository:"
    cd "${PROJECT_DIR}"
    git remote get-url origin 2>/dev/null || echo "  Unknown"

    echo

    echo "Current commit:"
    git rev-parse --short HEAD 2>/dev/null || echo "  Unknown"

    echo

    show_dependency_status

    echo
    inspect_firebase_configuration

    echo
}

# ------------------------------------------------------------
# Customer website
# ------------------------------------------------------------

run_customer_site() {
    log_step "Starting customer website"

    if ! command_exists python3; then
        log_error "Python 3 is not installed."
        echo
        echo "The current customer site development workflow uses:"
        echo
        echo "  python3 -m http.server 8000"
        echo
        return
    fi

    local site_dir="${PROJECT_DIR}/massage_admin_app/client_site"

    if [[ ! -d "${site_dir}" ]]; then
        log_error "Customer site directory not found."
        return
    fi

    cd "${site_dir}"

    echo
    echo "Customer website:"
    echo "  http://localhost:8000"
    echo
    echo "Press Ctrl+C to stop."
    echo

    python3 -m http.server 8000
}

# ------------------------------------------------------------
# Flutter admin
# ------------------------------------------------------------

run_flutter_admin() {
    log_step "Starting Flutter Admin application"

    if ! command_exists flutter; then
        log_error "Flutter is not installed."
        return
    fi

    cd "${PROJECT_DIR}/massage_admin_app"

    flutter run
}

# ------------------------------------------------------------
# Build menu
# ------------------------------------------------------------

build_flutter() {
    if ! command_exists flutter; then
        log_error "Flutter is not installed."
        return
    fi

    while true; do

        echo
        echo "============================================================"
        echo "                    FLUTTER BUILD"
        echo "============================================================"
        echo
        echo "1. Web"
        echo "2. Android APK"
        echo "3. Linux"
        echo "0. Back"
        echo

        read -r -p "Select: " choice

        case "${choice}" in

            1)
                cd "${PROJECT_DIR}/massage_admin_app"
                flutter build web
                ;;

            2)
                cd "${PROJECT_DIR}/massage_admin_app"
                flutter build apk
                ;;

            3)
                cd "${PROJECT_DIR}/massage_admin_app"
                flutter build linux
                ;;

            0)
                return
                ;;

            *)
                log_warning "Invalid selection."
                ;;

        esac
    done
}

# ------------------------------------------------------------
# Firebase menu
# ------------------------------------------------------------

firebase_menu() {

    while true; do

        echo
        echo "============================================================"
        echo "                       FIREBASE"
        echo "============================================================"
        echo
        echo "1. Check Firebase CLI"
        echo "2. Login"
        echo "3. List Projects"
        echo "4. Current Firebase Project"
        echo "5. Select / Configure Project"
        echo "6. Logout"
        echo "0. Back"
        echo

        read -r -p "Select: " choice

        case "${choice}" in

            1)
                if command_exists firebase; then
                    firebase --version
                else
                    log_warning "Firebase CLI is not installed."
                fi
                ;;

            2)
                if command_exists firebase; then
                    firebase login
                else
                    log_error "Firebase CLI is not installed."
                fi
                ;;

            3)
                if command_exists firebase; then
                    firebase projects:list
                else
                    log_error "Firebase CLI is not installed."
                fi
                ;;

            4)
                cd "${PROJECT_DIR}"

                if command_exists firebase; then
                    firebase use
                else
                    log_error "Firebase CLI is not installed."
                fi
                ;;

            5)
                cd "${PROJECT_DIR}"

                if command_exists firebase; then
                    firebase use --add
                else
                    log_error "Firebase CLI is not installed."
                fi
                ;;

            6)
                if command_exists firebase; then
                    firebase logout
                else
                    log_error "Firebase CLI is not installed."
                fi
                ;;

            0)
                return
                ;;

            *)
                log_warning "Invalid selection."
                ;;

        esac
    done
}

# ------------------------------------------------------------
# Database / backup menu
# ------------------------------------------------------------

database_menu() {

    while true; do

        echo
        echo "============================================================"
        echo "                   DATABASE & BACKUPS"
        echo "============================================================"
        echo
        echo "1. Database Status"
        echo "2. Create Backup"
        echo "3. List Backups"
        echo "4. Verify Backup"
        echo "5. Restore Backup"
        echo "0. Back"
        echo

        read -r -p "Select: " choice

        case "${choice}" in

            1)
                echo
                log_info "Database status is not fully implemented in V1."
                echo
                echo "Future implementation:"
                echo "  Firebase authentication"
                echo "  Firestore connectivity"
                echo "  Firestore project validation"
                ;;

            2)
                echo
                log_warning "Backup creation is intentionally not implemented in V1."
                echo
                echo "Future backups will use an official Firestore"
                echo "export/import mechanism."
                ;;

            3)
                echo
                echo "Local backups:"
                echo

                find "${PROJECT_DIR}/.project/backups" \
                    -maxdepth 1 \
                    -type f \
                    -printf '%f\n' 2>/dev/null || true
                ;;

            4)
                echo
                log_warning "Backup verification is not implemented in V1."
                ;;

            5)
                echo
                log_warning "Restore is intentionally disabled in V1."
                echo
                echo "No database data will be modified."
                ;;

            0)
                return
                ;;

            *)
                log_warning "Invalid selection."
                ;;

        esac
    done
}

# ------------------------------------------------------------
# Diagnostics
# ------------------------------------------------------------

diagnostics() {

    local diagnostics_file="${PROJECT_DIR}/.project/logs/diagnostics.txt"

    {
        echo "Luxury Touch Massage Diagnostics"
        echo "================================"
        echo
        echo "Date:"
        date
        echo
        echo "OS:"
        uname -a
        echo
        echo "Distribution:"
        if [[ -f /etc/os-release ]]; then
            cat /etc/os-release
        fi
        echo
        echo "Architecture:"
        uname -m
        echo
        echo "User:"
        whoami
        echo
        echo "Git:"
        git --version 2>&1 || true
        echo
        echo "Python:"
        python3 --version 2>&1 || true
        echo
        echo "Node:"
        node --version 2>&1 || true
        echo
        echo "npm:"
        npm --version 2>&1 || true
        echo
        echo "Flutter:"
        flutter --version 2>&1 | head -n 5 || true
        echo
        echo "Firebase:"
        firebase --version 2>&1 || true
        echo
        echo "Repository:"
        cd "${PROJECT_DIR}"
        git remote get-url origin 2>&1 || true
        echo
        echo "Commit:"
        git rev-parse HEAD 2>&1 || true
    } > "${diagnostics_file}"

    log_success "Diagnostics written to:"
    echo
    echo "  ${diagnostics_file}"
    echo

    cat "${diagnostics_file}"
}

# ------------------------------------------------------------
# Validate project
# ------------------------------------------------------------

validate_project() {
    log_step "Validating project"

    inspect_project

    echo

    inspect_firebase_configuration

    echo

    if command_exists flutter; then
        check_flutter_project
    else
        log_warning "Flutter validation skipped."
    fi

    echo
    log_success "Project validation completed."
}

# ------------------------------------------------------------
# Setup / repair
# ------------------------------------------------------------

setup_repair() {

    echo
    echo "============================================================"
    echo "                    SETUP / REPAIR"
    echo "============================================================"
    echo
    echo "1. Check basic dependencies"
    echo "2. Check Firebase CLI"
    echo "3. Check Flutter project"
    echo "4. Reinitialize local state"
    echo "5. Full validation"
    echo "0. Back"
    echo

    read -r -p "Select: " choice

    case "${choice}" in

        1)
            ensure_basic_tools
            show_dependency_status
            ;;

        2)
            check_firebase_cli
            ;;

        3)
            check_flutter_project
            ;;

        4)
            initialize_local_state
            ;;

        5)
            validate_project
            ;;

        0)
            return
            ;;

        *)
            log_warning "Invalid selection."
            ;;

    esac
}

# ------------------------------------------------------------
# Main Control Center
# ------------------------------------------------------------

control_center() {

    while true; do

        echo
        echo "============================================================"
        echo "             LUXURY TOUCH MASSAGE"
        echo "             PROJECT CONTROL CENTER"
        echo "============================================================"
        echo
        echo "Project:"
        echo "  ${PROJECT_DIR}"
        echo
        echo "1. Project Status"
        echo "2. Check Dependencies"
        echo "3. Validate Project"
        echo "4. Firebase"
        echo "5. Database & Backups"
        echo "6. Run Customer Website"
        echo "7. Run Flutter Admin"
        echo "8. Build Flutter"
        echo "9. Diagnostics"
        echo "10. Setup / Repair"
        echo "0. Exit"
        echo

        read -r -p "Select: " choice

        case "${choice}" in

            1)
                project_status
                ;;

            2)
                show_dependency_status
                ;;

            3)
                validate_project
                ;;

            4)
                firebase_menu
                ;;

            5)
                database_menu
                ;;

            6)
                run_customer_site
                ;;

            7)
                run_flutter_admin
                ;;

            8)
                build_flutter
                ;;

            9)
                diagnostics
                ;;

            10)
                setup_repair
                ;;

            0)
                echo
                log_success "Goodbye."
                exit 0
                ;;

            *)
                log_warning "Invalid selection."
                ;;

        esac
    done
}

# ------------------------------------------------------------
# Main
# ------------------------------------------------------------

main() {

    show_banner

    detect_os

    detect_privileges

    detect_package_manager

    ensure_git

    ensure_basic_tools

    select_project_directory

    download_project

    show_git_information

    inspect_project

    show_project_information

    inspect_firebase_configuration

    initialize_local_state

    show_dependency_status

    check_firebase_cli

    check_flutter_project

    echo
    echo "============================================================"
    echo "                  BOOTSTRAP COMPLETE"
    echo "============================================================"
    echo
    echo "Project:"
    echo "  ${PROJECT_DIR}"
    echo
    echo "Source:"
    echo "  ${REPO_URL}"
    echo
    echo "The application itself has not been modified."
    echo "Firebase data has not been modified."
    echo "Firebase authentication has not been performed automatically."
    echo

    control_center
}

main "$@"
