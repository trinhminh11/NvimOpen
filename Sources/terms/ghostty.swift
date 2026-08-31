import Foundation

enum Ghostty {
    static let BUNDLE_ID = "com.mitchellh.ghostty"

    static func launch(_ command: String) throws {
        let script = """
        on run argv
            set cmd to item 1 of argv

            tell application id "com.mitchellh.ghostty"
                activate

                -- Ghostty 1.3+ has a native AppleScript API.
                -- Create a new window using the normal Ghostty configuration,
                -- then type the nvim command into that window's shell.
                set cfg to new surface configuration
                set win to new window with configuration cfg
                set term to focused terminal of selected tab of win

                input text cmd to term
                send key "enter" to term
                focus term
            end tell
        end run
        """

        try TerminalSupport.runAndWait(
            "/usr/bin/osascript",
            arguments: ["-e", script, command]
        )
    }
}
