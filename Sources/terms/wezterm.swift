import Foundation

enum WezTerm {
    static let BUNDLE_ID = "com.github.wez.wezterm"

    static func launch(_ command: String) throws {
        let shell = TerminalSupport.loginShell()
        let wezterm = try TerminalSupport.bundledExecutable(
            bundleID: BUNDLE_ID,
            named: "wezterm"
        )

        let shellArgs = TerminalSupport.shellArgumentsKeepingWindowOpen(
            command: command
        )

        // Prefer a new OS window in the already-running WezTerm GUI.
        //
        // `wezterm cli` searches for a running GUI instance.
        let existingResult = try TerminalSupport.runAndWaitStatus(
            wezterm,
            arguments: [
                "cli",
                "spawn",
                "--new-window",
                "--",
                shell,
            ] + shellArgs
        )

        if existingResult.status == 0 {
            return
        }

        // No running GUI/mux was found. Start WezTerm normally.
        //
        // The wrapper shell executes nvim and then execs a fresh login shell,
        // so quitting nvim does not close the newly-created terminal window.
        try TerminalSupport.runDetached(
            wezterm,
            arguments: [
                "start",
                "--",
                shell,
            ] + shellArgs
        )
    }
}
