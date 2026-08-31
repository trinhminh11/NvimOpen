import Foundation

enum AppleTerminal {
    static let BUNDLE_ID = "com.apple.Terminal"

    static func launch(_ command: String) throws {
        let script = """
        on run argv
            set cmd to item 1 of argv

            tell application id "com.apple.Terminal"
                activate

                -- With no target window, `do script` creates a new Terminal
                -- window in the existing Terminal.app process.
                --
                -- The window owns a normal shell; nvim is merely a command
                -- inside that shell, so :qa returns to the prompt.
                do script cmd
            end tell
        end run
        """

        try TerminalSupport.runAndWait(
            "/usr/bin/osascript",
            arguments: ["-e", script, command]
        )
    }
}
