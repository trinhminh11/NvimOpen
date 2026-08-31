NvimOpen opens files from Finder directly in Neovim using your preferred terminal.

## Requirements

- An Apple Silicon Mac
- macOS 11 or later
- Neovim available as `nvim`

## Installation

1. Download the ZIP ending in `-macos-arm64.zip` from the assets below.
2. Extract the ZIP and move `NvimOpen.app` to `/Applications`.
3. Open the app once. NvimOpen has no app window and exits when launched without a file.
4. In Finder, select a file and choose **File → Get Info**.
5. Under **Open with**, select `NvimOpen.app`. Optionally choose **Change All**.

The app is ad-hoc signed but not Apple-notarized. If macOS blocks the first launch, Control-click `NvimOpen.app`, choose **Open**, then confirm.

## Configure your terminal

Create `~/.terminal.default` and put your terminal's macOS bundle ID on the first non-empty line. For example, to use Ghostty:

```text
com.mitchellh.ghostty
```

See the [configuration guide](https://github.com/trinhminh11/NvimOpen#configure-your-terminal) for all supported terminals.

## Verify the download

Download the accompanying `.sha256` file into the same directory as the ZIP, then run:

```sh
shasum -a 256 -c NvimOpen-*.zip.sha256
```
