#!/bin/bash
# AFX (AgenticFlow) Installer
# Usage:
#   Install:  ./install.sh /path/to/project
#   Update:   ./install.sh --update /path/to/project
#   Remote:   curl -sL https://raw.githubusercontent.com/rixrix/afx/main/install.sh | bash -s -- .
#
# Options:
#   --update          Update existing AFX installation (preserves user content)
#   --commands-only   Only install/update command assets (.claude + .codex + .agent)
#   --no-claude-md    Skip CLAUDE.md snippet integration
#   --no-agents-md    Skip AGENTS.md snippet integration
#   --no-gemini-md    Skip GEMINI.md snippet integration
#   --no-copilot-md   Skip copilot-instructions.md snippet integration
#   --no-docs         Skip copying AFX documentation to docs/agenticflowx/
#   --force           Overwrite all existing files (fresh install)
#   --dry-run         Show what would be changed without making changes
#   --yes             Skip all confirmation prompts (non-interactive mode)
#   --reset           Reset AFX: recreate .afx/ folder, .afx.yaml defaults

set -e

# ============================================================================
# Section 1: Constants & Colors
# ============================================================================

AFX_REPO="rixrix/afx"

# Boundary markers
AFX_START_MARKER="<!-- AFX:START - Managed by AFX. Do not edit manually. -->"
AFX_END_MARKER="<!-- AFX:END -->"
AFX_AGENTS_START_MARKER="<!-- AFX-CODEX:START - Managed by AFX. Do not edit manually. -->"
AFX_AGENTS_END_MARKER="<!-- AFX-CODEX:END -->"
AFX_GEMINI_START_MARKER="<!-- AFX-GEMINI:START - Managed by AFX. Do not edit manually. -->"
AFX_GEMINI_END_MARKER="<!-- AFX-GEMINI:END -->"
AFX_COPILOT_START_MARKER="<!-- AFX-COPILOT:START - Managed by AFX. Do not edit manually. -->"
AFX_COPILOT_END_MARKER="<!-- AFX-COPILOT:END -->"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ============================================================================
# Section 2: Default Options
# ============================================================================

UPDATE_MODE=false
COMMANDS_ONLY=false
NO_CLAUDE_MD=false
NO_AGENTS_MD=false
NO_GEMINI_MD=false
NO_COPILOT_MD=false
NO_DOCS=false
EXPLICIT_NO_FLAGS=false  # Set true if any --no-*-md flag was passed via CLI
FORCE=false
DRY_RUN=false
YES=false
RESET=false
TARGET_DIR=""

# Provider selection (set by select_providers on first install)
INSTALL_CLAUDE=true
INSTALL_CODEX=true
INSTALL_ANTIGRAVITY=true
INSTALL_GEMINI=true
INSTALL_COPILOT=true

# Pack management options
# @see docs/specs/afx-packs/design.md#33-new-arguments
PACK_NAMES=()
PACK_DISABLE=""
PACK_ENABLE=""
PACK_REMOVE=""
PACK_LIST=false
SKILL_DISABLE=""
SKILL_ENABLE=""
UPDATE_PACKS=false
ADD_SKILL=""
BRANCH=""
VERSION=""

# Change tracking
INSTALLED=()
UPDATED=()
SKIPPED=()

# ============================================================================
# Section 3: Argument Parsing
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --update)         UPDATE_MODE=true; shift ;;
        --commands-only)  COMMANDS_ONLY=true; shift ;;
        --no-claude-md)   NO_CLAUDE_MD=true; EXPLICIT_NO_FLAGS=true; shift ;;
        --no-agents-md)   NO_AGENTS_MD=true; EXPLICIT_NO_FLAGS=true; shift ;;
        --no-gemini-md)   NO_GEMINI_MD=true; EXPLICIT_NO_FLAGS=true; shift ;;
        --no-copilot-md)  NO_COPILOT_MD=true; EXPLICIT_NO_FLAGS=true; shift ;;
        --no-docs)        NO_DOCS=true; shift ;;
        --force)          FORCE=true; shift ;;
        --dry-run)        DRY_RUN=true; shift ;;
        --yes|-y)         YES=true; shift ;;
        --reset)          RESET=true; shift ;;
        --pack)           PACK_NAMES+=("$2"); shift 2 ;;
        --pack-disable)   PACK_DISABLE="$2"; shift 2 ;;
        --pack-enable)    PACK_ENABLE="$2"; shift 2 ;;
        --pack-remove)    PACK_REMOVE="$2"; shift 2 ;;
        --pack-list)      PACK_LIST=true; shift ;;
        --skill-disable)  SKILL_DISABLE="$2"; shift 2 ;;
        --skill-enable)   SKILL_ENABLE="$2"; shift 2 ;;
        --packs)          UPDATE_PACKS=true; shift ;;
        --add-skill)      ADD_SKILL="$2"; shift 2 ;;
        --branch)         BRANCH="$2"; shift 2 ;;
        --version)        VERSION="$2"; shift 2 ;;
        -h|--help)
            cat <<'HELPEOF'
AFX Installer

Usage: ./install.sh [OPTIONS] <target-project-path>

Options:
  --update          Update existing AFX installation
  --commands-only   Only install/update command assets (.claude + .codex + .agent)
  --no-claude-md    Skip CLAUDE.md snippet integration
  --no-agents-md    Skip AGENTS.md snippet integration
  --no-gemini-md    Skip GEMINI.md snippet integration
  --no-copilot-md   Skip copilot-instructions.md snippet integration
  --no-docs         Skip copying AFX documentation to docs/agenticflowx/
  --force           Overwrite all files (fresh install)
  --dry-run         Preview changes without applying
  --yes, -y         Skip all confirmation prompts
  --reset           Reset AFX: recreate .afx/ folder and config files
  --branch NAME     Use a specific branch (default: main)
  --version TAG     Use a specific version tag (e.g., 1.5.3 or v1.5.3)
  -h, --help        Show this help message

Pack Management:
  --pack NAME                     Install and enable a pack
  --pack-disable NAME             Disable a pack (keep master)
  --pack-enable NAME              Re-enable a disabled pack
  --pack-remove NAME              Remove a pack entirely
  --pack-list                     List installed packs
  --skill-disable NAME --pack P   Disable a skill within a pack
  --skill-enable NAME --pack P    Re-enable a skill within a pack
  --update --packs                Update all enabled packs
  --add-skill REPO:PATH/SKILL     Install a single skill (no pack)

Examples:
  # Fresh install (interactive — choose your providers)
  ./install.sh .

  # Non-interactive install (all providers)
  ./install.sh --yes .

  # Update existing installation
  ./install.sh --update .

  # Remote install
  curl -sL https://raw.githubusercontent.com/rixrix/afx/main/install.sh | bash -s -- .

  # Install QA pack (short or full name)
  ./install.sh --pack qa .
  ./install.sh --pack afx-pack-qa .

  # Install from version
  ./install.sh --version 1.5.3 --pack qa .

  # Multiple packs
  ./install.sh --pack qa --pack security .

  # Manage packs (short or full name)
  ./install.sh --pack-disable afx-pack-qa .
  ./install.sh --pack-enable qa .
  ./install.sh --pack-list .

  # Update all packs
  ./install.sh --update --packs .

  # Reset AFX (recreate .afx/ folder and config)
  ./install.sh --reset .
HELPEOF
            exit 0
            ;;
        *)
            TARGET_DIR="$1"
            shift
            ;;
    esac
done

# ============================================================================
# Section 4: Core Helper Functions
# ============================================================================

# Ask for confirmation. Returns 0 (yes) or 1 (no).
# Usage: confirm "Do something?" && do_it
# Defaults to Yes if user just presses Enter.
# Skipped entirely if --yes flag is set.
confirm() {
    local prompt="$1"
    if [[ "$YES" == "true" || "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    echo -en "${BOLD}${prompt}${NC} ${DIM}[Y/n]${NC} "
    read -r answer </dev/tty
    case "$answer" in
        [nN]|[nN][oO]) return 1 ;;
        *) return 0 ;;
    esac
}

# Install or update a single file
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

# Install or update a directory by replacing destination contents
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

# Update a markdown file with AFX boundary markers (reusable for CLAUDE.md, AGENTS.md, etc.)
# Usage: update_md_with_markers <file> <start_marker> <end_marker> <snippet_content> <label> <header>
update_md_with_markers() {
    local md_file="$1"
    local start_marker="$2"
    local end_marker="$3"
    local snippet_content="$4"
    local label="$5"
    local header_content="$6"

    local section="${start_marker}
<!-- AFX Version: ${AFX_VERSION} -->

${snippet_content}
${end_marker}"

    if [ "$DRY_RUN" = "true" ]; then
        if [ -f "$md_file" ]; then
            if grep -q "$start_marker" "$md_file" 2>/dev/null; then
                UPDATED+=("$label AFX section (would update)")
            elif [[ "$label" == "CLAUDE.md" ]] && grep -q "## Documentation References\|## AgenticFlow" "$md_file" 2>/dev/null; then
                SKIPPED+=("$label (has old AFX section - run with --force to migrate)")
            else
                INSTALLED+=("$label AFX section (would append)")
            fi
        else
            INSTALLED+=("$label (would create)")
        fi
        return 0
    fi

    if [ -f "$md_file" ]; then
        if grep -q "$start_marker" "$md_file"; then
            # Has boundary markers — replace the section
            awk -v start="$start_marker" '$0 == start { exit } { print }' "$md_file" > "$md_file.tmp"
            echo "$section" >> "$md_file.tmp"
            awk -v end="$end_marker" 'BEGIN { skip=1 } $0 == end { skip=0; next } !skip { print }' "$md_file" >> "$md_file.tmp"
            mv "$md_file.tmp" "$md_file"
            UPDATED+=("$label AFX section")
        elif [[ "$label" == "CLAUDE.md" ]] && grep -q "## Documentation References\|## AgenticFlow" "$md_file"; then
            # Old-style section without markers
            if [ "$FORCE" = "true" ]; then
                echo -e "${YELLOW}Warning: Migrating old AFX section to use boundary markers${NC}"
                echo "" >> "$md_file"
                echo "$section" >> "$md_file"
                UPDATED+=("$label (migrated - please remove old AFX section manually)")
            else
                SKIPPED+=("$label (has old AFX section - use --force to migrate)")
            fi
        else
            # No AFX section — append
            echo "" >> "$md_file"
            echo "$section" >> "$md_file"
            INSTALLED+=("$label AFX section")
        fi
    else
        # Create new file
        mkdir -p "$(dirname "$md_file")"
        echo "$header_content" > "$md_file"
        echo "" >> "$md_file"
        echo "$section" >> "$md_file"
        INSTALLED+=("$label (created)")
    fi
}

# Ensure a pattern is in .gitignore
# @see docs/specs/afx-packs/design.md#310-helper-functions
ensure_gitignore() {
    local pattern="$1"
    local gitignore="$TARGET_DIR/.gitignore"
    [[ "$DRY_RUN" == "true" ]] && return 0
    if [[ -f "$gitignore" ]]; then
        grep -qF "$pattern" "$gitignore" || echo "$pattern" >> "$gitignore"
    else
        echo "$pattern" > "$gitignore"
    fi
}

# Write minimal user-facing .afx.yaml (version + packs + override guide)
# All defaults live in .afx/.afx.yaml — user only adds overrides here.
write_minimal_user_config() {
    cat > "$TARGET_DIR/.afx.yaml" <<'YAMLEOF'
# ┌─────────────────────────────────────────────────────────────────────────┐
# │  AFX Configuration                                                      │
# │                                                                         │
# │  Defaults are in .afx/.afx.yaml (managed by AFX — do not edit).         │
# │  Add overrides below — they take precedence over defaults.              │
# │                                                                         │
# │  Docs: docs/agenticflowx/agenticflowx.md                                │
# │  Help: /afx:help (Claude) or afx-help (Codex)                           │
# └─────────────────────────────────────────────────────────────────────────┘

# AFX version — controls which branch/tag install.sh fetches from.
# Accepts: semver (e.g. '1.5.3' → tag v1.5.3), branch name, or 'main'.
version: main

# ── Installed Packs ───────────────────────────────────────────────────────
# Managed by install.sh. Add packs with:
#   ./install.sh --pack qa .
#   ./install.sh --pack security .

providers:
  claude: true
  codex: true
  antigravity: true
  gemini: true
  copilot: true

packs: []

# ── Your Overrides ───────────────────────────────────────────────────────
# Override any value from .afx/.afx.yaml here. Examples:
#
#   paths:
#     specs: my-specs          # Custom spec directory
#
#   features:
#     - user-auth              # Active features
#
#   quality_gates:
#     require_path_check: false
YAMLEOF
}

# ============================================================================
# Section 5: Provider Selection (first install only)
# ============================================================================

# Interactive provider selection menu for first install.
# Sets INSTALL_* flags and NO_*_MD flags based on user choices.
select_providers() {
    # Skip in dry-run (preview only)
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi

    # Skip if --no-*-md flags were explicitly passed via CLI (user knows what they want)
    if [[ "$EXPLICIT_NO_FLAGS" == "true" ]]; then
        return 0
    fi

    echo ""
    echo -e "${BOLD}Which AI coding tools do you use?${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}) Claude Code       ${DIM}(Anthropic)${NC}"
    echo -e "  ${GREEN}2${NC}) Codex CLI          ${DIM}(OpenAI)${NC}"
    echo -e "  ${GREEN}3${NC}) Antigravity        ${DIM}(Anthropic)${NC}"
    echo -e "  ${GREEN}4${NC}) Gemini CLI          ${DIM}(Google)${NC}"
    echo -e "  ${GREEN}5${NC}) GitHub Copilot     ${DIM}(GitHub)${NC}"
    echo ""
    echo -e "  ${CYAN}a${NC}) All of the above"
    echo ""
    echo -en "${BOLD}Select providers (comma-separated, e.g. 1,4):${NC} "
    selection=""
    if [[ -t 0 ]]; then
        read -r selection || true
    else
        read -r selection </dev/tty 2>/dev/null || true
    fi
    # No input — default to all
    [[ -z "$selection" ]] && selection="a"

    # If "all", keep everything true and return
    if [[ "$selection" == "a" || "$selection" == "A" || "$selection" == "all" ]]; then
        echo -e "${GREEN}Installing for all providers.${NC}"
        echo ""
        return 0
    fi

    # Reset all to false, then enable selected ones
    INSTALL_CLAUDE=false
    INSTALL_CODEX=false
    INSTALL_ANTIGRAVITY=false
    INSTALL_GEMINI=false
    INSTALL_COPILOT=false

    IFS=',' read -ra choices <<< "$selection"
    for choice in "${choices[@]}"; do
        choice=$(echo "$choice" | tr -d ' ')
        case "$choice" in
            1) INSTALL_CLAUDE=true ;;
            2) INSTALL_CODEX=true ;;
            3) INSTALL_ANTIGRAVITY=true ;;
            4) INSTALL_GEMINI=true ;;
            5) INSTALL_COPILOT=true ;;
            *) echo -e "${YELLOW}Unknown option '$choice' — skipping${NC}" ;;
        esac
    done

    # Map provider flags to --no-* flags
    [[ "$INSTALL_CLAUDE" == "false" ]] && NO_CLAUDE_MD=true
    [[ "$INSTALL_CODEX" == "false" ]] && NO_AGENTS_MD=true
    [[ "$INSTALL_GEMINI" == "false" ]] && NO_GEMINI_MD=true
    [[ "$INSTALL_COPILOT" == "false" ]] && NO_COPILOT_MD=true

    # Show summary
    local selected=()
    [[ "$INSTALL_CLAUDE" == "true" ]] && selected+=("Claude Code")
    [[ "$INSTALL_CODEX" == "true" ]] && selected+=("Codex CLI")
    [[ "$INSTALL_ANTIGRAVITY" == "true" ]] && selected+=("Antigravity")
    [[ "$INSTALL_GEMINI" == "true" ]] && selected+=("Gemini CLI")
    [[ "$INSTALL_COPILOT" == "true" ]] && selected+=("GitHub Copilot")

    echo -e "${GREEN}Selected: ${selected[*]}${NC}"
    echo ""
}

# Read provider flags from .afx.yaml (returns nothing if file/section missing).
# Sets INSTALL_* and NO_*_MD flags based on saved providers.
load_providers_from_yaml() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0
    grep -q "^providers:" "$yaml" || return 0

    local val
    for provider in claude codex antigravity gemini copilot; do
        val=$(grep "^  ${provider}:" "$yaml" | head -1 | awk '{print $2}')
        [[ -z "$val" ]] && val="true"
        case "$provider" in
            claude)       INSTALL_CLAUDE="$val";       [[ "$val" == "false" ]] && NO_CLAUDE_MD=true ;;
            codex)        INSTALL_CODEX="$val";        [[ "$val" == "false" ]] && NO_AGENTS_MD=true ;;
            antigravity)  INSTALL_ANTIGRAVITY="$val" ;;
            gemini)       INSTALL_GEMINI="$val";       [[ "$val" == "false" ]] && NO_GEMINI_MD=true ;;
            copilot)      INSTALL_COPILOT="$val";      [[ "$val" == "false" ]] && NO_COPILOT_MD=true ;;
        esac
    done
    return 0
}

# Write current INSTALL_* flags into the providers: section of .afx.yaml.
save_providers_to_yaml() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0
    [[ "$DRY_RUN" == "true" ]] && return 0

    # If providers: section exists, update in place; otherwise append after version:
    if grep -q "^providers:" "$yaml"; then
        local temp=$(mktemp)
        local in_providers=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" == "providers:" ]]; then
                in_providers=true
                echo "providers:" >> "$temp"
                echo "  claude: $INSTALL_CLAUDE" >> "$temp"
                echo "  codex: $INSTALL_CODEX" >> "$temp"
                echo "  antigravity: $INSTALL_ANTIGRAVITY" >> "$temp"
                echo "  gemini: $INSTALL_GEMINI" >> "$temp"
                echo "  copilot: $INSTALL_COPILOT" >> "$temp"
                continue
            fi
            if $in_providers; then
                # Skip old provider lines until we hit a non-provider line
                if [[ "$line" =~ ^\ \ (claude|codex|antigravity|gemini|copilot): ]]; then
                    continue
                fi
                in_providers=false
            fi
            echo "$line" >> "$temp"
        done < "$yaml"
        mv "$temp" "$yaml"
    else
        # Insert after version: line
        local temp=$(mktemp)
        while IFS= read -r line || [[ -n "$line" ]]; do
            echo "$line" >> "$temp"
            if [[ "$line" =~ ^version: ]]; then
                echo "" >> "$temp"
                echo "providers:" >> "$temp"
                echo "  claude: $INSTALL_CLAUDE" >> "$temp"
                echo "  codex: $INSTALL_CODEX" >> "$temp"
                echo "  antigravity: $INSTALL_ANTIGRAVITY" >> "$temp"
                echo "  gemini: $INSTALL_GEMINI" >> "$temp"
                echo "  copilot: $INSTALL_COPILOT" >> "$temp"
            fi
        done < "$yaml"
        mv "$temp" "$yaml"
    fi
}

# ============================================================================
# Section 6: Pack Management Functions
# @see docs/specs/afx-packs/design.md#3-installsh-architecture
# @see docs/specs/afx-packs/tasks.md#phase-3-installsh--download--detection
# ============================================================================

# Resolve the git ref for AFX repo fetches
# @see docs/specs/afx-packs/design.md#34-download-strategy
resolve_ref() {
    if [[ -n "$VERSION" && -n "$BRANCH" ]]; then
        echo -e "${RED}Error: --version and --branch are mutually exclusive${NC}" >&2
        return 1
    fi
    if [[ -n "$VERSION" ]]; then
        [[ "$VERSION" == v* ]] && echo "$VERSION" || echo "v$VERSION"
    elif [[ -n "$BRANCH" ]]; then
        echo "$BRANCH"
    else
        local yaml_version=""
        if [[ -f "$TARGET_DIR/.afx.yaml" ]]; then
            yaml_version=$(grep '^version:' "$TARGET_DIR/.afx.yaml" 2>/dev/null | awk '{print $2}' | tr -d "'\"")
        fi
        if [[ -n "$yaml_version" && "$yaml_version" != "main" ]]; then
            if [[ "$yaml_version" =~ ^[0-9] ]]; then
                [[ "$yaml_version" == v* ]] && echo "$yaml_version" || echo "v$yaml_version"
            else
                echo "$yaml_version"
            fi
        else
            echo "main"
        fi
    fi
}

# Fetch a pack manifest YAML from raw.githubusercontent.com
# @see docs/specs/afx-packs/design.md#34-download-strategy
fetch_manifest() {
    local pack_name="$1"
    local ref="$2"
    local temp_manifest=$(mktemp)

    curl -sfL "https://raw.githubusercontent.com/${AFX_REPO}/${ref}/packs/${pack_name}.yaml" \
        -o "$temp_manifest" 2>/dev/null

    if [[ ! -s "$temp_manifest" ]]; then
        rm -f "$temp_manifest"
        echo -e "${RED}Error: Failed to fetch manifest for '${pack_name}' (ref: ${ref})${NC}" >&2
        echo "Check pack name and try again." >&2
        return 1
    fi

    echo "$temp_manifest"
}

# Download and extract specific paths from a GitHub repo tarball
# @see docs/specs/afx-packs/design.md#34-download-strategy
download_items() {
    local repo="$1"
    local ref="$2"
    local base_path="$3"
    shift 3
    local items=("$@")

    local url="https://codeload.github.com/${repo}/tar.gz/${ref}"
    local temp_dir=$(mktemp -d)

    curl -sL "$url" | tar xz -C "$temp_dir" --strip-components=1 2>/dev/null
    echo "$temp_dir"
}

# Parse manifest includes[] — outputs one line per include block: "repo path item1 item2 ..."
# @see docs/specs/afx-packs/design.md#35-yaml-parsing
for_each_include() {
    local manifest="$1"
    local in_includes=false
    local current_repo="" current_path=""
    local items=()

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "includes:" ]]; then
            in_includes=true; continue
        fi
        if $in_includes && [[ "$line" =~ ^[a-z] ]]; then
            [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
            break
        fi

        if $in_includes; then
            if [[ "$line" =~ ^\ \ -\ repo:\ (.+) ]]; then
                [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
                current_repo="${BASH_REMATCH[1]}"
                current_path="" ; items=()
            elif [[ "$line" =~ ^\ \ \ \ path:\ (.+) ]]; then
                current_path="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^\ \ \ \ \ \ -\ ([^#]+) ]]; then
                local item_name="${BASH_REMATCH[1]}"
                item_name="${item_name%%#*}"
                item_name="${item_name%% }"
                item_name="${item_name%% }"
                items+=("$item_name")
            fi
        fi
    done < "$manifest"

    [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
}

# Parse platforms from manifest
parse_platforms() {
    local manifest="$1"
    local in_platforms=false
    local result=""

    while IFS= read -r line; do
        if [[ "$line" == "platforms:" ]]; then
            in_platforms=true; continue
        fi
        if $in_platforms && [[ "$line" =~ ^[a-z] ]]; then
            break
        fi
        if $in_platforms && [[ "$line" =~ ^\ \ ([a-z]+):\ *([a-z]+) ]]; then
            result+="${BASH_REMATCH[1]}:${BASH_REMATCH[2]} "
        fi
    done < "$manifest"

    echo "$result"
}

# Check if a platform is enabled in the manifest
# @see docs/specs/afx-packs/design.md#36-type-detection--routing
platform_enabled() {
    local platforms="$1"
    local provider="$2"
    local val=""

    for pair in $platforms; do
        if [[ "$pair" == "${provider}:"* ]]; then
            val="${pair#*:}"
            break
        fi
    done

    [[ "$val" == "true" || "$val" == "partial" ]]
}

# ────────────────────────────────────────────────────────────────────────────
# Provider-specific skill transforms
# ────────────────────────────────────────────────────────────────────────────
#
# AFX-built skills ship as a single canonical SKILL.md using Claude command
# syntax (/afx:cmd sub). install.sh transforms this per provider at install
# time, eliminating 4x file duplication in the source repo.
#
# @see docs/specs/afx-packs/design.md#2-directory-layout
# ────────────────────────────────────────────────────────────────────────────

# Transform a canonical SKILL.md for a specific provider
transform_for_provider() {
    local input="$1"
    local output="$2"
    local provider="$3"

    case "$provider" in
        claude)
            sed \
                -e '/<!-- @afx:provider-commands -->/d' \
                -e '/<!-- @afx:\/provider-commands -->/d' \
                "$input" > "$output"
            ;;
        codex)
            sed \
                -e '/<!-- @afx:provider-commands -->/d' \
                -e '/<!-- @afx:\/provider-commands -->/d' \
                -e 's|`/afx:\([a-z]*\) \([a-z]*\)`|`afx-\1-\2`|g' \
                "$input" > "$output"
            ;;
        antigravity)
            sed \
                '/<!-- @afx:provider-commands -->/,/<!-- @afx:\/provider-commands -->/d' \
                "$input" > "$output"
            ;;
        *)
            cp "$input" "$output"
            ;;
    esac
}

# Generate a condensed Copilot agent.md from a canonical SKILL.md
generate_copilot_agent() {
    local input="$1"
    local output="$2"
    local skill_name="$3"

    local title
    title=$(grep -m1 '^# ' "$input" | sed 's/^# //')

    local description
    description=$(awk 'NR>1 && /^[^#]/ && !/^$/ && !/^---/ { print; exit }' "$input")

    local instructions
    instructions=$(sed -n '/^## Instructions/,/^## [^I]/{
        /^##/d
        /^###/d
        /^```/,/^```/d
        /<!-- @afx/d
        /^$/d
        /^   |/d
        p
    }' "$input" | grep -E '^\d+\.|^- ' | head -7)

    local numbered
    numbered=$(echo "$instructions" | awk '
        /^[0-9]+\./ { counter++; sub(/^[0-9]+\./, counter"."); }
        { print }
    ')

    cat > "$output" <<EOF
---
name: ${skill_name}
description: $(echo "$description" | sed 's/\.$//')
---

# ${title}

${description}

When assisting with this topic:

${numbered}
EOF
}

# Detect skill type
# @see docs/specs/afx-packs/design.md#36-type-detection--routing
detect_type() {
    local item_dir="$1"
    local source_repo="$2"

    if [[ "$source_repo" == "${AFX_REPO}" ]]; then
        echo "afx"
    elif [[ -d "$item_dir/.claude-plugin" ]]; then
        echo "plugin"
    elif [[ -f "$item_dir/agents/openai.yaml" ]]; then
        echo "openai"
    elif [[ -f "$item_dir/SKILL.md" ]]; then
        echo "skill"
    else
        echo "unknown"
    fi
}

# Route a detected item to .afx/packs/{pack}/{provider}/
# @see docs/specs/afx-packs/design.md#36-type-detection--routing
route_item() {
    local item_dir="$1"
    local item_name="$2"
    local type="$3"
    local pack_dir="$4"
    local platforms="$5"

    case "$type" in
        skill)
            if platform_enabled "$platforms" "claude"; then
                mkdir -p "$pack_dir/claude/skills/$item_name"
                cp -r "$item_dir"/. "$pack_dir/claude/skills/$item_name/"
            fi
            if platform_enabled "$platforms" "codex"; then
                mkdir -p "$pack_dir/codex/skills/$item_name"
                cp -r "$item_dir"/. "$pack_dir/codex/skills/$item_name/"
            fi
            if platform_enabled "$platforms" "antigravity"; then
                mkdir -p "$pack_dir/antigravity/skills/$item_name"
                cp -r "$item_dir"/. "$pack_dir/antigravity/skills/$item_name/"
            fi
            ;;
        plugin)
            if platform_enabled "$platforms" "claude"; then
                mkdir -p "$pack_dir/claude/plugins/$item_name"
                cp -r "$item_dir"/. "$pack_dir/claude/plugins/$item_name/"
            fi
            ;;
        openai)
            if platform_enabled "$platforms" "codex"; then
                mkdir -p "$pack_dir/codex/skills/$item_name"
                cp -r "$item_dir"/. "$pack_dir/codex/skills/$item_name/"
            fi
            ;;
        afx)
            local canonical="$item_dir/SKILL.md"
            if [[ ! -f "$canonical" ]]; then
                echo -e "${YELLOW}Warning: No SKILL.md in AFX skill '$item_name' — skipping${NC}"
                break
            fi
            for provider in claude codex antigravity; do
                if platform_enabled "$platforms" "$provider"; then
                    mkdir -p "$pack_dir/$provider/skills/$item_name"
                    transform_for_provider "$canonical" \
                        "$pack_dir/$provider/skills/$item_name/SKILL.md" \
                        "$provider"
                fi
            done
            if platform_enabled "$platforms" "copilot"; then
                mkdir -p "$pack_dir/copilot/agents"
                generate_copilot_agent "$canonical" \
                    "$pack_dir/copilot/agents/${item_name}.agent.md" \
                    "$item_name"
            fi
            ;;
        *)
            echo -e "${YELLOW}Warning: Unknown skill type for '$item_name' — skipping${NC}"
            ;;
    esac
}

# Check name collision across packs
# @see docs/specs/afx-packs/design.md#38-name-collision-detection
check_collision() {
    local item_name="$1"
    local provider_dir="$2"
    local current_pack="$3"

    if [[ -d "$provider_dir/$item_name" ]] && [[ "$FORCE" != "true" ]]; then
        for pack_dir in "$TARGET_DIR/.afx/packs"/afx-pack-*/; do
            [[ -d "$pack_dir" ]] || continue
            local pack_name=$(basename "$pack_dir")
            if [[ "$pack_name" != "$current_pack" ]]; then
                if [[ -d "$pack_dir"/*/"skills/$item_name" ]] || \
                   [[ -d "$pack_dir"/*/"plugins/$item_name" ]]; then
                    echo -e "${RED}Error: '$item_name' already installed by pack '$pack_name'${NC}"
                    echo "Use --force to overwrite."
                    return 1
                fi
            fi
        done
    fi
    return 0
}

# Map provider name to target directory
# @see docs/specs/afx-packs/design.md#310-helper-functions
provider_target_dir() {
    local provider="$1"
    local subdir="$2"

    case "$provider" in
        claude)       echo "$TARGET_DIR/.claude/$subdir" ;;
        codex)        echo "$TARGET_DIR/.agents/$subdir" ;;
        antigravity)  echo "$TARGET_DIR/.agent/$subdir" ;;
        copilot)      echo "$TARGET_DIR/.github/agents" ;;
    esac
}

# ============================================================================
# Section 7: .afx.yaml Read/Write Helpers
# @see docs/specs/afx-packs/design.md#311-afxyaml-readwrite
# ============================================================================

afx_yaml_enabled_packs() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0
    awk '/^packs:/,/^[^ ]/' "$yaml" | grep -B1 'status: enabled' | grep 'name:' | awk '{print $3}'
}

afx_yaml_all_packs() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    local name="" status="" disabled_count=0 in_packs=false in_disabled=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "packs:" ]]; then
            in_packs=true; continue
        fi
        if $in_packs && [[ -n "$line" ]] && [[ ! "$line" =~ ^\ \  ]]; then
            [[ -n "$name" ]] && echo "$name:$status:$disabled_count"
            break
        fi
        if $in_packs; then
            if [[ "$line" =~ ^\ \ -\ name:\ (.+) ]]; then
                [[ -n "$name" ]] && echo "$name:$status:$disabled_count"
                name="${BASH_REMATCH[1]}"
                status="" ; disabled_count=0 ; in_disabled=false
            elif [[ "$line" =~ ^\ \ \ \ status:\ (.+) ]]; then
                status="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^\ \ \ \ disabled_items: ]]; then
                in_disabled=true
            elif $in_disabled && [[ "$line" =~ ^\ \ \ \ \ \ -\  ]]; then
                ((disabled_count++))
            elif [[ "$line" =~ ^\ \ \ \  ]] && ! $in_disabled; then
                :
            else
                in_disabled=false
            fi
        fi
    done < "$yaml"

    [[ -n "$name" ]] && echo "$name:$status:$disabled_count"
}

afx_yaml_pack_ref() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || { echo "main"; return 0; }

    local found_pack=false
    while IFS= read -r line; do
        if [[ "$line" =~ name:\ $pack_name$ ]]; then
            found_pack=true; continue
        fi
        if $found_pack && [[ "$line" =~ ^\ \ -\ name: ]]; then break; fi
        if $found_pack && [[ "$line" =~ ^\ \ \ \ installed_ref:\ (.+) ]]; then
            echo "${BASH_REMATCH[1]}"; return 0
        fi
    done < "$yaml"
    echo "main"
}

afx_yaml_disabled_items() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    local found_pack=false in_disabled=false result=""
    while IFS= read -r line; do
        if [[ "$line" =~ name:\ $pack_name$ ]]; then found_pack=true; continue; fi
        if $found_pack && [[ "$line" =~ ^\ \ -\ name: ]]; then break; fi
        if $found_pack && [[ "$line" =~ disabled_items: ]]; then in_disabled=true; continue; fi
        if $found_pack && $in_disabled; then
            if [[ "$line" =~ ^\ \ \ \ \ \ -\ (.+) ]]; then
                result+="${BASH_REMATCH[1]} "
            else
                in_disabled=false
            fi
        fi
    done < "$yaml"
    echo "$result"
}

afx_yaml_set_pack() {
    local pack_name="$1"
    local status="$2"
    local ref="${3:-}"
    local yaml="$TARGET_DIR/.afx.yaml"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "  ${CYAN}(would update .afx.yaml: $pack_name → $status)${NC}"
        return 0
    fi

    if [[ ! -f "$yaml" ]]; then
        echo "packs:" > "$yaml"
    fi

    if grep -q "name: $pack_name" "$yaml" 2>/dev/null; then
        local temp=$(mktemp)
        local in_target=false
        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^\ \ -\ name:\ $pack_name$ ]]; then
                in_target=true
                echo "$line" >> "$temp"
            elif $in_target && [[ "$line" =~ ^\ \ -\ name: || ! "$line" =~ ^\ \  ]]; then
                in_target=false
                echo "$line" >> "$temp"
            elif $in_target && [[ "$line" =~ ^\ \ \ \ status: ]]; then
                echo "    status: $status" >> "$temp"
            elif $in_target && [[ -n "$ref" ]] && [[ "$line" =~ ^\ \ \ \ installed_ref: ]]; then
                echo "    installed_ref: $ref" >> "$temp"
            else
                echo "$line" >> "$temp"
            fi
        done < "$yaml"
        mv "$temp" "$yaml"
    else
        if ! grep -q "^packs:" "$yaml" 2>/dev/null; then
            echo "" >> "$yaml"
            echo "packs:" >> "$yaml"
        fi
        cat >> "$yaml" <<EOF
  - name: $pack_name
    status: $status
    installed_ref: ${ref:-main}
    disabled_items: []
EOF
    fi
}

afx_yaml_remove_pack() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "  ${CYAN}(would remove $pack_name from .afx.yaml)${NC}"
        return 0
    fi

    local temp=$(mktemp)
    local skip=false
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\ \ -\ name:\ $pack_name$ ]]; then skip=true; continue; fi
        if $skip && [[ "$line" =~ ^\ \ -\ name: ]]; then skip=false; fi
        if $skip && [[ -n "$line" ]] && [[ ! "$line" =~ ^\ \  ]]; then skip=false; fi
        $skip || echo "$line"
    done < "$yaml" > "$temp"
    mv "$temp" "$yaml"
}

afx_yaml_disable_item() {
    local pack_name="$1"
    local item_name="$2"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ "$DRY_RUN" == "true" ]] && return 0

    if grep -A5 "name: $pack_name" "$yaml" | grep -q "disabled_items: \[\]"; then
        sed -i.bak "/name: $pack_name/,/disabled_items:/{s/disabled_items: \[\]/disabled_items:\n      - $item_name/;}" "$yaml"
        rm -f "$yaml.bak"
    else
        sed -i.bak "/name: $pack_name/,/^  - name:\|^[^ ]/{/disabled_items:/a\\
      - $item_name
}" "$yaml"
        rm -f "$yaml.bak"
    fi
}

afx_yaml_enable_item() {
    local pack_name="$1"
    local item_name="$2"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ "$DRY_RUN" == "true" ]] && return 0

    sed -i.bak "/      - $item_name/d" "$yaml"
    rm -f "$yaml.bak"

    if ! grep -A20 "name: $pack_name" "$yaml" | grep -q "^      - "; then
        sed -i.bak "/name: $pack_name/,/^  - name:\|^[^ ]/{s/disabled_items:/disabled_items: []/;}" "$yaml"
        rm -f "$yaml.bak"
    fi
}

afx_yaml_add_custom_skill() {
    local repo="$1"
    local path="$2"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ "$DRY_RUN" == "true" ]] && return 0

    if ! grep -q "^custom_skills:" "$yaml" 2>/dev/null; then
        echo "" >> "$yaml"
        echo "custom_skills:" >> "$yaml"
    fi
    cat >> "$yaml" <<EOF
  - repo: $repo
    path: $path
EOF
}

# ============================================================================
# Section 8: Pack Lifecycle Functions
# @see docs/specs/afx-packs/design.md#39-state-transitions
# ============================================================================

pack_copy_to_providers() {
    local pack_name="$1"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"
    local disabled_items=$(afx_yaml_disabled_items "$pack_name")

    # Claude skills
    if [[ -d "$pack_dir/claude/skills" ]]; then
        mkdir -p "$TARGET_DIR/.claude/skills"
        for skill in "$pack_dir"/claude/skills/*/; do
            [[ -d "$skill" ]] || continue
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            check_collision "$name" "$TARGET_DIR/.claude/skills" "$pack_name" || continue
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED+=("  → .claude/skills/$name (would create)")
            else
                cp -r "$skill" "$TARGET_DIR/.claude/skills/$name"
                INSTALLED+=("  → .claude/skills/$name")
            fi
        done
    fi

    # Claude plugins
    if [[ -d "$pack_dir/claude/plugins" ]]; then
        mkdir -p "$TARGET_DIR/.claude/plugins"
        for plugin in "$pack_dir"/claude/plugins/*/; do
            [[ -d "$plugin" ]] || continue
            local name=$(basename "$plugin")
            [[ " $disabled_items " =~ " $name " ]] && continue
            check_collision "$name" "$TARGET_DIR/.claude/plugins" "$pack_name" || continue
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED+=("  → .claude/plugins/$name (would create)")
            else
                cp -r "$plugin" "$TARGET_DIR/.claude/plugins/$name"
                INSTALLED+=("  → .claude/plugins/$name")
            fi
        done
    fi

    # Codex skills
    if [[ -d "$pack_dir/codex/skills" ]]; then
        mkdir -p "$TARGET_DIR/.agents/skills"
        for skill in "$pack_dir"/codex/skills/*/; do
            [[ -d "$skill" ]] || continue
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED+=("  → .agents/skills/$name (would create)")
            else
                cp -r "$skill" "$TARGET_DIR/.agents/skills/$name"
                INSTALLED+=("  → .agents/skills/$name")
            fi
        done
    fi

    # Antigravity skills
    if [[ -d "$pack_dir/antigravity/skills" ]]; then
        mkdir -p "$TARGET_DIR/.agent/skills"
        for skill in "$pack_dir"/antigravity/skills/*/; do
            [[ -d "$skill" ]] || continue
            local name=$(basename "$skill")
            [[ " $disabled_items " =~ " $name " ]] && continue
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED+=("  → .agent/skills/$name (would create)")
            else
                cp -r "$skill" "$TARGET_DIR/.agent/skills/$name"
                INSTALLED+=("  → .agent/skills/$name")
            fi
        done
    fi

    # Copilot agents
    if [[ -d "$pack_dir/copilot/agents" ]]; then
        mkdir -p "$TARGET_DIR/.github/agents"
        for agent in "$pack_dir"/copilot/agents/*.agent.md; do
            [[ -f "$agent" ]] || continue
            local name=$(basename "$agent" .agent.md)
            [[ " $disabled_items " =~ " $name " ]] && continue
            if [[ "$DRY_RUN" == "true" ]]; then
                INSTALLED+=("  → .github/agents/$(basename "$agent") (would create)")
            else
                cp "$agent" "$TARGET_DIR/.github/agents/$(basename "$agent")"
                INSTALLED+=("  → .github/agents/$(basename "$agent")")
            fi
        done
    fi
}

pack_remove_from_providers() {
    local pack_name="$1"
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "  ${CYAN}(would remove provider copies for $pack_name)${NC}"
        return 0
    fi

    for skill in "$pack_dir"/claude/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.claude/skills/$(basename "$skill")"
    done
    for plugin in "$pack_dir"/claude/plugins/*/; do
        [[ -d "$plugin" ]] && rm -rf "$TARGET_DIR/.claude/plugins/$(basename "$plugin")"
    done
    for skill in "$pack_dir"/codex/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.agents/skills/$(basename "$skill")"
    done
    for skill in "$pack_dir"/antigravity/skills/*/; do
        [[ -d "$skill" ]] && rm -rf "$TARGET_DIR/.agent/skills/$(basename "$skill")"
    done
    for agent in "$pack_dir"/copilot/agents/*.agent.md; do
        [[ -f "$agent" ]] && rm -f "$TARGET_DIR/.github/agents/$(basename "$agent")"
    done
}

normalize_pack_name() {
    local input="$1"
    if [[ "$input" == afx-pack-* ]]; then
        echo "$input"
    else
        echo "afx-pack-$input"
    fi
}

# Install a pack: fetch manifest → download → detect → route → copy → state
pack_install() {
    local input_name="$1"
    local ref_override="${2:-}"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local ref
    if [[ -n "$ref_override" ]]; then
        ref="$ref_override"
    else
        ref=$(resolve_ref) || exit 1
    fi
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    echo -e "${BLUE}Installing pack '$pack_name' (ref: $ref)...${NC}"

    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$TARGET_DIR/.afx/.cache"
    fi
    ensure_gitignore ".afx/"

    local manifest
    manifest=$(fetch_manifest "$pack_name" "$ref") || exit 1

    local platforms
    platforms=$(parse_platforms "$manifest")

    while IFS= read -r include_line; do
        [[ -z "$include_line" ]] && continue

        local repo path
        repo=$(echo "$include_line" | awk '{print $1}')
        path=$(echo "$include_line" | awk '{print $2}')
        local items_str
        items_str=$(echo "$include_line" | cut -d' ' -f3-)

        local item_ref="main"
        if [[ "$repo" == "${AFX_REPO}" ]]; then
            item_ref="$ref"
        fi

        echo -e "  ${CYAN}Downloading from ${repo} (ref: ${item_ref})...${NC}"

        local temp
        temp=$(download_items "$repo" "$item_ref" "$path" $items_str)

        if [[ "$DRY_RUN" != "true" ]]; then
            mkdir -p "$pack_dir"
        fi

        for item_name in $items_str; do
            local item_dir="$temp/${path}${item_name}"
            if [[ ! -d "$item_dir" ]]; then
                echo -e "  ${YELLOW}Warning: '$item_name' not found in download — skipping${NC}"
                continue
            fi

            local type
            type=$(detect_type "$item_dir" "$repo")
            echo -e "  ${GREEN}Found: $item_name (type: $type)${NC}"

            if [[ "$DRY_RUN" != "true" ]]; then
                route_item "$item_dir" "$item_name" "$type" "$pack_dir" "$platforms"
            else
                INSTALLED+=("  ↓ $item_name ($type)")
            fi
        done

        rm -rf "$temp"
    done < <(for_each_include "$manifest")

    pack_copy_to_providers "$pack_name"
    afx_yaml_set_pack "$pack_name" "enabled" "$ref"
    rm -f "$manifest"

    echo -e "${GREEN}Pack '$pack_name' installed and enabled (ref: $ref).${NC}"
    echo ""
}

pack_enable() {
    local input_name="$1"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    if [[ ! -d "$pack_dir" ]]; then
        echo -e "${RED}Error: Pack '$pack_name' not found. Install it first with --pack $pack_name${NC}"
        exit 1
    fi

    pack_copy_to_providers "$pack_name"
    afx_yaml_set_pack "$pack_name" "enabled"
    echo -e "${GREEN}Pack '$pack_name' enabled.${NC}"
}

pack_disable() {
    local input_name="$1"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    if [[ ! -d "$pack_dir" ]]; then
        echo -e "${RED}Error: Pack '$pack_name' not installed.${NC}"
        exit 1
    fi

    pack_remove_from_providers "$pack_name"
    afx_yaml_set_pack "$pack_name" "disabled"
    echo -e "${YELLOW}Pack '$pack_name' disabled. Master preserved in .afx/${NC}"
}

pack_remove() {
    local input_name="$1"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    pack_remove_from_providers "$pack_name"
    [[ "$DRY_RUN" != "true" ]] && rm -rf "$pack_dir"
    afx_yaml_remove_pack "$pack_name"
    echo -e "${YELLOW}Pack '$pack_name' removed entirely.${NC}"
}

skill_disable() {
    local skill_name="$1"
    local input_name="$2"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")

    if [[ "$DRY_RUN" != "true" ]]; then
        rm -rf "$TARGET_DIR/.claude/skills/$skill_name"
        rm -rf "$TARGET_DIR/.claude/plugins/$skill_name"
        rm -rf "$TARGET_DIR/.agents/skills/$skill_name"
        rm -rf "$TARGET_DIR/.agent/skills/$skill_name"
        rm -f  "$TARGET_DIR/.github/agents/${skill_name}.agent.md"
    fi

    afx_yaml_disable_item "$pack_name" "$skill_name"
    echo -e "${YELLOW}Skill '$skill_name' disabled in pack '${pack_name}'.${NC}"
}

skill_enable() {
    local skill_name="$1"
    local input_name="$2"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    check_collision "$skill_name" "$TARGET_DIR/.claude/skills" "$pack_name" || exit 1

    if [[ "$DRY_RUN" != "true" ]]; then
        for provider in claude codex antigravity copilot; do
            if [[ -d "$pack_dir/$provider/skills/$skill_name" ]]; then
                local target=$(provider_target_dir "$provider" "skills")
                mkdir -p "$target"
                cp -r "$pack_dir/$provider/skills/$skill_name" "$target/$skill_name"
            fi
            if [[ -d "$pack_dir/$provider/plugins/$skill_name" ]]; then
                local target=$(provider_target_dir "$provider" "plugins")
                mkdir -p "$target"
                cp -r "$pack_dir/$provider/plugins/$skill_name" "$target/$skill_name"
            fi
            if [[ -f "$pack_dir/$provider/agents/${skill_name}.agent.md" ]]; then
                mkdir -p "$TARGET_DIR/.github/agents"
                cp "$pack_dir/$provider/agents/${skill_name}.agent.md" \
                   "$TARGET_DIR/.github/agents/${skill_name}.agent.md"
            fi
        done
    fi

    afx_yaml_enable_item "$pack_name" "$skill_name"
    echo -e "${GREEN}Skill '$skill_name' re-enabled in pack '${pack_name}'.${NC}"
}

pack_list() {
    local has_packs=false

    echo -e "${BLUE}Installed packs:${NC}"
    echo ""

    while IFS=: read -r name status disabled_count; do
        has_packs=true
        if [[ "$status" == "enabled" ]]; then
            echo -e "  ${GREEN}●${NC} $name (enabled)"
        else
            echo -e "  ${YELLOW}○${NC} $name (disabled)"
        fi
        if [[ "$disabled_count" -gt 0 ]]; then
            echo "    $disabled_count items disabled"
        fi
    done < <(afx_yaml_all_packs)

    if [[ "$has_packs" == "false" ]]; then
        echo "  (none)"
        echo ""
        echo "Install a pack:"
        echo "  ./install.sh --pack qa ."
    fi
}

pack_update_all() {
    echo -e "${BLUE}Updating installed packs...${NC}"
    echo ""

    local index_ref
    index_ref=$(resolve_ref) || exit 1
    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$TARGET_DIR/.afx/.cache"
        curl -sL "https://raw.githubusercontent.com/${AFX_REPO}/${index_ref}/packs/index.json" \
            > "$TARGET_DIR/.afx/.cache/lastIndex.json" 2>/dev/null
    fi

    local updated=0
    for pack_name in $(afx_yaml_enabled_packs); do
        local pack_ref
        pack_ref=$(afx_yaml_pack_ref "$pack_name")
        echo -e "${BLUE}Updating $pack_name (ref: $pack_ref)...${NC}"
        pack_remove_from_providers "$pack_name"
        [[ "$DRY_RUN" != "true" ]] && rm -rf "$TARGET_DIR/.afx/packs/$pack_name"
        pack_install "$pack_name" "$pack_ref"
        ((updated++))
    done

    if [[ "$updated" -eq 0 ]]; then
        echo "  No enabled packs to update."
    fi
}

add_skill() {
    local spec="$1"
    local repo="${spec%%:*}"
    local full_path="${spec#*:}"
    local skill_name=$(basename "$full_path")
    local base_path="$(dirname "$full_path")/"

    echo -e "${BLUE}Installing skill '$skill_name' from $repo...${NC}"

    local temp
    temp=$(download_items "$repo" "main" "$base_path" "$skill_name")

    local item_dir="$temp/${base_path}${skill_name}"
    if [[ ! -d "$item_dir" ]]; then
        echo -e "${RED}Error: Skill '$skill_name' not found in $repo${NC}"
        rm -rf "$temp"
        exit 1
    fi

    local type
    type=$(detect_type "$item_dir" "$repo")

    if [[ "$DRY_RUN" != "true" ]]; then
        case "$type" in
            skill)
                mkdir -p "$TARGET_DIR/.claude/skills/$skill_name"
                cp -r "$item_dir"/. "$TARGET_DIR/.claude/skills/$skill_name/"
                mkdir -p "$TARGET_DIR/.agents/skills/$skill_name"
                cp -r "$item_dir"/. "$TARGET_DIR/.agents/skills/$skill_name/"
                mkdir -p "$TARGET_DIR/.agent/skills/$skill_name"
                cp -r "$item_dir"/. "$TARGET_DIR/.agent/skills/$skill_name/"
                ;;
            plugin)
                mkdir -p "$TARGET_DIR/.claude/plugins/$skill_name"
                cp -r "$item_dir"/. "$TARGET_DIR/.claude/plugins/$skill_name/"
                ;;
            openai)
                mkdir -p "$TARGET_DIR/.agents/skills/$skill_name"
                cp -r "$item_dir"/. "$TARGET_DIR/.agents/skills/$skill_name/"
                ;;
        esac
    fi

    rm -rf "$temp"
    afx_yaml_add_custom_skill "$repo" "$full_path"
    echo -e "${GREEN}Skill '$skill_name' installed from $repo.${NC}"
}

# ============================================================================
# Section 9: Install Step Functions (modular)
# ============================================================================

step_claude_commands() {
    echo -e "${BLUE}Installing Claude slash commands...${NC}"
    local dir="$TARGET_DIR/.claude/commands"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    for cmd in "$AFX_DIR"/.claude/commands/afx-*.md; do
        if [ -f "$cmd" ]; then
            local filename=$(basename "$cmd")
            install_file "$cmd" "$dir/$filename" "Command: $filename" "$UPDATE_MODE"
        fi
    done
}

step_codex_skills() {
    echo -e "${BLUE}Installing Codex skills...${NC}"
    local dir="$TARGET_DIR/.codex/skills"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    if [ -d "$AFX_DIR/.codex/skills" ]; then
        for skill_dir in "$AFX_DIR"/.codex/skills/afx-*; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                install_directory "$skill_dir" "$dir/$skill_name" "Codex skill: $skill_name" "$UPDATE_MODE"
            fi
        done
    fi
}

step_antigravity_skills() {
    echo -e "${BLUE}Installing Antigravity skills...${NC}"
    local dir="$TARGET_DIR/.agent/skills"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    if [ -d "$AFX_DIR/.agent/skills" ]; then
        for skill_dir in "$AFX_DIR"/.agent/skills/afx-*; do
            if [ -d "$skill_dir" ]; then
                local skill_name=$(basename "$skill_dir")
                install_directory "$skill_dir" "$dir/$skill_name" "Antigravity skill: $skill_name" "$UPDATE_MODE"
            fi
        done
    fi
}

step_gemini_commands() {
    echo -e "${BLUE}Installing Gemini CLI commands...${NC}"
    local dir="$TARGET_DIR/.gemini/commands"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    if [ -d "$AFX_DIR/.gemini/commands" ]; then
        for cmd in "$AFX_DIR"/.gemini/commands/afx-*.toml; do
            if [ -f "$cmd" ]; then
                local filename=$(basename "$cmd")
                install_file "$cmd" "$dir/$filename" "Gemini command: $filename" "$UPDATE_MODE"
            fi
        done
    fi
}

step_copilot_prompts() {
    echo -e "${BLUE}Installing GitHub Copilot prompts...${NC}"
    local dir="$TARGET_DIR/.github/prompts"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    if [ -d "$AFX_DIR/.github/prompts" ]; then
        for prompt in "$AFX_DIR"/.github/prompts/afx-*.prompt.md; do
            if [ -f "$prompt" ]; then
                local filename=$(basename "$prompt")
                install_file "$prompt" "$dir/$filename" "Copilot prompt: $filename" "$UPDATE_MODE"
            fi
        done
        if [ -f "$AFX_DIR/.github/prompts/README.md" ]; then
            install_file "$AFX_DIR/.github/prompts/README.md" "$dir/README.md" "Copilot prompts README" "$UPDATE_MODE"
        fi
    fi
}

step_templates() {
    echo -e "${BLUE}Installing templates...${NC}"
    local dir="$TARGET_DIR/docs/agenticflowx/templates"

    if [ -d "$AFX_DIR/templates" ]; then
        for tpl in "$AFX_DIR"/templates/*.md; do
            if [ -f "$tpl" ]; then
                local filename=$(basename "$tpl")
                install_file "$tpl" "$dir/$filename" "Template: $filename" "$UPDATE_MODE"
            fi
        done
    fi
}

step_config() {
    echo -e "${BLUE}Managing configuration...${NC}"

    # Ensure .afx/ folder exists
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$TARGET_DIR/.afx/.cache"
    ensure_gitignore ".afx/"

    # Managed defaults — always written/overwritten in .afx/.afx.yaml
    install_file "$AFX_DIR/.afx.yaml.template" "$TARGET_DIR/.afx/.afx.yaml" ".afx/.afx.yaml" "true"

    # User config — never overwritten (unless --force)
    if [ -f "$TARGET_DIR/.afx.yaml" ]; then
        if [ "$FORCE" = "true" ]; then
            if [[ "$DRY_RUN" == "true" ]]; then
                UPDATED+=(".afx.yaml (would reset to minimal)")
            else
                write_minimal_user_config
                UPDATED+=(".afx.yaml (reset to minimal)")
            fi
        else
            SKIPPED+=(".afx.yaml (preserved - user config)")
        fi
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            INSTALLED+=(".afx.yaml (would create)")
        else
            write_minimal_user_config
            INSTALLED+=(".afx.yaml (created with guide)")
        fi
    fi
}

step_claude_md() {
    echo -e "${BLUE}Updating CLAUDE.md...${NC}"
    local snippet_file="$AFX_DIR/prompts/complete.md"
    if [ -f "$snippet_file" ]; then
        local snippet_content
        snippet_content=$(sed -n '/^---$/,$p' "$snippet_file" | tail -n +2)
        update_md_with_markers \
            "$TARGET_DIR/CLAUDE.md" \
            "$AFX_START_MARKER" \
            "$AFX_END_MARKER" \
            "$snippet_content" \
            "CLAUDE.md" \
            "$(printf '# CLAUDE.md\n\nThis file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.\n')"
    fi
}

step_agents_md() {
    echo -e "${BLUE}Updating AGENTS.md...${NC}"
    local snippet_file="$AFX_DIR/prompts/agents.md"
    if [ -f "$snippet_file" ]; then
        local snippet_content
        snippet_content=$(sed -n '/^---$/,$p' "$snippet_file" | tail -n +2)
        update_md_with_markers \
            "$TARGET_DIR/AGENTS.md" \
            "$AFX_AGENTS_START_MARKER" \
            "$AFX_AGENTS_END_MARKER" \
            "$snippet_content" \
            "AGENTS.md" \
            "$(printf '# AGENTS.md\n\nProject instructions for Codex and compatible coding agents.\n')"
    fi
}

step_gemini_md() {
    echo -e "${BLUE}Updating GEMINI.md...${NC}"
    local snippet_file="$AFX_DIR/prompts/gemini.md"
    if [ -f "$snippet_file" ]; then
        local snippet_content
        snippet_content=$(sed -n '/^---$/,$p' "$snippet_file" | tail -n +2)
        update_md_with_markers \
            "$TARGET_DIR/GEMINI.md" \
            "$AFX_GEMINI_START_MARKER" \
            "$AFX_GEMINI_END_MARKER" \
            "$snippet_content" \
            "GEMINI.md" \
            "$(printf '# GEMINI.md\n\nProject context for Gemini CLI when working with code in this repository.\n')"
    fi
}

step_copilot_md() {
    echo -e "${BLUE}Updating copilot-instructions.md...${NC}"
    local snippet_file="$AFX_DIR/prompts/copilot.md"
    if [ -f "$snippet_file" ]; then
        local snippet_content
        snippet_content=$(sed -n '/^---$/,$p' "$snippet_file" | tail -n +2)
        [[ "$DRY_RUN" != "true" ]] && mkdir -p "$TARGET_DIR/.github"
        update_md_with_markers \
            "$TARGET_DIR/.github/copilot-instructions.md" \
            "$AFX_COPILOT_START_MARKER" \
            "$AFX_COPILOT_END_MARKER" \
            "$snippet_content" \
            "copilot-instructions.md" \
            ""
    fi
}

step_docs() {
    echo -e "${BLUE}Installing AFX documentation...${NC}"
    local dir="$TARGET_DIR/docs/agenticflowx"
    [[ "$DRY_RUN" != "true" ]] && mkdir -p "$dir"

    for doc in "agenticflowx.md" "guide.md" "cheatsheet.md" "multi-agent.md"; do
        if [ -f "$AFX_DIR/docs/agenticflowx/$doc" ]; then
            install_file "$AFX_DIR/docs/agenticflowx/$doc" "$dir/$doc" "AFX Doc: $doc" "$UPDATE_MODE"
        fi
    done
}

# Strip AFX boundary-marked section from a markdown file.
# If the file becomes empty (only whitespace) after stripping, delete it.
# Usage: strip_afx_section <file> <start_marker> <end_marker> <label>
strip_afx_section() {
    local file="$1"
    local start_marker="$2"
    local end_marker="$3"
    local label="$4"

    [[ -f "$file" ]] || return 0

    if ! grep -q "$start_marker" "$file" 2>/dev/null; then
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        REMOVED+=("$label (would strip AFX section)")
        return 0
    fi

    # Remove the AFX section (start marker through end marker, inclusive)
    awk -v start="$start_marker" -v end="$end_marker" '
        $0 == start { skip=1; next }
        $0 == end { skip=0; next }
        !skip { print }
    ' "$file" > "$file.tmp"

    # Check if file is now empty (only whitespace)
    if [[ ! -s "$file.tmp" ]] || ! grep -q '[^[:space:]]' "$file.tmp" 2>/dev/null; then
        rm -f "$file" "$file.tmp"
        REMOVED+=("$label (deleted — empty after stripping)")
    else
        mv "$file.tmp" "$file"
        REMOVED+=("$label (AFX section stripped)")
    fi
}

# Count files matching a glob pattern (returns 0 if none)
count_glob() {
    local pattern="$1"
    local count=0
    for f in $pattern; do
        [[ -e "$f" ]] && ((count++))
    done
    echo "$count"
}

# Remove files/dirs matching a glob, with summary
# Usage: remove_glob <pattern> <label> <type> (type: "file" or "dir")
remove_glob() {
    local pattern="$1"
    local label="$2"
    local type="$3"
    local count=$(count_glob "$pattern")

    if [[ "$count" -eq 0 ]]; then
        return 0
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
        REMOVED+=("$label ($count items would be removed)")
        return 0
    fi

    if [[ "$type" == "dir" ]]; then
        rm -rf $pattern
    else
        rm -f $pattern
    fi
    REMOVED+=("$label ($count items removed)")
}

step_reset() {
    local REMOVED=()
    local step=0
    local total=6

    # ── Step 1: Agent commands/skills ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Remove AFX agent commands and skills${NC}"

    local has_items=false
    local items_preview=""
    for check in \
        ".claude/commands/afx-*.md" \
        ".codex/skills/afx-*" \
        ".agent/skills/afx-*" \
        ".gemini/commands/afx-*.toml" \
        ".github/prompts/afx-*.prompt.md"; do
        local c=$(count_glob "$TARGET_DIR/$check")
        if [[ "$c" -gt 0 ]]; then
            has_items=true
            items_preview+="      ${DIM}$check ($c items)${NC}\n"
        fi
    done
    # Pack-installed items
    for check in \
        ".claude/skills/*" \
        ".claude/plugins/*" \
        ".agents/skills/*" \
        ".github/agents/*"; do
        local c=$(count_glob "$TARGET_DIR/$check")
        if [[ "$c" -gt 0 ]]; then
            has_items=true
            items_preview+="      ${DIM}$check ($c items)${NC}\n"
        fi
    done

    if [[ "$has_items" == "true" ]]; then
        echo -e "$items_preview"
        if confirm "  Remove these?"; then
            remove_glob "$TARGET_DIR/.claude/commands/afx-*.md" ".claude/commands/afx-*.md" "file"
            remove_glob "$TARGET_DIR/.codex/skills/afx-*" ".codex/skills/afx-*" "dir"
            remove_glob "$TARGET_DIR/.agent/skills/afx-*" ".agent/skills/afx-*" "dir"
            remove_glob "$TARGET_DIR/.gemini/commands/afx-*.toml" ".gemini/commands/afx-*.toml" "file"
            remove_glob "$TARGET_DIR/.github/prompts/afx-*.prompt.md" ".github/prompts/afx-*.prompt.md" "file"
            remove_glob "$TARGET_DIR/.github/prompts/README.md" ".github/prompts/README.md" "file"
            # Pack-installed items
            remove_glob "$TARGET_DIR/.claude/skills/*" ".claude/skills/ (pack items)" "dir"
            remove_glob "$TARGET_DIR/.claude/plugins/*" ".claude/plugins/ (pack items)" "dir"
            remove_glob "$TARGET_DIR/.agents/skills/*" ".agents/skills/ (pack items)" "dir"
            remove_glob "$TARGET_DIR/.github/agents/*" ".github/agents/ (pack items)" "file"
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(no AFX commands/skills found)${NC}"
    fi
    echo ""

    # ── Step 2: Strip AFX sections from MD files ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Strip AFX sections from MD files${NC}"

    local md_targets=()
    [[ -f "$TARGET_DIR/CLAUDE.md" ]] && grep -q "$AFX_START_MARKER" "$TARGET_DIR/CLAUDE.md" 2>/dev/null && md_targets+=("CLAUDE.md")
    [[ -f "$TARGET_DIR/AGENTS.md" ]] && grep -q "$AFX_AGENTS_START_MARKER" "$TARGET_DIR/AGENTS.md" 2>/dev/null && md_targets+=("AGENTS.md")
    [[ -f "$TARGET_DIR/GEMINI.md" ]] && grep -q "$AFX_GEMINI_START_MARKER" "$TARGET_DIR/GEMINI.md" 2>/dev/null && md_targets+=("GEMINI.md")
    [[ -f "$TARGET_DIR/.github/copilot-instructions.md" ]] && grep -q "$AFX_COPILOT_START_MARKER" "$TARGET_DIR/.github/copilot-instructions.md" 2>/dev/null && md_targets+=("copilot-instructions.md")

    if [[ ${#md_targets[@]} -gt 0 ]]; then
        echo -e "      ${DIM}${md_targets[*]}${NC}"
        if confirm "  Strip AFX sections? (user content preserved)"; then
            strip_afx_section "$TARGET_DIR/CLAUDE.md" "$AFX_START_MARKER" "$AFX_END_MARKER" "CLAUDE.md"
            strip_afx_section "$TARGET_DIR/AGENTS.md" "$AFX_AGENTS_START_MARKER" "$AFX_AGENTS_END_MARKER" "AGENTS.md"
            strip_afx_section "$TARGET_DIR/GEMINI.md" "$AFX_GEMINI_START_MARKER" "$AFX_GEMINI_END_MARKER" "GEMINI.md"
            strip_afx_section "$TARGET_DIR/.github/copilot-instructions.md" "$AFX_COPILOT_START_MARKER" "$AFX_COPILOT_END_MARKER" "copilot-instructions.md"
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(no AFX sections found in MD files)${NC}"
    fi
    echo ""

    # ── Step 3: AFX documentation ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Remove AFX documentation${NC}"
    if [[ -d "$TARGET_DIR/docs/agenticflowx" ]]; then
        echo -e "      ${DIM}docs/agenticflowx/ (docs + templates)${NC}"
        if confirm "  Remove?"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                REMOVED+=("docs/agenticflowx/ (would remove)")
            else
                rm -rf "$TARGET_DIR/docs/agenticflowx"
                REMOVED+=("docs/agenticflowx/")
            fi
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(not found)${NC}"
    fi
    echo ""

    # ── Step 4: .afx/ folder ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Remove .afx/ folder${NC}"
    if [[ -d "$TARGET_DIR/.afx" ]]; then
        echo -e "      ${DIM}.afx/ (packs, cache, managed config)${NC}"
        if confirm "  Remove?"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                REMOVED+=(".afx/ folder (would remove)")
            else
                rm -rf "$TARGET_DIR/.afx"
                REMOVED+=(".afx/ folder")
            fi
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(not found)${NC}"
    fi
    echo ""

    # ── Step 5: .afx.yaml ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Remove .afx.yaml${NC}"
    if [[ -f "$TARGET_DIR/.afx.yaml" ]]; then
        echo -e "      ${DIM}.afx.yaml (user config)${NC}"
        if confirm "  Remove?"; then
            if [[ "$DRY_RUN" == "true" ]]; then
                REMOVED+=(".afx.yaml (would remove)")
            else
                rm -f "$TARGET_DIR/.afx.yaml"
                REMOVED+=(".afx.yaml")
            fi
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(not found)${NC}"
    fi
    echo ""

    # ── Step 6: .gitignore cleanup ──
    ((step++))
    echo -e "${DIM}[${step}/${total}]${NC} ${BOLD}Clean .gitignore${NC}"
    if [[ -f "$TARGET_DIR/.gitignore" ]] && grep -q "^\.afx/" "$TARGET_DIR/.gitignore" 2>/dev/null; then
        if confirm "  Remove '.afx/' entry from .gitignore?"; then
            if [[ "$DRY_RUN" != "true" ]]; then
                sed -i.bak '/^\.afx\/$/d' "$TARGET_DIR/.gitignore"
                rm -f "$TARGET_DIR/.gitignore.bak"
            fi
            REMOVED+=(".gitignore (.afx/ entry)")
        else
            echo -e "  ${YELLOW}Skipped${NC}"
        fi
    else
        echo -e "  ${DIM}(no .afx/ entry)${NC}"
    fi
    echo ""

    # ── Summary ──
    if [[ ${#REMOVED[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Removed:${NC}"
        for item in "${REMOVED[@]}"; do
            echo "  - $item"
        done
    fi
}

step_directories() {
    echo -e "${BLUE}Creating directory structure...${NC}"
    if [ "$DRY_RUN" != "true" ]; then
        mkdir -p "$TARGET_DIR/docs/specs"
        mkdir -p "$TARGET_DIR/docs/adr"
        mkdir -p "$TARGET_DIR/docs/research"
    fi
    if [ ! -d "$TARGET_DIR/docs/specs" ]; then INSTALLED+=("docs/specs/ directory"); fi
    if [ ! -d "$TARGET_DIR/docs/adr" ]; then INSTALLED+=("docs/adr/ directory"); fi
    if [ ! -d "$TARGET_DIR/docs/research" ]; then INSTALLED+=("docs/research/ directory"); fi
}

# ============================================================================
# Section 10: Main Flow
# ============================================================================

# Validate target directory
if [ -z "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Target project path required${NC}"
    echo "Usage: ./install.sh [--update] /path/to/project"
    exit 1
fi

TARGET_DIR=$(cd "$TARGET_DIR" 2>/dev/null && pwd || echo "$TARGET_DIR")

if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory does not exist: $TARGET_DIR${NC}"
    exit 1
fi

# Resolve AFX version
_afx_ref="main"
if [[ -n "$VERSION" ]]; then
    _afx_ref=$([[ "$VERSION" == v* ]] && echo "$VERSION" || echo "v$VERSION")
elif [[ -n "$BRANCH" ]]; then
    _afx_ref="$BRANCH"
elif [[ -f "$TARGET_DIR/.afx.yaml" ]]; then
    _yaml_ver=$(grep '^version:' "$TARGET_DIR/.afx.yaml" 2>/dev/null | awk '{print $2}' | tr -d "'\"")
    if [[ -n "$_yaml_ver" && "$_yaml_ver" != "main" ]]; then
        if [[ "$_yaml_ver" =~ ^[0-9] ]]; then
            _afx_ref=$([[ "$_yaml_ver" == v* ]] && echo "$_yaml_ver" || echo "v$_yaml_ver")
        else
            _afx_ref="$_yaml_ver"
        fi
    fi
fi
AFX_VERSION=$(curl -sL "https://raw.githubusercontent.com/${AFX_REPO}/${_afx_ref}/CHANGELOG.md" | awk '/^## \[/ {print substr($2, 2, length($2)-2); exit}')
if [ -z "$AFX_VERSION" ]; then
    AFX_VERSION="Unknown"
fi

# Header
echo ""
if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${BLUE}${BOLD}AFX Updater v${AFX_VERSION}${NC}"
else
    echo -e "${BLUE}${BOLD}AFX Installer v${AFX_VERSION}${NC}"
fi
echo -e "${DIM}Target: $TARGET_DIR${NC}"
if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}(Dry run — no changes will be made)${NC}"
fi
echo ""

# ── Pack-only operations (dispatch and exit) ──────────────────────────────

_pack_only=false
if [[ -n "$PACK_DISABLE" || -n "$PACK_ENABLE" || -n "$PACK_REMOVE" || "$PACK_LIST" == "true" \
    || -n "$SKILL_DISABLE" || -n "$SKILL_ENABLE" || ${#PACK_NAMES[@]} -gt 0 \
    || ( "$UPDATE_PACKS" == "true" && "$UPDATE_MODE" == "true" ) \
    || -n "$ADD_SKILL" ]]; then
    _pack_only=true
fi

PACK_OPERATION=false

if [[ ${#PACK_NAMES[@]} -gt 0 && -z "$SKILL_DISABLE" && -z "$SKILL_ENABLE" ]]; then
    PACK_OPERATION=true
    for name in "${PACK_NAMES[@]}"; do
        pack_install "$name"
    done
fi

if [[ -n "$PACK_DISABLE" ]]; then
    PACK_OPERATION=true
    pack_disable "$PACK_DISABLE"
fi

if [[ -n "$PACK_ENABLE" ]]; then
    PACK_OPERATION=true
    pack_enable "$PACK_ENABLE"
fi

if [[ -n "$PACK_REMOVE" ]]; then
    PACK_OPERATION=true
    pack_remove "$PACK_REMOVE"
fi

if [[ "$PACK_LIST" == "true" ]]; then
    PACK_OPERATION=true
    pack_list
fi

if [[ -n "$SKILL_DISABLE" ]]; then
    PACK_OPERATION=true
    if [[ ${#PACK_NAMES[@]} -eq 0 ]]; then
        echo -e "${RED}Error: --skill-disable requires --pack${NC}"
        exit 1
    fi
    skill_disable "$SKILL_DISABLE" "${PACK_NAMES[0]}"
fi

if [[ -n "$SKILL_ENABLE" ]]; then
    PACK_OPERATION=true
    if [[ ${#PACK_NAMES[@]} -eq 0 ]]; then
        echo -e "${RED}Error: --skill-enable requires --pack${NC}"
        exit 1
    fi
    skill_enable "$SKILL_ENABLE" "${PACK_NAMES[0]}"
fi

if [[ "$UPDATE_MODE" == "true" && "$UPDATE_PACKS" == "true" ]]; then
    PACK_OPERATION=true
    pack_update_all
fi

if [[ -n "$ADD_SKILL" ]]; then
    PACK_OPERATION=true
    add_skill "$ADD_SKILL"
fi

if [[ "$PACK_OPERATION" == "true" ]]; then
    echo ""
    echo -e "${GREEN}Done!${NC}"
    [ ${#INSTALLED[@]} -gt 0 ] && echo "" && echo "Installed:" && printf '  + %s\n' "${INSTALLED[@]}"
    [ ${#UPDATED[@]} -gt 0 ] && echo "" && echo "Updated:" && printf '  ~ %s\n' "${UPDATED[@]}"
    exit 0
fi

# ── Core Install / Update ────────────────────────────────────────────────

# Determine AFX source directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [ -z "$SCRIPT_DIR" ] || [ ! -f "$SCRIPT_DIR/.afx.yaml.template" ]; then
    echo -e "${YELLOW}Downloading AFX from GitHub...${NC}"
    TEMP_DIR=$(mktemp -d)
    trap "rm -rf $TEMP_DIR" EXIT

    clone_branch="${_afx_ref:-main}"
    git clone --depth 1 --branch "$clone_branch" --quiet https://github.com/${AFX_REPO}.git "$TEMP_DIR/afx" 2>/dev/null || {
        echo -e "${RED}Error: Failed to clone AFX repository${NC}"
        echo "Check your internet connection or clone manually:"
        echo "  git clone https://github.com/${AFX_REPO}.git"
        exit 1
    }
    AFX_DIR="$TEMP_DIR/afx"
else
    AFX_DIR="$SCRIPT_DIR"
fi

# Handle --reset (full uninstall)
if [[ "$RESET" == "true" ]]; then
    echo -e "${YELLOW}${BOLD}AFX Reset — Full Uninstall${NC}"
    echo -e "${DIM}This will remove all AFX-installed files from your project.${NC}"
    echo ""

    step_reset

    echo ""
    echo -e "${GREEN}${BOLD}AFX has been fully removed.${NC}"
    echo ""
    echo -e "${BLUE}To re-install:${NC}"
    echo "  ./install.sh ."
    echo "  # or"
    echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/main/install.sh | bash -s -- ."
    echo ""
    exit 0
fi

# Provider selection
# - Fresh install: interactive provider menu (all providers if non-TTY/piped)
# - Update: always show provider menu (skills may have been added/updated)
# - Non-TTY/piped: defaults to all providers (use --no-* flags to exclude)
if [[ "$UPDATE_MODE" == "true" ]]; then
    # Load previously saved providers as defaults
    load_providers_from_yaml
    # Re-ask on update so user can add/remove providers
    # select_providers will skip if non-TTY/piped (saved providers used as-is)
    select_providers
elif [[ ! -f "$TARGET_DIR/.afx.yaml" ]]; then
    select_providers
else
    # Existing install, not --update: load saved providers
    load_providers_from_yaml
fi

# ── Step execution ─────────────────────────────────────────────────────────
# Each step checks provider flags and --no-* flags.

STEP=0
total_steps() {
    local count=0
    [[ "$INSTALL_CLAUDE" == "true" ]] && ((count++))
    [[ "$INSTALL_CODEX" == "true" ]] && ((count++))
    [[ "$INSTALL_ANTIGRAVITY" == "true" ]] && ((count++))
    [[ "$INSTALL_GEMINI" == "true" ]] && ((count++))
    [[ "$INSTALL_COPILOT" == "true" ]] && ((count++))
    ((count+=2))  # templates + config (always)
    [[ "$NO_CLAUDE_MD" != "true" ]] && ((count++))
    [[ "$NO_AGENTS_MD" != "true" ]] && ((count++))
    [[ "$NO_GEMINI_MD" != "true" ]] && ((count++))
    [[ "$NO_COPILOT_MD" != "true" ]] && ((count++))
    [[ "$NO_DOCS" != "true" ]] && ((count++))
    ((count++))  # directory structure
    echo "$count"
}

TOTAL=$(total_steps)

run_step() {
    local label="$1"
    local func="$2"
    ((STEP++))
    echo -e "${DIM}[${STEP}/${TOTAL}]${NC} ${label}"
    "$func"
    echo ""
}

# Provider-gated steps
if [[ "$INSTALL_CLAUDE" == "true" ]]; then
    run_step "Claude slash commands" step_claude_commands
fi

if [[ "$INSTALL_CODEX" == "true" ]]; then
    run_step "Codex skills" step_codex_skills
fi

if [[ "$INSTALL_ANTIGRAVITY" == "true" ]]; then
    run_step "Antigravity skills" step_antigravity_skills
fi

if [[ "$INSTALL_GEMINI" == "true" ]]; then
    run_step "Gemini CLI commands" step_gemini_commands
fi

if [[ "$INSTALL_COPILOT" == "true" ]]; then
    run_step "GitHub Copilot prompts" step_copilot_prompts
fi

# Commands-only exit
if [ "$COMMANDS_ONLY" = "true" ]; then
    echo ""
    echo -e "${GREEN}Commands processed!${NC}"
    echo ""
    [ ${#INSTALLED[@]} -gt 0 ] && echo "Installed: ${#INSTALLED[@]}" && printf '  + %s\n' "${INSTALLED[@]}"
    [ ${#UPDATED[@]} -gt 0 ] && echo "Updated: ${#UPDATED[@]}" && printf '  ~ %s\n' "${UPDATED[@]}"
    [ ${#SKIPPED[@]} -gt 0 ] && echo "Skipped: ${#SKIPPED[@]}" && printf '  - %s\n' "${SKIPPED[@]}"
    exit 0
fi

# Always-available steps
run_step "Templates" step_templates
run_step "Configuration (.afx.yaml)" step_config

# Persist provider selection to .afx.yaml
save_providers_to_yaml

# MD integration steps (gated by --no-* flags)
if [[ "$NO_CLAUDE_MD" != "true" ]]; then
    run_step "CLAUDE.md integration" step_claude_md
fi

if [[ "$NO_AGENTS_MD" != "true" ]]; then
    run_step "AGENTS.md integration" step_agents_md
fi

if [[ "$NO_GEMINI_MD" != "true" ]]; then
    run_step "GEMINI.md integration" step_gemini_md
fi

if [[ "$NO_COPILOT_MD" != "true" ]]; then
    run_step "copilot-instructions.md integration" step_copilot_md
fi

if [[ "$NO_DOCS" != "true" ]]; then
    run_step "AFX documentation" step_docs
fi

run_step "Directory structure" step_directories

# ============================================================================
# Summary
# ============================================================================

echo ""
if [ "$UPDATE_MODE" = "true" ]; then
    echo -e "${GREEN}${BOLD}AFX Update Complete! (v${AFX_VERSION})${NC}"
else
    echo -e "${GREEN}${BOLD}AFX Installation Complete! (v${AFX_VERSION})${NC}"
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
    echo "  - Commands, skills, and templates were updated for selected providers"
    echo "  - .afx/.afx.yaml was updated (managed defaults)"
    echo "  - .afx.yaml was preserved (your config overrides)"
    echo "  - MD integration files were replaced (your content preserved)"
else
    echo -e "${BLUE}Next steps:${NC}"
    echo "  1. Edit .afx.yaml to configure your project"
    echo "  2. Run /afx:init feature <name> (Claude) or ask Codex to run afx-init"
    echo "  3. See docs/agenticflowx/ for AFX reference documentation"
    echo "  4. Run /afx:help (Claude) or afx-help (Codex) for command reference"
fi
echo ""
update_ref=$(resolve_ref)
echo -e "${CYAN}To update AFX later:${NC}"
echo "  ./install.sh --update ."
echo "  # or"
echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/${update_ref}/install.sh | bash -s -- --update ."
echo ""
