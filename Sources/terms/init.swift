import AppKit
import Foundation
import Darwin

typealias TerminalLaunchFunction = (_ command: String) throws -> Void

enum TerminalRegistry {
    static let launchers: [String: TerminalLaunchFunction] = [
        AppleTerminal.BUNDLE_ID: AppleTerminal.launch,
        ITerm2.BUNDLE_ID: ITerm2.launch,
        Alacritty.BUNDLE_ID: Alacritty.launch,
        WezTerm.BUNDLE_ID: WezTerm.launch,
        Kitty.BUNDLE_ID: Kitty.launch,
        Ghostty.BUNDLE_ID: Ghostty.launch,
    ]
}

enum TerminalSupport {
    static func applicationURL(bundleID: String) -> URL? {
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
    }

    static func loginShell() -> String {
        if let passwd = getpwuid(getuid()),
           let shellPointer = passwd.pointee.pw_shell {
            let shell = String(cString: shellPointer)
            if !shell.isEmpty {
                return shell
            }
        }

        return "/bin/zsh"
    }

    static func shellQuote(_ value: String) -> String {
        "'" + value.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }

    static func keepShellOpenCommand(_ command: String) -> String {
        let shell = loginShell()

        // Important:
        //
        //   shell -c 'nvim file'
        //
        // exits the shell when nvim exits, so terminals that treat that shell
        // as the window's root process will close the window.
        //
        // Instead:
        //
        //   shell -c 'nvim file; exec shell -l'
        //
        // replaces the finished command shell with a fresh login shell.
        //
        // Result:
        //   :qa -> back to a normal terminal prompt.
        return "\(command); exec \(shellQuote(shell)) -l"
    }

    static func shellArgumentsKeepingWindowOpen(command: String) -> [String] {
        [
            "-l",
            "-i",
            "-c",
            keepShellOpenCommand(command),
        ]
    }

    static func bundledExecutable(
        bundleID: String,
        named executableName: String
    ) throws -> String {
        guard let appURL = applicationURL(bundleID: bundleID) else {
            throw LaunchError.applicationNotFound(bundleID)
        }

        let executable = appURL
            .appendingPathComponent("Contents")
            .appendingPathComponent("MacOS")
            .appendingPathComponent(executableName)

        guard FileManager.default.isExecutableFile(atPath: executable.path) else {
            throw LaunchError.executableNotFound(executable.path)
        }

        return executable.path
    }

    static func runDetached(
        _ executable: String,
        arguments: [String]
    ) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments
        process.standardInput = FileHandle.nullDevice
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        try process.run()
    }

    @discardableResult
    static func runAndWaitStatus(
        _ executable: String,
        arguments: [String]
    ) throws -> (status: Int32, stderr: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        let stderrPipe = Pipe()
        process.standardError = stderrPipe
        process.standardOutput = FileHandle.nullDevice

        try process.run()
        process.waitUntilExit()

        let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
        let message = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return (process.terminationStatus, message)
    }

    static func runAndWait(
        _ executable: String,
        arguments: [String]
    ) throws {
        let result = try runAndWaitStatus(executable, arguments: arguments)

        guard result.status == 0 else {
            throw LaunchError.processFailed(
                executable: executable,
                status: result.status,
                message: result.stderr.isEmpty ? nil : result.stderr
            )
        }
    }

    static func launchApp(
        bundleID: String,
        arguments: [String] = []
    ) throws {
        guard let appURL = applicationURL(bundleID: bundleID) else {
            throw LaunchError.applicationNotFound(bundleID)
        }

        var openArgs = ["-a", appURL.path]

        if !arguments.isEmpty {
            openArgs.append("--args")
            openArgs.append(contentsOf: arguments)
        }

        try runAndWait("/usr/bin/open", arguments: openArgs)
    }
}

enum LaunchError: LocalizedError {
    case applicationNotFound(String)
    case executableNotFound(String)
    case processFailed(executable: String, status: Int32, message: String?)

    var errorDescription: String? {
        switch self {
        case .applicationNotFound(let bundleID):
            return "No installed macOS application was found for bundle ID \(bundleID)."

        case .executableNotFound(let path):
            return "Expected terminal executable was not found at \(path)."

        case .processFailed(let executable, let status, let message):
            if let message, !message.isEmpty {
                return "\(executable) exited with status \(status): \(message)"
            }
            return "\(executable) exited with status \(status)."
        }
    }
}
