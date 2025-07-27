#!/bin/bash

# Change to notes directory
NOTES_DIR="${NOTES_DIR:-$(pwd)}"
cd "$NOTES_DIR" || exit 1

# Create temp file with all notes sorted by modification date
TEMP_FILE=$(mktemp)
ls -t > "$TEMP_FILE"
trap "rm -f $TEMP_FILE" EXIT

# Key bindings
BINDINGS="ctrl-x:execute(vim {})"
BINDINGS+=",enter:execute(sterm={cq} && vim -c \"silent! /\$sterm\\c\" {})+abort"
BINDINGS+=",ctrl-p:toggle-preview"
BINDINGS+=",tab:up,shift-tab:down"

# Launch skim with configuration
sk --ansi -i \
   -c "if [ -z '{}' ]; then cat $TEMP_FILE; else { grep -i '{}' $TEMP_FILE; rg -l --no-heading -i '{}' . 2>/dev/null | sed 's|^\./||'; echo {}.md; } | awk '!seen[\$0]++'; fi" \
   --bind "$BINDINGS" \
   --preview "SEARCH_TERM={cq} preview.sh {}" \
   --preview-window 'down:50%:wrap'

