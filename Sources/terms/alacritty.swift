import Foundation

enum Alacritty {
    static let BUNDLE_ID = "org.alacritty"

    static func launch(_ command: String) throws {
        let shell = TerminalSupport.loginShell()
        let alacritty = try TerminalSupport.bundledExecutable(
            bundleID: BUNDLE_ID,
            named: "alacritty"
        )

        let shellArgs = TerminalSupport.shellArgumentsKeepingWindowOpen(
            command: command
        )

        // Preferred path:
        // `alacritty msg create-window` explicitly creates a new window in
        // the same already-running Alacritty process.
        let existingResult = try TerminalSupport.runAndWaitStatus(
            alacritty,
            arguments: [
                "msg",
                "create-window",
                "-e",
                shell,
            ] + shellArgs
        )

        if existingResult.status == 0 {
            return
        }

        // No running IPC target. Launch the app for the first time.
        try TerminalSupport.launchApp(
            bundleID: BUNDLE_ID,
            arguments: [
                "-e",
                shell,
            ] + shellArgs
        )
    }
}
