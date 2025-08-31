#!/bin/bash

# Echo Plugins Deployment Script
# Deploys the echo-plugins package to PyPI via Poetry

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get version from pyproject.toml (current working directory)
get_pyproject_version() {
    grep '^version = ' pyproject.toml | sed 's/version = "\(.*\)"/\1/'
}

# Calculate next versions from a semver string X.Y.Z
calculate_next_versions() {
    local current_version=$1
    local major minor patch
    IFS='.' read -r major minor patch <<< "$current_version"
    local next_patch="$major.$minor.$((patch + 1))"
    local next_minor="$major.$((minor + 1)).0"
    local next_major="$((major + 1)).0.0"
    echo "$next_patch $next_minor $next_major"
}

# Ensure we are in the plugins directory (has pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    print_error "pyproject.toml not found. Run this script from the plugins directory."
    exit 1
fi

# Ensure Poetry is installed
if ! command -v poetry >/dev/null 2>&1; then
    print_error "Poetry is not installed. Install it from https://python-poetry.org/docs/"
    exit 1
fi

# Warn on uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
    print_warning "You have uncommitted changes. Consider committing before deployment."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Deployment cancelled."
        exit 0
    fi
fi

PACKAGE_NAME="echo-plugins"
CURRENT_VERSION=$(get_pyproject_version)
print_status "Package: $PACKAGE_NAME"
print_status "Current version in pyproject.toml: $CURRENT_VERSION"

# Ask for version bump type
read -r NEXT_PATCH NEXT_MINOR NEXT_MAJOR <<< "$(calculate_next_versions "$CURRENT_VERSION")"
echo
echo "Select version bump type:"
echo "1) patch ($CURRENT_VERSION -> $NEXT_PATCH)"
echo "2) minor ($CURRENT_VERSION -> $NEXT_MINOR)"
echo "3) major ($CURRENT_VERSION -> $NEXT_MAJOR)"
echo "4) Skip version bump"
read -p "Enter choice (1-4): " -n 1 -r
echo

case $REPLY in
    1)
        print_status "Bumping patch version..."
        poetry version patch
        ;;
    2)
        print_status "Bumping minor version..."
        poetry version minor
        ;;
    3)
        print_status "Bumping major version..."
        poetry version major
        ;;
    4)
        print_status "Skipping version bump..."
        ;;
    *)
        print_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

NEW_VERSION=$(get_pyproject_version)
print_status "New version: $NEW_VERSION"

# Clean previous builds
print_status "Cleaning previous builds..."
rm -rf dist/ build/ *.egg-info/

# Build package
print_status "Building package..."
poetry build

# Verify build
if [ ! -d "dist" ] || [ -z "$(ls -A dist/)" ]; then
    print_error "Build failed. No distribution files found."
    exit 1
fi

print_success "Package built successfully!"
echo
print_status "Files to be uploaded:"
ls -la dist/

# Confirm publish
echo
read -p "Deploy $PACKAGE_NAME $NEW_VERSION to PyPI? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Deployment cancelled."
    exit 0
fi

print_status "Publishing to PyPI..."
poetry publish

print_success "Package deployed successfully to PyPI!"
print_status "Version $NEW_VERSION is now available on PyPI."

# Optional git tag
read -p "Create git tag v$NEW_VERSION? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Creating git tag..."
    git tag -a "v$NEW_VERSION" -m "Release $PACKAGE_NAME version $NEW_VERSION"
    print_success "Git tag v$NEW_VERSION created!"
    print_warning "Don't forget to push the tag: git push origin v$NEW_VERSION"
fi

echo
print_success "Deployment completed successfully!"
print_status "Package: $PACKAGE_NAME"
print_status "Version: $NEW_VERSION"
print_status "PyPI URL: https://pypi.org/project/$PACKAGE_NAME/"


