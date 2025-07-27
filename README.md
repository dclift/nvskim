# NVskim

There have been quite a few approaches to carry on Zachary Schneirov's wonderful work on [Notational Velocity](https://github.com/scrod/nv).

This is an approach that I created in response to https://github.com/alok/notational-fzf-vim/issues/22 using the author of that project's suggestion to leverage skim's interactive mode. 

I've used it since then and found it invaluable, and recently I made some adjustments and wanted to publish it here in case anyone would like to use it in their own workflow. 

## Setup

### Prerequisites
- [skim](https://github.com/lotabout/skim) 
- [ripgrep](https://github.com/BurntSushi/ripgrep) 
- vim 

### Installation
1. Clone or download the repository
2. Make the script executable: `chmod +x nvskim.sh`
3. Optionally, add to your PATH or create an alias for easy access

### Configuration
- **Notes directory**: Set the `NOTES_DIR` environment variable, or it defaults to the current working directory
- **Editor**: The script uses vim by default. To use a different editor, modify the `execute(vim {})` bindings in the script
- **Preview**: Requires `preview.sh` to be in the same directory as `nvskim.sh` 

## Key Bindings

- **ctrl-x**: Opens the selected file in vim
- **enter**: Opens the selected file in vim and searches for the current query term (case-insensitive), then exits skim
- **ctrl-p**: Toggles the preview pane on/off
- **tab**: Moves selection up in the list
- **shift-tab**: Moves selection down in the list

## Functionality

1. **File indexing**: Creates a temporary file containing all files in the notes directory sorted by modification date (`ls -t`). This pre-sorted list is reused throughout the session for performance.

2. **Interactive search interface**: Launches skim (fuzzy finder) with:
   - Case-insensitive search (`-i`)
   - ANSI color support (`--ansi`) 
   - Custom command mode search logic (`-c`)
   - Preview pane showing file contents with search term highlighting

3. **Search behavior**:
   - **Empty query**: Shows all files from the pre-sorted list (most recently modified first)
   - **With search term**: 
     - Searches filenames using `grep -i` on the pre-sorted file list
     - Searches file contents using `ripgrep -l` (lists files containing the term)
     - Combines and deduplicates results while preserving the modification date order

4. **Preview functionality**: 
   - Shows file contents in a preview pane (50% of screen height)
   - Highlights search terms in the preview using `preview.sh`
   - Supports toggling preview on/off with ctrl-p

5. **File operations**:
   - **ctrl-x**: Opens selected file directly in vim
   - **enter**: Opens file in vim and automatically searches for the current query term

