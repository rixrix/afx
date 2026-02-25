#!/bin/bash
# AFX (AgenticFlow) Installer
# Usage:
#   Install:  ./install.sh /path/to/project
#   Update:   ./install.sh --update /path/to/project
#   Remote:   curl -sL https://raw.githubusercontent.com/rixrix/afx/main/install.sh | bash -s -- .
#
# Options:
#   --update          Update existing AFX installation (preserves user content)
#   --commands-only   Only install/update command assets (.claude + .codex)
#   --no-claude-md    Skip CLAUDE.md snippet integration
#   --no-agents-md    Skip AGENTS.md snippet integration
#   --no-docs         Skip copying AFX documentation to docs/agenticflowx/
#   --force           Overwrite all existing files (fresh install)
#   --dry-run         Show what would be changed without making changes

set -e

# AFX Version (dynamic from CHANGELOG.md)
AFX_REPO="rixrix/afx"
AFX_VERSION=$(curl -sL "https://raw.githubusercontent.com/${AFX_REPO}/main/CHANGELOG.md" | awk '/^## \[/ {print substr($2, 2, length($2)-2); exit}')
if [ -z "$AFX_VERSION" ]; then
    AFX_VERSION="Unknown"
fi

# Boundary markers for CLAUDE.md
AFX_START_MARKER="<!-- AFX:START - Managed by AFX. Do not edit manually. -->"
AFX_END_MARKER="<!-- AFX:END -->"
# Boundary markers for AGENTS.md
AFX_AGENTS_START_MARKER="<!-- AFX-CODEX:START - Managed by AFX. Do not edit manually. -->"
AFX_AGENTS_END_MARKER="<!-- AFX-CODEX:END -->"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default options
UPDATE_MODE=false
COMMANDS_ONLY=false
NO_CLAUDE_MD=false
NO_AGENTS_MD=false
NO_DOCS=false
FORCE=false
DRY_RUN=false
TARGET_DIR=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --update)
            UPDATE_MODE=true
            shift
            ;;
        --commands-only)
            COMMANDS_ONLY=true
            shift
            ;;
        --no-claude-md)
            NO_CLAUDE_MD=true
            shift
            ;;
        --no-agents-md)
            NO_AGENTS_MD=true
            shift
            ;;
        --no-docs)
            NO_DOCS=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "AFX Installer v${AFX_VERSION}"
            echo ""
            echo "Usage: ./install.sh [OPTIONS] <target-project-path>"
            echo ""
            echo "Options:"
            echo "  --update          Update existing AFX installation"
            echo "  --commands-only   Only install/update command assets (.claude + .codex)"
            echo "  --no-claude-md    Skip CLAUDE.md snippet integration"
            echo "  --no-agents-md    Skip AGENTS.md snippet integration"
            echo "  --no-docs         Skip copying AFX documentation to docs/agenticflowx/"
            echo "  --force           Overwrite all files (fresh install)"
            echo "  --dry-run         Preview changes without applying"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Examples:"
            echo "  # Fresh install"
            echo "  ./install.sh /path/to/my-project"
            echo ""
            echo "  # Update existing installation"
            echo "  ./install.sh --update ."
            echo ""
            echo "  # Remote install"
            echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/main/install.sh | bash -s -- ."
            echo ""
            echo "  # Remote update"
            echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/main/install.sh | bash -s -- --update ."
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# Validate target directory
if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target project path required${NC}"
    echo "Usage: ./install.sh [--update] /path/to/project"
    exit 1
fi

# Resolve to absolute path
TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

# Header
if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${BLUE}AFX Updater v${AFX_VERSION}${NC}"
else
    echo -e "${BLUE}AFX Installer v${AFX_VERSION}${NC}"
fi
echo "Target: $TARGET_DIR"
if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}(Dry run - no changes will be made)${NC}"
fi
echo ""

# Determine AFX source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/.afx.yaml.template" ]; then
    echo -e "${YELLOW}Downloading AFX from GitHub...${NC}"
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    git clone --depth 1 --quiet https://github.com/${AFX_REPO}.git "$TEMP_DIR/afx" 2>/dev/null || {
        echo -e "${RED}Error: Failed to clone AFX repository${NC}"
        echo "Check your internet connection or clone manually:"
        echo "  git clone https://github.com/${AFX_REPO}.git"
        exit 1
    }
    AFX_DIR="$TEMP_DIR/afx"
else
    AFX_DIR="$SCRIPT_DIR"
fi

# Track changes
INSTALLED=()
UPDATED=()
SKIPPED=()

# Helper: Install or update a file
install_file() {
    local src="$1"
    local dest="$2"
    local desc="$3"
    local always_update="${4:-false}"

    if [ "$DRY_RUN" = "true" ]; then
        if [ -e "$dest" ]; then
            if [ "$UPDATE_MODE" = "true" ] || [ "$FORCE" = "true" ] || [ "$always_update" = "true" ]; then
                UPDATED+=("$desc (would update)")
            else
                SKIPPED+=("$desc (exists)")
            fi
        else
            INSTALLED+=("$desc (would create)")
        fi
        return 0
    fi

    if [ -e "$dest" ]; then
        if [ "$UPDATE_MODE" = "true" ] || [ "$FORCE" = "true" ] || [ "$always_update" = "true" ]; then
            mkdir -p "$(dirname "$dest")"
            cp -r "$src" "$dest"
            UPDATED+=("$desc")
        else
            SKIPPED+=("$desc (exists)")
        fi
    else
        mkdir -p "$(dirname "$dest")"
        cp -r "$src" "$dest"
        INSTALLED+=("$desc")
    fi
}

# Helper: Install or update a directory by replacing destination contents
install_directory() {
    local src="$1"
    local dest="$2"
    local desc="$3"
    local always_update="${4:-false}"

    if [ "$DRY_RUN" = "true" ]; then
        if [ -e "$dest" ]; then
            if [ "$UPDATE_MODE" = "true" ] || [ "$FORCE" = "true" ] || [ "$always_update" = "true" ]; then
                UPDATED+=("$desc (would update)")
            else
                SKIPPED+=("$desc (exists)")
            fi
        else
            INSTALLED+=("$desc (would create)")
        fi
        return 0
    fi

    if [ -e "$dest" ]; then
        if [ "$UPDATE_MODE" = "true" ] || [ "$FORCE" = "true" ] || [ "$always_update" = "true" ]; then
            rm -rf "$dest"
            mkdir -p "$(dirname "$dest")"
            cp -R "$src" "$dest"
            UPDATED+=("$desc")
        else
            SKIPPED+=("$desc (exists)")
        fi
    else
        mkdir -p "$(dirname "$dest")"
        cp -R "$src" "$dest"
        INSTALLED+=("$desc")
    fi
}

# ============================================================================
# 1. Install/Update Claude slash commands
# ============================================================================
echo -e "${BLUE}[1/7] Installing Claude slash commands...${NC}"
COMMANDS_DIR="$TARGET_DIR/.claude/commands"

if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$COMMANDS_DIR"
fi

for cmd in "$AFX_DIR"/.claude/commands/afx-*.md; do
    if [ -f "$cmd" ]; then
        filename=$(basename "$cmd")
        # Commands are always updated in update mode
        install_file "$cmd" "$COMMANDS_DIR/$filename" "Command: $filename" "$UPDATE_MODE"
    fi
done

# ============================================================================
# 2. Install/Update Codex skills
# ============================================================================
echo -e "${BLUE}[2/7] Installing Codex skills...${NC}"
CODEX_SKILLS_DIR="$TARGET_DIR/.codex/skills"

if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$CODEX_SKILLS_DIR"
fi

if [ -d "$AFX_DIR/.codex/skills" ]; then
    for skill_dir in "$AFX_DIR"/.codex/skills/afx-*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            install_directory "$skill_dir" "$CODEX_SKILLS_DIR/$skill_name" "Codex skill: $skill_name" "$UPDATE_MODE"
        fi
    done
fi

if [ "$COMMANDS_ONLY" = "true" ]; then
    echo ""
    echo -e "${GREEN}Commands processed!${NC}"
    echo ""
    [ ${#INSTALLED[@]} -gt 0 ] && echo "Installed: ${#INSTALLED[@]}" && printf '  + %s\n' "${INSTALLED[@]}"
    [ ${#UPDATED[@]} -gt 0 ] && echo "Updated: ${#UPDATED[@]}" && printf '  ~ %s\n' "${UPDATED[@]}"
    [ ${#SKIPPED[@]} -gt 0 ] && echo "Skipped: ${#SKIPPED[@]}" && printf '  - %s\n' "${SKIPPED[@]}"
    exit 0
fi

# ============================================================================
# 3. Install/Update templates
# ============================================================================
echo -e "${BLUE}[3/7] Installing templates...${NC}"
TEMPLATES_DIR="$TARGET_DIR/docs/agenticflowx/templates"

if [ -d "$AFX_DIR/templates" ]; then
    for tpl in "$AFX_DIR"/templates/*.md; do
        if [ -f "$tpl" ]; then
            filename=$(basename "$tpl")
            install_file "$tpl" "$TEMPLATES_DIR/$filename" "Template: $filename" "$UPDATE_MODE"
        fi
    done
fi

# ============================================================================
# 4. Create/Update .afx.yaml
# ============================================================================
echo -e "${BLUE}[4/7] Managing configuration...${NC}"
AFX_CONFIG="$TARGET_DIR/.afx.yaml"

if [ -f "$AFX_CONFIG" ]; then
    # Config exists - never overwrite unless --force (user customizations)
    if [ "$FORCE" = "true" ]; then
        install_file "$AFX_DIR/.afx.yaml.template" "$AFX_CONFIG" ".afx.yaml" "true"
    else
        SKIPPED+=(".afx.yaml (preserved - user config)")
    fi
else
    install_file "$AFX_DIR/.afx.yaml.template" "$AFX_CONFIG" ".afx.yaml"
fi

# ============================================================================
# 5. Update CLAUDE.md with boundary markers
# ============================================================================
if [ "$NO_CLAUDE_MD" != "true" ]; then
    echo -e "${BLUE}[5/7] Updating CLAUDE.md...${NC}"
    CLAUDE_MD="$TARGET_DIR/CLAUDE.md"
    SNIPPET_FILE="$AFX_DIR/prompts/complete.md"

    if [ -f "$SNIPPET_FILE" ]; then
        # Extract content after the separator line (skip header comments)
        SNIPPET_CONTENT=$(sed -n '/^---$/,$p' "$SNIPPET_FILE" | tail -n +2)

        # Wrap with boundary markers
        AFX_SECTION="${AFX_START_MARKER}
<!-- AFX Version: ${AFX_VERSION} -->

${SNIPPET_CONTENT}
${AFX_END_MARKER}"

        if [ "$DRY_RUN" = "true" ]; then
            if [ -f "$CLAUDE_MD" ]; then
                if grep -q "$AFX_START_MARKER" "$CLAUDE_MD" 2>/dev/null; then
                    UPDATED+=("CLAUDE.md AFX section (would update)")
                elif grep -q "## Documentation References\|## AgenticFlow" "$CLAUDE_MD" 2>/dev/null; then
                    SKIPPED+=("CLAUDE.md (has old AFX section - run with --force to migrate)")
                else
                    INSTALLED+=("CLAUDE.md AFX section (would append)")
                fi
            else
                INSTALLED+=("CLAUDE.md (would create)")
            fi
        else
            if [ -f "$CLAUDE_MD" ]; then
                if grep -q "$AFX_START_MARKER" "$CLAUDE_MD"; then
                    # Has boundary markers - replace the section safely
                    # 1. Print everything before the start marker
                    awk -v start="$AFX_START_MARKER" '
                        $0 == start { exit }
                        { print }
                    ' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"

                    # 2. Print the new section
                    echo "$AFX_SECTION" >> "$CLAUDE_MD.tmp"

                    # 3. Print everything after the end marker
                    awk -v end="$AFX_END_MARKER" '
                        BEGIN { skip=1 }
                        $0 == end { skip=0; next }
                        !skip { print }
                    ' "$CLAUDE_MD" >> "$CLAUDE_MD.tmp"

                    mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
                    UPDATED+=("CLAUDE.md AFX section")
                elif grep -q "## Documentation References\|## AgenticFlow" "$CLAUDE_MD"; then
                    # Has old-style AFX section without markers
                    if [ "$FORCE" = "true" ]; then
                        # Remove old section and add new with markers
                        # This is a best-effort removal
                        echo -e "${YELLOW}Warning: Migrating old AFX section to use boundary markers${NC}"
                        # Append new section (user should manually remove old)
                        echo "" >> "$CLAUDE_MD"
                        echo "$AFX_SECTION" >> "$CLAUDE_MD"
                        UPDATED+=("CLAUDE.md (migrated - please remove old AFX section manually)")
                    else
                        SKIPPED+=("CLAUDE.md (has old AFX section - use --force to migrate)")
                    fi
                else
                    # No AFX section - append with markers
                    echo "" >> "$CLAUDE_MD"
                    echo "$AFX_SECTION" >> "$CLAUDE_MD"
                    INSTALLED+=("CLAUDE.md AFX section")
                fi
            else
                # Create new CLAUDE.md with header + AFX section
                cat > "$CLAUDE_MD" << 'HEADER'
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

HEADER
                echo "$AFX_SECTION" >> "$CLAUDE_MD"
                INSTALLED+=("CLAUDE.md (created)")
            fi
        fi
    fi
else
    echo -e "${YELLOW}[5/7] Skipping CLAUDE.md (--no-claude-md)${NC}"
fi

# ============================================================================
# 6. Update AGENTS.md with boundary markers
# ============================================================================
if [ "$NO_AGENTS_MD" != "true" ]; then
    echo -e "${BLUE}[6/7] Updating AGENTS.md...${NC}"
    AGENTS_MD="$TARGET_DIR/AGENTS.md"
    AGENTS_SNIPPET_FILE="$AFX_DIR/prompts/agents.md"

    if [ -f "$AGENTS_SNIPPET_FILE" ]; then
        AGENTS_SNIPPET_CONTENT=$(sed -n '/^---$/,$p' "$AGENTS_SNIPPET_FILE" | tail -n +2)

        AFX_AGENTS_SECTION="${AFX_AGENTS_START_MARKER}
<!-- AFX Version: ${AFX_VERSION} -->

${AGENTS_SNIPPET_CONTENT}
${AFX_AGENTS_END_MARKER}"

        if [ "$DRY_RUN" = "true" ]; then
            if [ -f "$AGENTS_MD" ]; then
                if grep -q "$AFX_AGENTS_START_MARKER" "$AGENTS_MD" 2>/dev/null; then
                    UPDATED+=("AGENTS.md AFX Codex section (would update)")
                else
                    INSTALLED+=("AGENTS.md AFX Codex section (would append)")
                fi
            else
                INSTALLED+=("AGENTS.md (would create)")
            fi
        else
            if [ -f "$AGENTS_MD" ]; then
                if grep -q "$AFX_AGENTS_START_MARKER" "$AGENTS_MD"; then
                    awk -v start="$AFX_AGENTS_START_MARKER" '
                        $0 == start { exit }
                        { print }
                    ' "$AGENTS_MD" > "$AGENTS_MD.tmp"

                    echo "$AFX_AGENTS_SECTION" >> "$AGENTS_MD.tmp"

                    awk -v end="$AFX_AGENTS_END_MARKER" '
                        BEGIN { skip=1 }
                        $0 == end { skip=0; next }
                        !skip { print }
                    ' "$AGENTS_MD" >> "$AGENTS_MD.tmp"

                    mv "$AGENTS_MD.tmp" "$AGENTS_MD"
                    UPDATED+=("AGENTS.md AFX Codex section")
                else
                    echo "" >> "$AGENTS_MD"
                    echo "$AFX_AGENTS_SECTION" >> "$AGENTS_MD"
                    INSTALLED+=("AGENTS.md AFX Codex section")
                fi
            else
                cat > "$AGENTS_MD" << 'HEADER'
# AGENTS.md

Project instructions for Codex and compatible coding agents.

HEADER
                echo "$AFX_AGENTS_SECTION" >> "$AGENTS_MD"
                INSTALLED+=("AGENTS.md (created)")
            fi
        fi
    fi
else
    echo -e "${YELLOW}[6/7] Skipping AGENTS.md (--no-agents-md)${NC}"
fi

# ============================================================================
# 7. Install AFX documentation
# ============================================================================
if [ "$NO_DOCS" != "true" ]; then
    echo -e "${BLUE}[7/7] Installing AFX documentation...${NC}"
    AFX_DOCS_DIR="$TARGET_DIR/docs/agenticflowx"

    if [ "$DRY_RUN" != "true" ]; then
        mkdir -p "$AFX_DOCS_DIR"
    fi

    # Copy AFX documentation files
    for doc in "agenticflowx.md" "guide.md" "cheatsheet.md" "codex.md"; do
        if [ -f "$AFX_DIR/docs/agenticflowx/$doc" ]; then
            install_file "$AFX_DIR/docs/agenticflowx/$doc" "$AFX_DOCS_DIR/$doc" "AFX Doc: $doc" "$UPDATE_MODE"
        fi
    done
else
    echo -e "${YELLOW}[7/7] Skipping AFX documentation (--no-docs)${NC}"
fi
# ============================================================================
# Create directory structure
# ============================================================================
echo -e "${BLUE}[*] Creating directory structure...${NC}"
if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$TARGET_DIR/docs/specs"
    mkdir -p "$TARGET_DIR/docs/adr"
fi
if [ ! -d "$TARGET_DIR/docs/specs" ]; then
    INSTALLED+=("docs/specs/ directory")
fi
if [ ! -d "$TARGET_DIR/docs/adr" ]; then
    INSTALLED+=("docs/adr/ directory")
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}AFX Update Complete! (v${AFX_VERSION})${NC}"
    echo -e "${GREEN}========================================${NC}"
else
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}AFX Installation Complete! (v${AFX_VERSION})${NC}"
    echo -e "${GREEN}========================================${NC}"
fi
echo ""

if [ ${#INSTALLED[@]} -gt 0 ]; then
    echo -e "${GREEN}Installed:${NC}"
    for item in "${INSTALLED[@]}"; do
        echo "  + $item"
    done
fi

if [ ${#UPDATED[@]} -gt 0 ]; then
    echo ""
    echo -e "${CYAN}Updated:${NC}"
    for item in "${UPDATED[@]}"; do
        echo "  ~ $item"
    done
fi

if [ ${#SKIPPED[@]} -gt 0 ]; then
    echo ""
    echo -e "${YELLOW}Skipped:${NC}"
    for item in "${SKIPPED[@]}"; do
        echo "  - $item"
    done
fi

echo ""
if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${BLUE}Update notes:${NC}"
    echo "  - Claude commands, Codex skills, and templates were updated"
    echo "  - AFX docs in docs/agenticflowx/ were updated"
    echo "  - .afx.yaml was preserved (your config)"
    echo "  - CLAUDE.md AFX section was replaced (your content preserved)"
    echo "  - AGENTS.md AFX Codex section was replaced (your content preserved)"
else
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit .afx.yaml to configure your project"
    echo "  2. Run /afx:init feature <name> (Claude) or ask Codex to run afx-init"
    echo "  3. See docs/agenticflowx/ for AFX reference documentation"
    echo "  4. Run /afx:help (Claude) or afx-help (Codex) for command reference"
fi
echo ""
echo -e "${CYAN}To update AFX later:${NC}"
echo "  ./install.sh --update ."
echo "  # or"
echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/main/install.sh | bash -s -- --update ."
echo ""
