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

set -e

# AFX repository
AFX_REPO="rixrix/afx"
# AFX_VERSION is resolved after arg parsing (see below)

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

# Pack management options
# @see docs/specs/afx-packs/design.md#33-new-arguments
PACK_NAMES=()          # Array — supports --pack qa --pack security
PACK_DISABLE=""        # Single pack name
PACK_ENABLE=""         # Single pack name
PACK_REMOVE=""         # Single pack name
PACK_LIST=false
SKILL_DISABLE=""       # Skill name (requires --pack)
SKILL_ENABLE=""        # Skill name (requires --pack)
UPDATE_PACKS=false     # --update --packs
ADD_SKILL=""           # repo:path/skill format
BRANCH=""              # Branch name (e.g., dev, feature/packs)
VERSION=""             # Version tag (e.g., v1.5.3, 1.5.3)

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
        --pack)
            PACK_NAMES+=("$2")
            shift 2
            ;;
        --pack-disable)
            PACK_DISABLE="$2"
            shift 2
            ;;
        --pack-enable)
            PACK_ENABLE="$2"
            shift 2
            ;;
        --pack-remove)
            PACK_REMOVE="$2"
            shift 2
            ;;
        --pack-list)
            PACK_LIST=true
            shift
            ;;
        --skill-disable)
            SKILL_DISABLE="$2"
            shift 2
            ;;
        --skill-enable)
            SKILL_ENABLE="$2"
            shift 2
            ;;
        --packs)
            UPDATE_PACKS=true
            shift
            ;;
        --add-skill)
            ADD_SKILL="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --version)
            VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "AFX Installer"
            echo ""
            echo "Usage: ./install.sh [OPTIONS] <target-project-path>"
            echo ""
            echo "Options:"
            echo "  --update          Update existing AFX installation"
            echo "  --commands-only   Only install/update command assets (.claude + .codex + .agent)"
            echo "  --no-claude-md    Skip CLAUDE.md snippet integration"
            echo "  --no-agents-md    Skip AGENTS.md snippet integration"
            echo "  --no-gemini-md    Skip GEMINI.md snippet integration"
            echo "  --no-copilot-md   Skip copilot-instructions.md snippet integration"
            echo "  --no-docs         Skip copying AFX documentation to docs/agenticflowx/"
            echo "  --force           Overwrite all files (fresh install)"
            echo "  --dry-run         Preview changes without applying"
            echo "  --branch NAME     Use a specific branch (default: main)"
            echo "  --version TAG     Use a specific version tag (e.g., 1.5.3 or v1.5.3)"
            echo "  -h, --help        Show this help message"
            echo ""
            echo "Pack Management:"
            echo "  --pack NAME                     Install and enable a pack"
            echo "  --pack-disable NAME             Disable a pack (keep master)"
            echo "  --pack-enable NAME              Re-enable a disabled pack"
            echo "  --pack-remove NAME              Remove a pack entirely"
            echo "  --pack-list                     List installed packs"
            echo "  --skill-disable NAME --pack P   Disable a skill within a pack"
            echo "  --skill-enable NAME --pack P    Re-enable a skill within a pack"
            echo "  --update --packs                Update all enabled packs"
            echo "  --add-skill REPO:PATH/SKILL     Install a single skill (no pack)"
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
            echo "  # Install QA pack (short or full name)"
            echo "  ./install.sh --pack qa ."
            echo "  ./install.sh --pack afx-pack-qa ."
            echo ""
            echo "  # Install from version"
            echo "  ./install.sh --version 1.5.3 --pack qa ."
            echo ""
            echo "  # Multiple packs"
            echo "  ./install.sh --pack qa --pack security ."
            echo ""
            echo "  # Manage packs (short or full name)"
            echo "  ./install.sh --pack-disable afx-pack-qa ."
            echo "  ./install.sh --pack-enable qa ."
            echo "  ./install.sh --pack-list ."
            echo ""
            echo "  # Update all packs"
            echo "  ./install.sh --update --packs ."
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

# Resolve AFX version from CHANGELOG.md (uses same ref logic as resolve_ref)
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

# Check if this is a pack-only operation (no AFX source needed)
_pack_only=false
if [[ -n "$PACK_DISABLE" || -n "$PACK_ENABLE" || -n "$PACK_REMOVE" || "$PACK_LIST" == "true" \
    || -n "$SKILL_DISABLE" || -n "$SKILL_ENABLE" || ${#PACK_NAMES[@]} -gt 0 \
    || ( "$UPDATE_PACKS" == "true" && "$UPDATE_MODE" == "true" ) \
    || -n "$ADD_SKILL" ]]; then
    _pack_only=true
fi

# Determine AFX source directory (skip for pack-only operations)
if [[ "$_pack_only" != "true" ]]; then
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
# Pack Management Functions
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
        # Read version from .afx.yaml if it exists, otherwise default to main
        local yaml_version=""
        if [[ -f "$TARGET_DIR/.afx.yaml" ]]; then
            yaml_version=$(grep '^version:' "$TARGET_DIR/.afx.yaml" 2>/dev/null | awk '{print $2}' | tr -d "'\"")
        fi
        if [[ -n "$yaml_version" && "$yaml_version" != "main" ]]; then
            # Semver → tag, branch name → as-is
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

    # Tarball root is {repo-name}-{ref}/, so strip-components=1
    local repo_name="${repo##*/}"
    # Sanitize ref for tarball path (v1.5.3 → v1.5.3, main → main)
    local tar_ref="${ref#v}"  # GitHub strips v prefix in tarball dir names for tags
    # Actually GitHub uses the raw ref for branch names but strips v for tags... just try both
    # Simpler: strip-components=1 removes the top dir entirely, then we match by base_path

    local patterns=()
    for item in "${items[@]}"; do
        patterns+=("${base_path}${item}")
    done

    # Download entire tarball and extract matching paths
    curl -sL "$url" | tar xz -C "$temp_dir" --strip-components=1 2>/dev/null

    # If base_path is non-empty, the extracted items are under temp_dir/base_path/
    # Return temp_dir so caller can find items at temp_dir/base_path/item_name/
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
        # Detect includes section
        if [[ "$line" == "includes:" ]]; then
            in_includes=true; continue
        fi
        # Exit includes on next top-level key (no indent)
        if $in_includes && [[ "$line" =~ ^[a-z] ]]; then
            [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
            break
        fi

        if $in_includes; then
            if [[ "$line" =~ ^\ \ -\ repo:\ (.+) ]]; then
                # Flush previous block
                [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
                current_repo="${BASH_REMATCH[1]}"
                current_path="" ; items=()
            elif [[ "$line" =~ ^\ \ \ \ path:\ (.+) ]]; then
                current_path="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^\ \ \ \ \ \ -\ ([^#]+) ]]; then
                # Strip trailing comments and whitespace
                local item_name="${BASH_REMATCH[1]}"
                item_name="${item_name%%#*}"
                item_name="${item_name%% }"
                item_name="${item_name%% }"
                items+=("$item_name")
            fi
        fi
    done < "$manifest"

    # Flush final block (if file ends inside includes)
    [[ -n "$current_repo" ]] && echo "$current_repo $current_path ${items[*]}"
}

# Parse platforms from manifest — returns space-separated "provider:value" pairs
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

# Check if a platform is enabled in the manifest (true or partial = enabled)
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
# Canonical SKILL.md uses HTML comment markers to delineate provider-specific
# command references:
#
#   <!-- @afx:provider-commands -->
#   - Use `/afx:check path` to verify execution flow
#   - Use `/afx:task audit` to verify test coverage
#   <!-- @afx:/provider-commands -->
#   - Follow the spec → design → tasks → code traceability chain
#
# Transform rules per provider:
#
#   Claude:       Strip markers, keep content as-is (canonical format)
#   Codex:        Strip markers, convert /afx:cmd sub → afx-cmd-sub
#   Antigravity:  Remove markers AND content between them (generic lines remain)
#   Copilot:      Generate condensed agent.md from SKILL.md structure
#
# Sed patterns used:
#   Strip markers:   /<!-- @afx:provider-commands -->/d
#                    /<!-- @afx:\/provider-commands -->/d
#   Codex commands:  s|/afx:\([a-z]*\) \([a-z]*\)|afx-\1-\2|g
#   Antigravity:     /<!-- @afx:provider-commands -->/,/<!-- @afx:\/provider-commands -->/d
#
# @see docs/specs/afx-packs/design.md#2-directory-layout
# ────────────────────────────────────────────────────────────────────────────

# Transform a canonical SKILL.md for a specific provider
# Usage: transform_for_provider <input_file> <output_file> <provider>
transform_for_provider() {
    local input="$1"
    local output="$2"
    local provider="$3"

    case "$provider" in
        claude)
            # Claude is the canonical format — strip markers, keep command lines
            sed \
                -e '/<!-- @afx:provider-commands -->/d' \
                -e '/<!-- @afx:\/provider-commands -->/d' \
                "$input" > "$output"
            ;;
        codex)
            # Codex uses kebab-case skill names: /afx:check path → afx-check-path
            sed \
                -e '/<!-- @afx:provider-commands -->/d' \
                -e '/<!-- @afx:\/provider-commands -->/d' \
                -e 's|`/afx:\([a-z]*\) \([a-z]*\)`|`afx-\1-\2`|g' \
                "$input" > "$output"
            ;;
        antigravity)
            # Antigravity omits platform-specific commands — remove marked block
            sed \
                '/<!-- @afx:provider-commands -->/,/<!-- @afx:\/provider-commands -->/d' \
                "$input" > "$output"
            ;;
        *)
            # Unknown provider — copy as-is
            cp "$input" "$output"
            ;;
    esac
}

# Generate a condensed Copilot agent.md from a canonical SKILL.md
# Copilot agents use YAML frontmatter + a flat numbered instruction list.
# Usage: generate_copilot_agent <input_file> <output_file> <skill_name>
#
# Extraction logic:
#   1. Title:        first "# " heading
#   2. Description:  first non-empty line after title (trimmed)
#   3. Instructions: numbered items (N. ...) and bullet items (- ...),
#                    excluding code blocks, markers, sub-headings, and
#                    provider-specific command lines
generate_copilot_agent() {
    local input="$1"
    local output="$2"
    local skill_name="$3"

    # Extract title (first level-1 heading, without the "# " prefix)
    local title
    title=$(grep -m1 '^# ' "$input" | sed 's/^# //')

    # Extract description (first non-empty, non-heading line after the title)
    local description
    description=$(awk 'NR>1 && /^[^#]/ && !/^$/ && !/^---/ { print; exit }' "$input")

    # Extract instruction items: numbered (1. ...) and bulleted (- ...)
    # Skip: code fences, markers, sub-headings (###), tables, blank lines
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

    # Renumber items sequentially (1., 2., 3., ...)
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

# Detect skill type and return target type string
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
            # Simple Skill → Claude + Codex + Antigravity (gated by manifest platforms)
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
            # Claude Plugin → Claude only
            if platform_enabled "$platforms" "claude"; then
                mkdir -p "$pack_dir/claude/plugins/$item_name"
                cp -r "$item_dir"/. "$pack_dir/claude/plugins/$item_name/"
            fi
            ;;
        openai)
            # OpenAI Skill → Codex only
            if platform_enabled "$platforms" "codex"; then
                mkdir -p "$pack_dir/codex/skills/$item_name"
                cp -r "$item_dir"/. "$pack_dir/codex/skills/$item_name/"
            fi
            ;;
        afx)
            # AFX-built → single canonical SKILL.md, transformed per provider
            local canonical="$item_dir/SKILL.md"
            if [[ ! -f "$canonical" ]]; then
                echo -e "${YELLOW}Warning: No SKILL.md in AFX skill '$item_name' — skipping${NC}"
                break
            fi
            # Transform for each SKILL.md provider (claude, codex, antigravity)
            for provider in claude codex antigravity; do
                if platform_enabled "$platforms" "$provider"; then
                    mkdir -p "$pack_dir/$provider/skills/$item_name"
                    transform_for_provider "$canonical" \
                        "$pack_dir/$provider/skills/$item_name/SKILL.md" \
                        "$provider"
                fi
            done
            # Generate condensed Copilot agent.md
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

# Check if a skill/plugin already exists in a provider dir from a DIFFERENT pack
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

# Ensure a pattern is in .gitignore
# @see docs/specs/afx-packs/design.md#310-helper-functions
ensure_gitignore() {
    local pattern="$1"
    local gitignore="$TARGET_DIR/.gitignore"

    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi

    if [[ -f "$gitignore" ]]; then
        grep -qF "$pattern" "$gitignore" || echo "$pattern" >> "$gitignore"
    else
        echo "$pattern" > "$gitignore"
    fi
}

# Map provider name to target directory
# @see docs/specs/afx-packs/design.md#310-helper-functions
provider_target_dir() {
    local provider="$1"
    local subdir="$2"    # "skills" or "plugins"

    case "$provider" in
        claude)       echo "$TARGET_DIR/.claude/$subdir" ;;
        codex)        echo "$TARGET_DIR/.agents/$subdir" ;;
        antigravity)  echo "$TARGET_DIR/.agent/$subdir" ;;
        copilot)      echo "$TARGET_DIR/.github/agents" ;;
    esac
}

# ============================================================================
# .afx.yaml Read/Write Helpers
# @see docs/specs/afx-packs/design.md#311-afxyaml-readwrite
# ============================================================================

# Read all enabled pack names from .afx.yaml
afx_yaml_enabled_packs() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    awk '/^packs:/,/^[^ ]/' "$yaml" | \
        grep -B1 'status: enabled' | \
        grep 'name:' | \
        awk '{print $3}'
}

# Read all packs — outputs "name:status:disabled_count" per line
afx_yaml_all_packs() {
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    local name="" status="" disabled_count=0 in_packs=false in_disabled=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" == "packs:" ]]; then
            in_packs=true; continue
        fi
        # End of packs section on unindented non-empty line
        if $in_packs && [[ -n "$line" ]] && [[ ! "$line" =~ ^\ \  ]]; then
            [[ -n "$name" ]] && echo "$name:$status:$disabled_count"
            break
        fi

        if $in_packs; then
            if [[ "$line" =~ ^\ \ -\ name:\ (.+) ]]; then
                # Flush previous
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
                : # Other pack fields
            else
                in_disabled=false
            fi
        fi
    done < "$yaml"

    # Flush final
    [[ -n "$name" ]] && echo "$name:$status:$disabled_count"
}

# Get installed_ref for a specific pack (defaults to "main")
afx_yaml_pack_ref() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || { echo "main"; return 0; }

    local found_pack=false

    while IFS= read -r line; do
        if [[ "$line" =~ name:\ $pack_name$ ]]; then
            found_pack=true; continue
        fi
        if $found_pack && [[ "$line" =~ ^\ \ -\ name: ]]; then
            break  # Next pack
        fi
        if $found_pack && [[ "$line" =~ ^\ \ \ \ installed_ref:\ (.+) ]]; then
            echo "${BASH_REMATCH[1]}"
            return 0
        fi
    done < "$yaml"

    echo "main"
}

# Get disabled items for a specific pack
afx_yaml_disabled_items() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    local found_pack=false in_disabled=false result=""

    while IFS= read -r line; do
        if [[ "$line" =~ name:\ $pack_name$ ]]; then
            found_pack=true; continue
        fi
        if $found_pack && [[ "$line" =~ ^\ \ -\ name: ]]; then
            break  # Next pack
        fi
        if $found_pack && [[ "$line" =~ disabled_items: ]]; then
            in_disabled=true; continue
        fi
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

# Set pack status in .afx.yaml (add if missing, update if exists)
afx_yaml_set_pack() {
    local pack_name="$1"
    local status="$2"
    local ref="${3:-}"
    local yaml="$TARGET_DIR/.afx.yaml"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "  ${CYAN}(would update .afx.yaml: $pack_name → $status)${NC}"
        return 0
    fi

    # Create file with packs section if it doesn't exist
    if [[ ! -f "$yaml" ]]; then
        echo "packs:" > "$yaml"
    fi

    # Check if pack already exists
    if grep -q "name: $pack_name" "$yaml" 2>/dev/null; then
        # Update status (and optionally ref) for this pack only
        local temp=$(mktemp)
        local in_target=false

        while IFS= read -r line || [[ -n "$line" ]]; do
            if [[ "$line" =~ ^\ \ -\ name:\ $pack_name$ ]]; then
                in_target=true
                echo "$line" >> "$temp"
            elif $in_target && [[ "$line" =~ ^\ \ -\ name: || ! "$line" =~ ^\ \  ]]; then
                # Reached next pack entry or non-indented line — stop editing
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
        # Append new pack entry
        # Ensure packs: section exists
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

# Remove pack entry from .afx.yaml
afx_yaml_remove_pack() {
    local pack_name="$1"
    local yaml="$TARGET_DIR/.afx.yaml"
    [[ -f "$yaml" ]] || return 0

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "  ${CYAN}(would remove $pack_name from .afx.yaml)${NC}"
        return 0
    fi

    # Remove the multi-line block for this pack (from "  - name: X" to next "  - name:" or end)
    local temp=$(mktemp)
    local skip=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ "$line" =~ ^\ \ -\ name:\ $pack_name$ ]]; then
            skip=true; continue
        fi
        if $skip && [[ "$line" =~ ^\ \ -\ name: ]]; then
            skip=false
        fi
        if $skip && [[ -n "$line" ]] && [[ ! "$line" =~ ^\ \  ]]; then
            skip=false
        fi
        $skip || echo "$line"
    done < "$yaml" > "$temp"

    mv "$temp" "$yaml"
}

# Add item to disabled_items for a pack
afx_yaml_disable_item() {
    local pack_name="$1"
    local item_name="$2"
    local yaml="$TARGET_DIR/.afx.yaml"

    if [[ "$DRY_RUN" == "true" ]]; then return 0; fi

    # Replace "disabled_items: []" with actual list, or append to existing list
    if grep -A5 "name: $pack_name" "$yaml" | grep -q "disabled_items: \[\]"; then
        sed -i.bak "/name: $pack_name/,/disabled_items:/{s/disabled_items: \[\]/disabled_items:\n      - $item_name/;}" "$yaml"
        rm -f "$yaml.bak"
    else
        # Append after disabled_items: line for this pack
        sed -i.bak "/name: $pack_name/,/^  - name:\|^[^ ]/{/disabled_items:/a\\
      - $item_name
}" "$yaml"
        rm -f "$yaml.bak"
    fi
}

# Remove item from disabled_items for a pack
afx_yaml_enable_item() {
    local pack_name="$1"
    local item_name="$2"
    local yaml="$TARGET_DIR/.afx.yaml"

    if [[ "$DRY_RUN" == "true" ]]; then return 0; fi

    sed -i.bak "/      - $item_name/d" "$yaml"
    rm -f "$yaml.bak"

    # If no disabled items remain, restore "disabled_items: []"
    if ! grep -A20 "name: $pack_name" "$yaml" | grep -q "^      - "; then
        sed -i.bak "/name: $pack_name/,/^  - name:\|^[^ ]/{s/disabled_items:/disabled_items: []/;}" "$yaml"
        rm -f "$yaml.bak"
    fi
}

# Add custom skill to .afx.yaml
afx_yaml_add_custom_skill() {
    local repo="$1"
    local path="$2"
    local yaml="$TARGET_DIR/.afx.yaml"

    if [[ "$DRY_RUN" == "true" ]]; then return 0; fi

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
# Pack Lifecycle Functions
# @see docs/specs/afx-packs/design.md#39-state-transitions
# ============================================================================

# Copy all items from .afx/packs/{pack}/{provider}/ to provider dirs
# @see docs/specs/afx-packs/design.md#310-helper-functions
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

# Remove all items belonging to a pack from provider dirs
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

# Normalize pack name: accept both "qa" and "afx-pack-qa", always return full name.
# This allows callers (CLI, VSCode extension) to pass either form.
normalize_pack_name() {
    local input="$1"
    if [[ "$input" == afx-pack-* ]]; then
        echo "$input"
    else
        echo "afx-pack-$input"
    fi
}

# Install a pack: fetch manifest → download → detect → route → copy → state
# Usage: pack_install <name> [ref_override]
# If ref_override is provided, use it instead of resolve_ref() (used by pack_update_all)
# @see docs/specs/afx-packs/design.md#39-state-transitions
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

    # 1. Ensure .afx/ and .gitignore
    if [[ "$DRY_RUN" != "true" ]]; then
        mkdir -p "$TARGET_DIR/.afx/.cache"
    fi
    ensure_gitignore ".afx/"

    # 2. Fetch manifest
    local manifest
    manifest=$(fetch_manifest "$pack_name" "$ref") || exit 1

    # 3. Parse platforms
    local platforms
    platforms=$(parse_platforms "$manifest")

    # 4. For each includes entry, download items and route
    while IFS= read -r include_line; do
        [[ -z "$include_line" ]] && continue

        local repo path
        repo=$(echo "$include_line" | awk '{print $1}')
        path=$(echo "$include_line" | awk '{print $2}')
        # Remaining fields are items
        local items_str
        items_str=$(echo "$include_line" | cut -d' ' -f3-)

        local item_ref="main"
        if [[ "$repo" == "${AFX_REPO}" ]]; then
            item_ref="$ref"
        fi

        echo -e "  ${CYAN}Downloading from ${repo} (ref: ${item_ref})...${NC}"

        # Download
        local temp
        temp=$(download_items "$repo" "$item_ref" "$path" $items_str)

        if [[ "$DRY_RUN" != "true" ]]; then
            mkdir -p "$pack_dir"
        fi

        # Detect type and route each item
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

    # 5. Copy from master to provider dirs
    pack_copy_to_providers "$pack_name"

    # 6. Update .afx.yaml
    afx_yaml_set_pack "$pack_name" "enabled" "$ref"

    rm -f "$manifest"

    echo -e "${GREEN}Pack '$pack_name' installed and enabled (ref: $ref).${NC}"
    echo ""
}

# Enable a disabled pack (no download — restore from .afx/ master)
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

# Disable a pack (remove provider copies, keep master)
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

# Remove a pack entirely (master + provider copies + state)
pack_remove() {
    local input_name="$1"
    local pack_name
    pack_name=$(normalize_pack_name "$input_name")
    local pack_dir="$TARGET_DIR/.afx/packs/$pack_name"

    pack_remove_from_providers "$pack_name"

    if [[ "$DRY_RUN" != "true" ]]; then
        rm -rf "$pack_dir"
    fi

    afx_yaml_remove_pack "$pack_name"

    echo -e "${YELLOW}Pack '$pack_name' removed entirely.${NC}"
}

# Disable a specific skill within a pack
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

# Re-enable a specific skill within a pack
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

# List installed packs
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

# Update all enabled packs using each pack's installed_ref from .afx.yaml
pack_update_all() {
    echo -e "${BLUE}Updating installed packs...${NC}"
    echo ""

    # Fetch latest index using CLI ref (--branch/--version) or default
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
        if [[ "$DRY_RUN" != "true" ]]; then
            rm -rf "$TARGET_DIR/.afx/packs/$pack_name"
        fi
        pack_install "$pack_name" "$pack_ref"
        ((updated++))
    done

    if [[ "$updated" -eq 0 ]]; then
        echo "  No enabled packs to update."
    fi
}

# Install a one-off skill (no pack)
# @see docs/specs/afx-packs/design.md#39-state-transitions
add_skill() {
    local spec="$1"   # e.g., "anthropics/antigravity-awesome-skills:skills/some-niche-skill"
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
# Pack Dispatch — if any pack flag is set, handle and exit (skip core install)
# @see docs/specs/afx-packs/design.md#313-main-dispatch-logic
# ============================================================================

PACK_OPERATION=false

# Only install packs if --pack is used WITHOUT --skill-disable/--skill-enable
# (those flags reuse --pack as a reference, not an install target)
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

# If a pack operation was performed, print summary and exit
if [[ "$PACK_OPERATION" == "true" ]]; then
    echo ""
    echo -e "${GREEN}Done!${NC}"
    [ ${#INSTALLED[@]} -gt 0 ] && echo "" && echo "Installed:" && printf '  + %s\n' "${INSTALLED[@]}"
    [ ${#UPDATED[@]} -gt 0 ] && echo "" && echo "Updated:" && printf '  ~ %s\n' "${UPDATED[@]}"
    exit 0
fi

# ============================================================================
# 1. Install/Update Claude slash commands
# ============================================================================
echo -e "${BLUE}[1/12] Installing Claude slash commands...${NC}"
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
echo -e "${BLUE}[2/12] Installing Codex skills...${NC}"
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
# 3. Install/Update Antigravity skills
# ============================================================================
echo -e "${BLUE}[3/12] Installing Antigravity skills...${NC}"
ANTIGRAVITY_SKILLS_DIR="$TARGET_DIR/.agent/skills"

if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$ANTIGRAVITY_SKILLS_DIR"
fi

if [ -d "$AFX_DIR/.agent/skills" ]; then
    for skill_dir in "$AFX_DIR"/.agent/skills/afx-*; do
        if [ -d "$skill_dir" ]; then
            skill_name=$(basename "$skill_dir")
            install_directory "$skill_dir" "$ANTIGRAVITY_SKILLS_DIR/$skill_name" "Antigravity skill: $skill_name" "$UPDATE_MODE"
        fi
    done
fi

# ============================================================================
# 4. Install/Update Gemini CLI commands
# ============================================================================
echo -e "${BLUE}[4/12] Installing Gemini CLI commands...${NC}"
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
# 5. Install/Update GitHub Copilot prompts
# ============================================================================
echo -e "${BLUE}[5/12] Installing GitHub Copilot prompts...${NC}"
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
# 6. Install/Update templates
# ============================================================================
echo -e "${BLUE}[6/12] Installing templates...${NC}"
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
# 7. Create/Update .afx.yaml
# ============================================================================
echo -e "${BLUE}[7/12] Managing configuration...${NC}"
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
# 8. Update CLAUDE.md with boundary markers
# ============================================================================
if [ "$NO_CLAUDE_MD" != "true" ]; then
    echo -e "${BLUE}[8/12] Updating CLAUDE.md...${NC}"
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
    echo -e "${YELLOW}[8/12] Skipping CLAUDE.md (--no-claude-md)${NC}"
fi

# ============================================================================
# 9. Update AGENTS.md with boundary markers
# ============================================================================
if [ "$NO_AGENTS_MD" != "true" ]; then
    echo -e "${BLUE}[9/12] Updating AGENTS.md...${NC}"
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
    echo -e "${YELLOW}[9/12] Skipping AGENTS.md (--no-agents-md)${NC}"
fi

# ============================================================================
# 10. Update GEMINI.md with boundary markers
# ============================================================================
if [ "$NO_GEMINI_MD" != "true" ]; then
    echo -e "${BLUE}[10/12] Updating GEMINI.md...${NC}"
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
    echo -e "${YELLOW}[10/12] Skipping GEMINI.md (--no-gemini-md)${NC}"
fi

# ============================================================================
# 11. Update copilot-instructions.md with boundary markers
# ============================================================================
if [ "$NO_COPILOT_MD" != "true" ]; then
    echo -e "${BLUE}[11/12] Updating copilot-instructions.md...${NC}"
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
    echo -e "${YELLOW}[11/12] Skipping copilot-instructions.md (--no-copilot-md)${NC}"
fi

# ============================================================================
# 12. Install AFX documentation
# ============================================================================
if [ "$NO_DOCS" != "true" ]; then
    echo -e "${BLUE}[12/12] Installing AFX documentation...${NC}"
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
    echo -e "${YELLOW}[12/12] Skipping AFX documentation (--no-docs)${NC}"
fi
# ============================================================================
# Create directory structure
# ============================================================================
echo -e "${BLUE}[*] Creating directory structure...${NC}"
if [ "$DRY_RUN" != "true" ]; then
    mkdir -p "$TARGET_DIR/docs/specs"
    mkdir -p "$TARGET_DIR/docs/adr"
    mkdir -p "$TARGET_DIR/docs/research"
fi
if [ ! -d "$TARGET_DIR/docs/specs" ]; then
    INSTALLED+=("docs/specs/ directory")
fi
if [ ! -d "$TARGET_DIR/docs/adr" ]; then
    INSTALLED+=("docs/adr/ directory")
fi
if [ ! -d "$TARGET_DIR/docs/research" ]; then
    INSTALLED+=("docs/research/ directory")
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
update_ref=$(resolve_ref)
echo -e "${CYAN}To update AFX later:${NC}"
echo "  ./install.sh --update ."
echo "  # or"
echo "  curl -sL https://raw.githubusercontent.com/${AFX_REPO}/${update_ref}/install.sh | bash -s -- --update ."
echo ""
