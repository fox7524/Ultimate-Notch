# Vibe Island Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the Vibe Island functionality into UltimateNotch, providing a real-time monitor and interactive overlay for CLI agents (Claude Code, Gemini, KiloCode) running across 12+ terminals/IDEs, using a local Unix Domain Socket and a bundled wrapper CLI.

**Architecture:** 
1. **vibe-cli**: A Swift binary bundled in the app. Users alias agents to it (`alias claude="vibe-cli claude"`). It creates a pseudo-terminal (PTY) to run the target agent, intercepts stdin/stdout, and communicates with the Notch app via Unix Domain Sockets.
2. **Socket Server**: UltimateNotch runs a background server (`VibeSocketServer`) tracking active `VibeSession`s.
3. **Data Parsing**: `VibeParser` uses Regex to detect specific prompt formats (e.g., diffs, "Allow/Deny" prompts) from the raw terminal streams.
4. **SwiftUI Overlay**: `VibeIslandView` displays active sessions (Monitor) and interactive prompts (Approve/Ask) using a custom bottom tab bar, and uses AppleScript to Jump to the active terminal.

**Tech Stack:** Swift, AppKit, SwiftUI, Unix Domain Sockets (Network framework), Process/PTY, NSAppleScript.

---

### Task 1: Core Models & Socket Server

**Files:**
- Create: `UltimateNotch/boringNotch/components/Tabs/VibeIsland/VibeModels.swift`
- Create: `UltimateNotch/boringNotch/components/Tabs/VibeIsland/VibeSocketServer.swift`

- [ ] **Step 1: Define the core models**
Write `VibeModels.swift` to define `VibeSession`, `VibeMessage`, and prompt types.

```swift
import Foundation

struct VibeMessage: Codable {
    let type: String // "start", "output", "exit", "approve", "deny"
    let sessionId: String
    let command: String?
    let ide: String?
    let payload: String?
}

enum VibePromptType {
    case none
    case allowDeny(diff: String?)
    case ask(options: [String])
}

class VibeSession: Identifiable, ObservableObject {
    let id: String
    let command: String
    let ide: String
    let startTime: Date
    
    @Published var output: String = ""
    @Published var promptType: VibePromptType = .none
    @Published var isActive: Bool = true
    
    init(id: String, command: String, ide: String) {
        self.id = id
        self.command = command
        self.ide = ide
        self.startTime = Date()
    }
}
```

- [ ] **Step 2: Create the Socket Server Manager**
Write `VibeSocketServer.swift` using `Network` framework to listen on `/tmp/vibe_island.sock`.

```swift
import Foundation
import Network
import Combine

@MainActor
class VibeManager: ObservableObject {
    @Published var sessions: [VibeSession] = []
    
    private var listener: NWListener?
    private var connections: [NWConnection] = []
    
    init() {
        startListening()
    }
    
    func startListening() {
        let socketPath = "/tmp/vibe_island.sock"
        unlink(socketPath)
        
        do {
            let parameters = NWParameters(tls: nil, tcp: nil)
            parameters.requiredLocalEndpoint = NWEndpoint.unix(path: socketPath)
            parameters.allowLocalEndpointReuse = true
            
            listener = try NWListener(parameters: parameters)
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: .main)
        } catch {
            print("Failed to start socket listener: \(error)")
        }
    }
    
    private func handleConnection(_ connection: NWConnection) {
        connections.append(connection)
        connection.start(queue: .main)
        receiveMessage(on: connection)
    }
    
    private func receiveMessage(on connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
            guard let self = self else { return }
            
            if let data = data, let message = try? JSONDecoder().decode(VibeMessage.self, from: data) {
                self.processMessage(message)
            }
            
            if !isComplete && error == nil {
                self.receiveMessage(on: connection)
            }
        }
    }
    
    private func processMessage(_ msg: VibeMessage) {
        if msg.type == "start" {
            let session = VibeSession(id: msg.sessionId, command: msg.command ?? "unknown", ide: msg.ide ?? "Terminal")
            sessions.append(session)
        } else if msg.type == "output" {
            if let session = sessions.first(where: { $0.id == msg.sessionId }) {
                session.output += msg.payload ?? ""
                // We will add parsing logic here later
            }
        } else if msg.type == "exit" {
            if let session = sessions.first(where: { $0.id == msg.sessionId }) {
                session.isActive = false
            }
        }
    }
}
```

### Task 2: Build the UI (Vibe Island Tab)

**Files:**
- Modify: `UltimateNotch/boringNotch/components/Tabs/VibeIslandPlaceholderView.swift` (Rename to `VibeIslandView.swift`)

- [ ] **Step 1: Replace placeholder with actual UI**
Rewrite `VibeIslandView.swift` to include the bottom tab bar and monitor list.

```swift
import SwiftUI

enum VibeTab {
    case monitor, approve, ask, jump
}

struct VibeIslandView: View {
    @StateObject private var vibeManager = VibeManager()
    @State private var selectedTab: VibeTab = .monitor
    
    var body: some View {
        VStack(spacing: 0) {
            // Content Area
            ScrollView {
                if selectedTab == .monitor {
                    VStack(spacing: 12) {
                        ForEach(vibeManager.sessions) { session in
                            SessionCardView(session: session)
                        }
                    }
                    .padding()
                } else if selectedTab == .approve {
                    Text("Approve View Pending")
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Bottom Tab Bar
            HStack(spacing: 20) {
                TabButton(title: "Monitor", icon: "square.grid.2x2", isSelected: selectedTab == .monitor) { selectedTab = .monitor }
                TabButton(title: "Approve", icon: "hand.thumbsup", isSelected: selectedTab == .approve) { selectedTab = .approve }
                TabButton(title: "Ask", icon: "bubble.left.and.bubble.right", isSelected: selectedTab == .ask) { selectedTab = .ask }
                TabButton(title: "Jump", icon: "arrow.up.right.square", isSelected: selectedTab == .jump) { selectedTab = .jump }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.black.opacity(0.5))
            .clipShape(Capsule())
            .padding(.bottom, 12)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(isSelected ? .white : .gray)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SessionCardView: View {
    @ObservedObject var session: VibeSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(session.isActive ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                Text(session.command)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(session.ide)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(4)
            }
            
            Text(session.output.suffix(200)) // Show tail of output
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.gray)
                .lineLimit(3)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
```

- [ ] **Step 2: Update ContentView to use the renamed view**
Modify `ContentView.swift` to point to `VibeIslandView()`.

### Task 3: The CLI Wrapper (`vibe-cli`)

**Files:**
- Create: `UltimateNotch/vibe-cli/main.swift`
- Create: `UltimateNotch/vibe-cli/Package.swift` (To build it as a standalone executable)

- [ ] **Step 1: Setup the Package**
Create `Package.swift` in `UltimateNotch/vibe-cli/`.

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "vibe-cli",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "vibe-cli",
            path: "."
        )
    ]
)
```

- [ ] **Step 2: Implement the CLI Wrapper**
Write `main.swift` to intercept the process.

```swift
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
if env["TERM_PROGRAM"] == "iTerm.app" { ide = "iTerm2" }
else if env["TERM_PROGRAM"] == "vscode" { ide = "VS Code" }
else if env["TERM_PROGRAM"] == "Ghostty" { ide = "Ghostty" }
else if env["TERM_PROGRAM"] == "WarpTerminal" { ide = "Warp" }
else if env["__CFBundleIdentifier"] == "com.apple.Terminal" { ide = "Terminal.app" }

let connection = NWConnection(to: .unix(path: "/tmp/vibe_island.sock"), using: .tcp)
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
```

### Task 4: Jump via AppleScript

**Files:**
- Modify: `UltimateNotch/boringNotch/components/Tabs/VibeIsland/VibeSocketServer.swift`

- [ ] **Step 1: Implement AppleScript Jump**
Add a method to `VibeManager` to activate the target IDE.

```swift
    func jumpToIDE(appName: String) {
        let scriptSource = """
        tell application "\(appName)"
            activate
        end tell
        """
        if let script = NSAppleScript(source: scriptSource) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
            }
        }
    }
```
*Note: In the UI, wire the Jump button to call `vibeManager.jumpToIDE(appName: vibeManager.sessions.first(where: { $0.isActive })?.ide ?? "Terminal")`.*

---

*End of Plan.*