#!/usr/bin/env bash

REVERSE="\x1b[7m"
RESET="\x1b[m"

if [ -z "$1" ]; then
  echo "usage: $0 FILENAME[:LINENO][:IGNORED]"
  exit 1
fi

IFS=':' read -r -a INPUT <<< "$1"
FILE=${INPUT[0]}
CENTER=${INPUT[1]}

if [[ $1 =~ ^[A-Z]:\\ ]]; then
  FILE=$FILE:${INPUT[1]}
  CENTER=${INPUT[2]}
fi

if [[ -n "$CENTER" && ! "$CENTER" =~ ^[0-9] ]]; then
  exit 1
fi
CENTER=${CENTER/[^0-9]*/}

FILE="${FILE/#\~\//$HOME/}"
if [ ! -r "$FILE" ]; then
  echo "File not found ${FILE}"
  exit 1
fi

MIME=$(file --dereference --mime "$FILE")
if [[ "$MIME" =~ binary ]]; then
  echo "$MIME"
  exit 0
fi

if [ -z "$CENTER" ]; then
  CENTER=0
fi

if [ -n "$FZF_PREVIEW_LINES" ]; then
  LINES=$FZF_PREVIEW_LINES
else
  if [ -r /dev/tty ]; then
    LINES=$(stty size < /dev/tty | awk '{print $1}')
  else
    LINES=40
  fi
fi

FIRST=$(($CENTER-$LINES/3))
FIRST=$(($FIRST < 1 ? 1 : $FIRST))
LAST=$((${FIRST}+${LINES}-1))

if [ -z "$FZF_PREVIEW_COMMAND" ] && command -v bat > /dev/null; then
  if [ -n "$SEARCH_TERM" ]; then
    bat --style="${BAT_STYLE:-plain}" --color=always --pager=never \
        --line-range=$FIRST:$LAST --highlight-line=$CENTER "$FILE" | \
        grep --color=always -i "$SEARCH_TERM\|$"
  else
    bat --style="${BAT_STYLE:-plain}" --color=always --pager=never \
        --line-range=$FIRST:$LAST --highlight-line=$CENTER "$FILE"
  fi
  exit $?
fi

DEFAULT_COMMAND="highlight -O ansi -l {} || coderay {} || rougify {} || cat {}"
CMD=${FZF_PREVIEW_COMMAND:-$DEFAULT_COMMAND}
CMD=${CMD//{\}/$(printf %q "$FILE")}

if [ -n "$SEARCH_TERM" ] && [ "$SEARCH_TERM" != "" ] && command -v grep > /dev/null; then
  eval "$CMD" 2> /dev/null | grep --color=always -i "$SEARCH_TERM\|$" | awk "NR >= $FIRST && NR <= $LAST { \
      if (NR == $CENTER) \
          { gsub(/\x1b[[0-9;]*m/, \"&$REVERSE\"); printf(\"$REVERSE%s\n$RESET\", \$0); } \
      else printf(\"$RESET%s\n\", \$0); \
      }"
else
  eval "$CMD" 2> /dev/null | awk "NR >= $FIRST && NR <= $LAST { \
      if (NR == $CENTER) \
          { gsub(/\x1b[[0-9;]*m/, \"&$REVERSE\"); printf(\"$REVERSE%s\n$RESET\", \$0); } \
      else printf(\"$RESET%s\n\", \$0); \
      }"
fi
