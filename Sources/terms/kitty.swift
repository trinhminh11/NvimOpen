import Foundation

enum Kitty {
    static let BUNDLE_ID = "net.kovidgoyal.kitty"

    static func launch(_ command: String) throws {
        let shell = TerminalSupport.loginShell()
        let kitty = try TerminalSupport.bundledExecutable(
            bundleID: BUNDLE_ID,
            named: "kitty"
        )

        let shellArgs = TerminalSupport.shellArgumentsKeepingWindowOpen(
            command: command
        )

        // kitty's --single-instance mode makes later invocations create a new
        // top-level OS window in the first kitty process in the instance group.
        //
        // This is intentionally NOT `open -n`, which forces macOS to make a
        // separate application instance.
        try TerminalSupport.runDetached(
            kitty,
            arguments: [
                "--single-instance",
                shell,
            ] + shellArgs
        )
    }
}
