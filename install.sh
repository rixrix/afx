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
#   --no-gemini-md    Skip GEMINI.md snippet integration
#   --no-copilot-md   Skip copilot-instructions.md snippet integration
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
# Boundary markers for GEMINI.md
AFX_GEMINI_START_MARKER="<!-- AFX-GEMINI:START - Managed by AFX. Do not edit manually. -->"
AFX_GEMINI_END_MARKER="<!-- AFX-GEMINI:END -->"
# Boundary markers for copilot-instructions.md
AFX_COPILOT_START_MARKER="<!-- AFX-COPILOT:START - Managed by AFX. Do not edit manually. -->"
AFX_COPILOT_END_MARKER="<!-- AFX-COPILOT:END -->"

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
NO_GEMINI_MD=false
NO_COPILOT_MD=false
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
        --no-gemini-md)
            NO_GEMINI_MD=true
            shift
            ;;
        --no-copilot-md)
            NO_COPILOT_MD=true
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
            echo "  --no-gemini-md    Skip GEMINI.md snippet integration"
            echo "  --no-copilot-md   Skip copilot-instructions.md snippet integration"
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
echo -e "${BLUE}[1/11] Installing Claude slash commands...${NC}"
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
echo -e "${BLUE}[2/11] Installing Codex skills...${NC}"
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

# ============================================================================
# 3. Install/Update Gemini CLI commands
# ============================================================================
echo -e "${BLUE}[3/11] Installing Gemini CLI commands...${NC}"
GEMINI_COMMANDS_DIR="$TARGET_DIR/.gemini/commands"

if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$GEMINI_COMMANDS_DIR"
fi

if [ -d "$AFX_DIR/.gemini/commands" ]; then
    for cmd in "$AFX_DIR"/.gemini/commands/afx-*.md; do
        if [ -f "$cmd" ]; then
            filename=$(basename "$cmd")
            install_file "$cmd" "$GEMINI_COMMANDS_DIR/$filename" "Gemini command: $filename" "$UPDATE_MODE"
        fi
    done
fi

# ============================================================================
# 4. Install/Update GitHub Copilot prompts
# ============================================================================
echo -e "${BLUE}[4/11] Installing GitHub Copilot prompts...${NC}"
COPILOT_PROMPTS_DIR="$TARGET_DIR/.github/prompts"

if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$COPILOT_PROMPTS_DIR"
fi

if [ -d "$AFX_DIR/.github/prompts" ]; then
    for prompt in "$AFX_DIR"/.github/prompts/afx-*.prompt.md; do
        if [ -f "$prompt" ]; then
            filename=$(basename "$prompt")
            install_file "$prompt" "$COPILOT_PROMPTS_DIR/$filename" "Copilot prompt: $filename" "$UPDATE_MODE"
        fi
    done
    # Also install the README
    if [ -f "$AFX_DIR/.github/prompts/README.md" ]; then
        install_file "$AFX_DIR/.github/prompts/README.md" "$COPILOT_PROMPTS_DIR/README.md" "Copilot prompts README" "$UPDATE_MODE"
    fi
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
# 5. Install/Update templates
# ============================================================================
echo -e "${BLUE}[5/11] Installing templates...${NC}"
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
# 6. Create/Update .afx.yaml
# ============================================================================
echo -e "${BLUE}[6/11] Managing configuration...${NC}"
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
# 7. Update CLAUDE.md with boundary markers
# ============================================================================
if [ "$NO_CLAUDE_MD" != "true" ]; then
    echo -e "${BLUE}[7/11] Updating CLAUDE.md...${NC}"
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
    echo -e "${YELLOW}[7/11] Skipping CLAUDE.md (--no-claude-md)${NC}"
fi

# ============================================================================
# 8. Update AGENTS.md with boundary markers
# ============================================================================
if [ "$NO_AGENTS_MD" != "true" ]; then
    echo -e "${BLUE}[8/11] Updating AGENTS.md...${NC}"
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
    echo -e "${YELLOW}[8/11] Skipping AGENTS.md (--no-agents-md)${NC}"
fi

# ============================================================================
# 9. Update GEMINI.md with boundary markers
# ============================================================================
if [ "$NO_GEMINI_MD" != "true" ]; then
    echo -e "${BLUE}[9/11] Updating GEMINI.md...${NC}"
    GEMINI_MD="$TARGET_DIR/GEMINI.md"
    GEMINI_SNIPPET_FILE="$AFX_DIR/prompts/gemini.md"

    if [ -f "$GEMINI_SNIPPET_FILE" ]; then
        GEMINI_SNIPPET_CONTENT=$(sed -n '/^---$/,$p' "$GEMINI_SNIPPET_FILE" | tail -n +2)

        AFX_GEMINI_SECTION="${AFX_GEMINI_START_MARKER}
<!-- AFX Version: ${AFX_VERSION} -->

${GEMINI_SNIPPET_CONTENT}
${AFX_GEMINI_END_MARKER}"

        if [ "$DRY_RUN" = "true" ]; then
            if [ -f "$GEMINI_MD" ]; then
                if grep -q "$AFX_GEMINI_START_MARKER" "$GEMINI_MD" 2>/dev/null; then
                    UPDATED+=("GEMINI.md AFX Gemini section (would update)")
                else
                    INSTALLED+=("GEMINI.md AFX Gemini section (would append)")
                fi
            else
                INSTALLED+=("GEMINI.md (would create)")
            fi
        else
            if [ -f "$GEMINI_MD" ]; then
                if grep -q "$AFX_GEMINI_START_MARKER" "$GEMINI_MD"; then
                    awk -v start="$AFX_GEMINI_START_MARKER" '
                        $0 == start { exit }
                        { print }
                    ' "$GEMINI_MD" > "$GEMINI_MD.tmp"

                    echo "$AFX_GEMINI_SECTION" >> "$GEMINI_MD.tmp"

                    awk -v end="$AFX_GEMINI_END_MARKER" '
                        BEGIN { skip=1 }
                        $0 == end { skip=0; next }
                        !skip { print }
                    ' "$GEMINI_MD" >> "$GEMINI_MD.tmp"

                    mv "$GEMINI_MD.tmp" "$GEMINI_MD"
                    UPDATED+=("GEMINI.md AFX Gemini section")
                else
                    echo "" >> "$GEMINI_MD"
                    echo "$AFX_GEMINI_SECTION" >> "$GEMINI_MD"
                    INSTALLED+=("GEMINI.md AFX Gemini section")
                fi
            else
                cat > "$GEMINI_MD" << 'HEADER'
# GEMINI.md

Project context for Gemini CLI when working with code in this repository.

HEADER
                echo "$AFX_GEMINI_SECTION" >> "$GEMINI_MD"
                INSTALLED+=("GEMINI.md (created)")
            fi
        fi
    fi
else
    echo -e "${YELLOW}[9/11] Skipping GEMINI.md (--no-gemini-md)${NC}"
fi

# ============================================================================
# 10. Update copilot-instructions.md with boundary markers
# ============================================================================
if [ "$NO_COPILOT_MD" != "true" ]; then
    echo -e "${BLUE}[10/11] Updating copilot-instructions.md...${NC}"
    COPILOT_MD="$TARGET_DIR/.github/copilot-instructions.md"
    COPILOT_SNIPPET_FILE="$AFX_DIR/prompts/copilot.md"

    if [ -f "$COPILOT_SNIPPET_FILE" ]; then
        COPILOT_SNIPPET_CONTENT=$(sed -n '/^---$/,$p' "$COPILOT_SNIPPET_FILE" | tail -n +2)

        AFX_COPILOT_SECTION="${AFX_COPILOT_START_MARKER}
<!-- AFX Version: ${AFX_VERSION} -->

${COPILOT_SNIPPET_CONTENT}
${AFX_COPILOT_END_MARKER}"

        if [ "$DRY_RUN" = "true" ]; then
            if [ -f "$COPILOT_MD" ]; then
                if grep -q "$AFX_COPILOT_START_MARKER" "$COPILOT_MD" 2>/dev/null; then
                    UPDATED+=("copilot-instructions.md AFX Copilot section (would update)")
                else
                    INSTALLED+=("copilot-instructions.md AFX Copilot section (would append)")
                fi
            else
                INSTALLED+=("copilot-instructions.md (would create)")
            fi
        else
            # Ensure .github directory exists
            if [ ! -d "$TARGET_DIR/.github" ]; then
                mkdir -p "$TARGET_DIR/.github"
            fi

            if [ -f "$COPILOT_MD" ]; then
                if grep -q "$AFX_COPILOT_START_MARKER" "$COPILOT_MD"; then
                    awk -v start="$AFX_COPILOT_START_MARKER" '
                        $0 == start { exit }
                        { print }
                    ' "$COPILOT_MD" > "$COPILOT_MD.tmp"

                    echo "$AFX_COPILOT_SECTION" >> "$COPILOT_MD.tmp"

                    awk -v end="$AFX_COPILOT_END_MARKER" '
                        BEGIN { skip=1 }
                        $0 == end { skip=0; next }
                        !skip { print }
                    ' "$COPILOT_MD" >> "$COPILOT_MD.tmp"

                    mv "$COPILOT_MD.tmp" "$COPILOT_MD"
                    UPDATED+=("copilot-instructions.md AFX Copilot section")
                else
                    echo "" >> "$COPILOT_MD"
                    echo "$AFX_COPILOT_SECTION" >> "$COPILOT_MD"
                    INSTALLED+=("copilot-instructions.md AFX Copilot section")
                fi
            else
                echo "$AFX_COPILOT_SECTION" > "$COPILOT_MD"
                INSTALLED+=("copilot-instructions.md (created)")
            fi
        fi
    fi
else
    echo -e "${YELLOW}[10/11] Skipping copilot-instructions.md (--no-copilot-md)${NC}"
fi

# ============================================================================
# 11. Install AFX documentation
# ============================================================================
if [ "$NO_DOCS" != "true" ]; then
    echo -e "${BLUE}[11/11] Installing AFX documentation...${NC}"
    AFX_DOCS_DIR="$TARGET_DIR/docs/agenticflowx"

    if [ "$DRY_RUN" != "true" ]; then
        mkdir -p "$AFX_DOCS_DIR"
    fi

    # Copy AFX documentation files
    for doc in "agenticflowx.md" "guide.md" "cheatsheet.md" "multi-agent.md"; do
        if [ -f "$AFX_DIR/docs/agenticflowx/$doc" ]; then
            install_file "$AFX_DIR/docs/agenticflowx/$doc" "$AFX_DOCS_DIR/$doc" "AFX Doc: $doc" "$UPDATE_MODE"
        fi
    done
else
    echo -e "${YELLOW}[11/11] Skipping AFX documentation (--no-docs)${NC}"
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
    echo "  - Claude commands, Codex skills, Gemini commands, Copilot prompts, and templates were updated"
    echo "  - AFX docs in docs/agenticflowx/ were updated"
    echo "  - .afx.yaml was preserved (your config)"
    echo "  - CLAUDE.md AFX section was replaced (your content preserved)"
    echo "  - AGENTS.md AFX Codex section was replaced (your content preserved)"
    echo "  - GEMINI.md AFX Gemini section was replaced (your content preserved)"
    echo "  - copilot-instructions.md AFX Copilot section was replaced (your content preserved)"
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
