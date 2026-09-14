#!/usr/bin/env bash
# Install the Tree-sitter parsers and queries used by init.lua.
#
# Why this exists: the configuration uses Neovim's built-in Tree-sitter API with
# no plugin manager, so parsers and queries live in the Neovim data directory
# instead of being fetched by a plugin. This script links the Arch grammar
# packages when they are installed, otherwise it builds each grammar from source,
# and it vendors the query files that Neovim's runtime does not ship.
#
# Usage:
#   tools/install-treesitter-parsers.sh [language ...]
#
# With no arguments it installs the full set used by init.lua. Named languages
# are installed alone. Every step skips work that is already done, so the script
# is safe to re-run.
#
# Requires: git, curl, a C compiler, and the tree-sitter CLI (Arch: tree-sitter-cli).
set -euo pipefail

SITE="${NVIM_SITE_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site}"
PARSER_DIR="$SITE/parser"
QUERY_DIR="$SITE/queries"
SYSTEM_PARSER_DIR="${TREE_SITTER_LIB_DIR:-/usr/lib/tree_sitter}"
QUERY_SOURCE="${NVIM_TREESITTER_QUERIES:-https://raw.githubusercontent.com/nvim-treesitter/nvim-treesitter/main/runtime/queries}"

# Parsers init.lua enables, plus the parsers it injects (markdown_inline). Arch
# ships these as <lang>.so in $SYSTEM_PARSER_DIR.
PARSERS=(bash c diff go html lua luadoc markdown markdown_inline query vim vimdoc)

# Grammar sources, used when Arch does not ship a parser. Append "#<subdir>"
# when one repository holds several grammars.
declare -A GRAMMAR=(
	[bash]=https://github.com/tree-sitter/tree-sitter-bash
	[c]=https://github.com/tree-sitter/tree-sitter-c
	[diff]=https://github.com/tree-sitter-grammars/tree-sitter-diff
	[go]=https://github.com/tree-sitter/tree-sitter-go
	[html]=https://github.com/tree-sitter/tree-sitter-html
	[lua]=https://github.com/tree-sitter-grammars/tree-sitter-lua
	[luadoc]=https://github.com/tree-sitter-grammars/tree-sitter-luadoc
	[markdown]=https://github.com/tree-sitter-grammars/tree-sitter-markdown#tree-sitter-markdown
	[markdown_inline]=https://github.com/tree-sitter-grammars/tree-sitter-markdown#tree-sitter-markdown-inline
	[query]=https://github.com/tree-sitter-grammars/tree-sitter-query
	[vim]=https://github.com/tree-sitter-grammars/tree-sitter-vim
	[vimdoc]=https://github.com/neovim/tree-sitter-vimdoc
)

# Query files Neovim's runtime does not ship. Missing files are skipped, so the
# list can stay broad without failing on languages that ship fewer of them.
# html_tags is not a parser: html's queries inherit it by name.
QUERY_LANGS=(bash diff go html html_tags luadoc)
QUERY_FILES=(highlights folds indents injections locals)

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

die() {
	echo "error: $*" >&2
	exit 1
}

for tool in git curl tree-sitter; do
	command -v "$tool" >/dev/null 2>&1 || die "missing required tool: $tool"
done

# A dangling symlink is not "installed": remove it so it is replaced.
clear_dangling() {
	local path="$1"
	if [[ -L "$path" && ! -e "$path" ]]; then
		rm -f "$path"
	fi
}

install_parser() {
	local lang="$1"
	local dest="$PARSER_DIR/$lang.so"
	clear_dangling "$dest"
	if [[ -e "$dest" ]]; then
		echo "parser  $lang: already installed"
		return
	fi
	if [[ -e "$SYSTEM_PARSER_DIR/$lang.so" ]]; then
		ln -s "$SYSTEM_PARSER_DIR/$lang.so" "$dest"
		echo "parser  $lang: linked from $SYSTEM_PARSER_DIR"
		return
	fi
	local spec="${GRAMMAR[$lang]:-}"
	if [[ -z "$spec" ]]; then
		echo "parser  $lang: not packaged and no source URL; skipped" >&2
		return
	fi
	local repo="${spec%%#*}"
	local subdir=""
	[[ "$spec" == *"#"* ]] && subdir="${spec#*#}"
	git clone --depth 1 --quiet "$repo" "$TMP/grammar-$lang"
	local src="$TMP/grammar-$lang"
	[[ -n "$subdir" ]] && src="$src/$subdir"
	tree-sitter build -o "$dest" "$src" >/dev/null
	echo "parser  $lang: built from $repo"
}

install_queries() {
	local lang="$1"
	local dir="$QUERY_DIR/$lang"
	local found=0
	clear_dangling "$dir"
	if [[ -e "$dir" ]]; then
		echo "queries $lang: already installed"
		return
	fi
	mkdir -p "$dir"
	for file in "${QUERY_FILES[@]}"; do
		if curl -fsSL "$QUERY_SOURCE/$lang/$file.scm" -o "$dir/$file.scm" 2>/dev/null; then
			found=1
		else
			rm -f "$dir/$file.scm"
		fi
	done
	if [[ "$found" = 0 ]]; then
		rmdir "$dir"
		echo "queries $lang: none published upstream; skipped" >&2
		return
	fi
	echo "queries $lang: vendored from nvim-treesitter"
}

is_parser_lang() {
	local candidate="$1" lang
	for lang in "${PARSERS[@]}"; do
		[[ "$lang" = "$candidate" ]] && return 0
	done
	return 1
}

if (( $# > 0 )); then
	parser_langs=()
	for lang in "$@"; do
		is_parser_lang "$lang" && parser_langs+=("$lang")
	done
	query_langs=("$@")
else
	parser_langs=("${PARSERS[@]}")
	query_langs=("${QUERY_LANGS[@]}")
fi

mkdir -p "$PARSER_DIR" "$QUERY_DIR"

for lang in "${parser_langs[@]}"; do
	install_parser "$lang"
done

for lang in "${query_langs[@]}"; do
	install_queries "$lang"
done
