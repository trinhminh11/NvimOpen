
# NvimOpen

A small macOS **Open With** bridge for opening files from Finder directly in [Neovim](https://neovim.io/) using your preferred terminal emulator.

Instead of opening a file in a GUI editor, NvimOpen turns a Finder open event into:

```sh
nvim '/path/to/file'
```

and launches it in your configured terminal.

> [!IMPORTANT]
> NvimOpen currently supports **Apple Silicon Macs only** (`arm64`).

## Supported terminals

| Terminal     | Bundle ID                |
| ------------ | ------------------------ |
| Terminal.app | `com.apple.Terminal`     |
| iTerm2       | `com.googlecode.iterm2`  |
| Alacritty    | `org.alacritty`          |
| WezTerm      | `com.github.wez.wezterm` |
| kitty        | `net.kovidgoyal.kitty`   |
| Ghostty      | `com.mitchellh.ghostty`  |

## Installation

### Download

Download the latest release from the **Releases** page:

```text
NvimOpen-v0.1.0-macos-arm64.zip
```

Then:

1. Extract the ZIP.
2. Move `NvimOpen.app` to `/Applications`.
3. Try to open `NvimOpen.app` once.

## Finder setup

After installing NvimOpen:

1. Select a file in Finder.
2. Press **Command + I** or choose **Get Info**.
3. Expand **Open with**.
4. Select `NvimOpen.app`.
5. Optionally click **Change All...** to use NvimOpen for every file of that type.

NvimOpen declares broad `public.data` support so Finder can offer it as an **Open With** target.

It does not automatically take ownership of any file types.

## Configure your terminal

NvimOpen reads your preferred terminal from:

```text
~/.terminal.default
```

Create the file and put the terminal's macOS bundle ID inside it.

For example, for Ghostty:

```text
com.mitchellh.ghostty
```

For WezTerm:

```text
com.github.wez.wezterm
```

For iTerm2:

```text
com.googlecode.iterm2
```

Comments and blank lines are allowed:

```text
# My preferred terminal
com.mitchellh.ghostty
```

The first non-empty, non-comment line is used.

If `~/.terminal.default` does not exist or doesn't contain a bundle ID, NvimOpen defaults to:

```text
Terminal.app
```


## Build from source

### Requirements

* Apple Silicon Mac
* macOS
* Neovim available as `nvim`
* Xcode Command Line Tools or Xcode

Install the Xcode Command Line Tools if necessary:

```sh
xcode-select --install
```

Clone the repository:

```sh
git clone https://github.com/YOUR_USERNAME/NvimOpen.git
cd NvimOpen
```

Build:

```sh
./build.sh
```

The app will be created at:

```text
dist/NvimOpen.app
```

Install it:

```sh
cp -R dist/NvimOpen.app /Applications/
```

The local build is ad-hoc signed using macOS `codesign`. A paid Apple Developer account is not required to build NvimOpen from source.

## Project structure

```text
NvimOpen/
├── Info.plist
├── build.sh
└── Sources/
    ├── main.swift
    └── terms/
        ├── init.swift
        ├── terminal.swift
        ├── iterm2.swift
        ├── alacritty.swift
        ├── wezterm.swift
        ├── kitty.swift
        └── ghostty.swift
```

Each terminal integration lives in its own adapter under:

```text
Sources/terms/
```

## License

MIT — see [`LICENSE`](LICENSE).
