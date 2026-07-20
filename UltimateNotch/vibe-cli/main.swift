import Foundation
import Network

// Minimal implementation to spawn a process and send output to socket
let args = Array(CommandLine.arguments.dropFirst())
guard !args.isEmpty else {
    print("Usage: vibe-cli <command>")
    exit(1)
}

let command = args.joined(separator: " ")
let sessionId = UUID().uuidString

// Detect IDE from environment
let env = ProcessInfo.processInfo.environment
var ide = "Terminal"
if env["TERM_PROGRAM"] == "iTerm.app" { ide = "iTerm" }
else if env["TERM_PROGRAM"] == "vscode" { ide = "Visual Studio Code" }
else if env["TERM_PROGRAM"] == "Ghostty" { ide = "Ghostty" }
else if env["TERM_PROGRAM"] == "WarpTerminal" { ide = "Warp" }
else if env["__CFBundleIdentifier"] == "com.apple.Terminal" { ide = "Terminal" }
else if env["TERM_PROGRAM"] == "Trae" { ide = "Trae" }
else if env["TERM_PROGRAM"] == "Cursor" { ide = "Cursor" }
else if env["TERM_PROGRAM"] == "Codex" { ide = "Codex" }
else if env["TERM_PROGRAM"] == "Antigravity" { ide = "Antigravity IDE" }
else if env["TERM_PROGRAM"] == "OpenCode" { ide = "OpenCode" }
else if env["TERM_PROGRAM"] == "Freebuff" { ide = "Freebuff" }
else if env["TERM_PROGRAM"] == "Xcode" || env["__CFBundleIdentifier"] == "com.apple.dt.Xcode" { ide = "Xcode" }
else if env["TERM_PROGRAM"] == "VisualStudio" { ide = "Visual Studio" }

let homeDir = FileManager.default.homeDirectoryForCurrentUser
let pathFile = homeDir.appendingPathComponent("Library/Containers/theboringteam.boringnotch/Data/Library/Application Support/boringNotch/socket_path.txt")

guard let socketPath = try? String(contentsOf: pathFile, encoding: .utf8) else {
    print("Error: Could not find Vibe Island socket path. Make sure UltimateNotch is running.")
    exit(1)
}

let connection = NWConnection(to: .unix(path: socketPath), using: .tcp)
connection.start(queue: .global())

func sendMessage(_ type: String, payload: String? = nil) {
    let msg: [String: String] = [
        "type": type,
        "sessionId": sessionId,
        "command": command,
        "ide": ide,
        "payload": payload ?? ""
    ]
    if let data = try? JSONEncoder().encode(msg) {
        connection.send(content: data, completion: .contentProcessed({ _ in }))
    }
}

sendMessage("start")

let task = Process()
task.executableURL = URL(fileURLWithPath: "/bin/sh")
task.arguments = ["-c", command]

let pipe = Pipe()
task.standardOutput = pipe
task.standardError = pipe

let outHandle = pipe.fileHandleForReading
outHandle.readabilityHandler = { handle in
    let data = handle.availableData
    if data.count > 0 {
        FileHandle.standardOutput.write(data) // Pass through to real terminal
        if let text = String(data: data, encoding: .utf8) {
            sendMessage("output", payload: text)
        }
    }
}

try? task.run()
task.waitUntilExit()

sendMessage("exit")
Thread.sleep(forTimeInterval: 0.1) // allow flush
