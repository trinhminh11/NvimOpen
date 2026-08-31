import AppKit
import Foundation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var openedSomething = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // If NvimOpen.app is launched directly, quit instead of hanging around.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self, !self.openedSomething else { return }
            NSApp.terminate(nil)
        }
    }

    func application(_ sender: NSApplication, openFiles filenames: [String]) {
        openedSomething = true

        guard !filenames.isEmpty else {
            finish(sender, result: .failure)
            return
        }

        let bundleID = readTerminalBundleID()
        let command = makeNvimCommand(files: filenames)

        do {
            if let launch = TerminalRegistry.launchers[bundleID] {
                if TerminalSupport.applicationURL(bundleID: bundleID) == nil {
                    guard askToUseDefaultTerminal(
                        configuredBundleID: bundleID,
                        command: command,
                        reason: "The terminal is registered in NvimOpen, but macOS cannot find an installed application with that bundle ID."
                    ) else {
                        finish(sender, result: .failure)
                        return
                    }

                    try AppleTerminal.launch(command)
                } else {
                    try launch(command)
                }
            } else {
                guard askToUseDefaultTerminal(
                    configuredBundleID: bundleID,
                    command: command,
                    reason: "NvimOpen does not have a launcher registered for this terminal."
                ) else {
                    finish(sender, result: .failure)
                    return
                }

                try AppleTerminal.launch(command)
            }

            finish(sender, result: .success)
        } catch {
            sender.reply(toOpenOrPrint: .failure)
            showError(
                title: "Could not open Neovim",
                details: error.localizedDescription
            )
            sender.terminate(nil)
        }
    }

    // MARK: - Configuration

    private func readTerminalBundleID() -> String {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".terminal.default")

        guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
            return AppleTerminal.BUNDLE_ID
        }

        // First non-empty, non-comment line wins.
        for rawLine in contents.split(whereSeparator: { $0.isNewline }) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty && !line.hasPrefix("#") {
                return line
            }
        }

        return AppleTerminal.BUNDLE_ID
    }

    // MARK: - Neovim command

    private func makeNvimCommand(files: [String]) -> String {
        let quotedFiles = files.map(shellQuote).joined(separator: " ")
        return "nvim \(quotedFiles)"
    }

    private func shellQuote(_ value: String) -> String {
        // POSIX-safe single-quote escaping.
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    // MARK: - Unknown / unavailable terminal fallback

    private func askToUseDefaultTerminal(
        configuredBundleID: String,
        command: String,
        reason: String
    ) -> Bool {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Terminal launcher unavailable"
        alert.informativeText = """
        \(reason)

        Configured bundle ID:
        \(configuredBundleID)

        macOS can launch an application by bundle ID, but terminal emulators do not share a universal API for "run this command".

        NvimOpen can use Terminal.app for this open instead:

        \(command)

        Use Terminal.app?
        """

        alert.addButton(withTitle: "Use Terminal.app")
        alert.addButton(withTitle: "Cancel")

        return alert.runModal() == .alertFirstButtonReturn
    }

    // MARK: - UI / lifecycle helpers

    private func showError(title: String, details: String) {
        NSApp.activate(ignoringOtherApps: true)

        let alert = NSAlert()
        alert.alertStyle = .critical
        alert.messageText = title
        alert.informativeText = details
        alert.runModal()
    }

    private func finish(
        _ sender: NSApplication,
        result: NSApplication.DelegateReply
    ) {
        sender.reply(toOpenOrPrint: result)
        sender.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()

app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
