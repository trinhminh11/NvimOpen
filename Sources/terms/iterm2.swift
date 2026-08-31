import Foundation

enum ITerm2 {
    static let BUNDLE_ID = "com.googlecode.iterm2"

    static func launch(_ command: String) throws {
        let script = """
        on run argv
            set cmd to item 1 of argv

            tell application id "com.googlecode.iterm2"
                activate

                -- This is a new OS window in the existing iTerm2 app.
                -- The default profile starts its normal shell.
                set newWindow to (create window with default profile)

                tell current session of newWindow
                    write text cmd
                end tell
            end tell
        end run
        """

        try TerminalSupport.runAndWait(
            "/usr/bin/osascript",
            arguments: ["-e", script, command]
        )
    }
}
