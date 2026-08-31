# NvimOpen

A tiny macOS `Open With` bridge that turns a Finder file-open event into:

```sh
nvim '/path/to/file'
```

using your preferred terminal emulator.

## Layout

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

Each terminal adapter follows the same contract:

```swift
enum SomeTerminal {
    static let BUNDLE_ID = "..."

    static func launch(_ command: String) throws {
        // terminal-specific implementation
    }
}
```

`terms/init.swift` contains the registry:

```swift
static let launchers: [String: TerminalLaunchFunction] = [
    AppleTerminal.BUNDLE_ID: AppleTerminal.launch,
    ITerm2.BUNDLE_ID: ITerm2.launch,
    // ...
]
```

## Supported macOS terminals

| Terminal | Bundle ID |
| --- | --- |
| Terminal.app | `com.apple.Terminal` |
| iTerm2 | `com.googlecode.iterm2` |
| Alacritty | `org.alacritty` |
| WezTerm | `com.github.wez.wezterm` |
| kitty | `net.kovidgoyal.kitty` |
| Ghostty | `com.mitchellh.ghostty` |


## Configure the default terminal

Create:

```text
~/.terminal.default
```

with one bundle ID:

```text
com.mitchellh.ghostty
```

or:

```text
com.github.wez.wezterm
```

Comments and blank lines are allowed. The first non-empty, non-comment line is
used.

If the file does not exist or contains no bundle ID, NvimOpen silently defaults
to Terminal.app.

## Unknown terminal behavior

If `~/.terminal.default` contains a bundle ID that NvimOpen does not know, the
app displays a detailed alert explaining that macOS has no universal terminal
"execute command" API.

The alert offers:

- **Use Terminal.app** — run the current `nvim ...` command in Terminal.app.
- **Cancel** — do nothing and quit NvimOpen.

The same fallback is shown if the bundle ID is registered but the terminal is
not installed.

## Build

Requires Xcode Command Line Tools or Xcode:

```sh
./build.sh
```

Output:

```text
dist/NvimOpen.app
```

Install:

```sh
cp -R dist/NvimOpen.app /Applications/
```

## Finder setup

For each type you care about:

1. Select a code / JSON / YAML file in Finder.
2. Choose **Get Info**.
3. Under **Open with**, select `NvimOpen.app`.
4. Click **Change All...** if desired.

The app declares broad `public.data` support so Finder can offer it as an
`Open With` target. It does not automatically take ownership of file types.


