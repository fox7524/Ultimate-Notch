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
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let boringNotchDir = appSupport.appendingPathComponent("boringNotch")
        try? FileManager.default.createDirectory(at: boringNotchDir, withIntermediateDirectories: true)
        
        let socketPath = NSTemporaryDirectory() + "vibe.sock"
        unlink(socketPath)
        
        // Write the socket path to Application Support so vibe-cli can find it
        let pathFile = boringNotchDir.appendingPathComponent("socket_path.txt")
        try? socketPath.write(to: pathFile, atomically: true, encoding: .utf8)
        
        do {
            let parameters = NWParameters()
            parameters.requiredLocalEndpoint = NWEndpoint.unix(path: socketPath)
            parameters.allowLocalEndpointReuse = true
            
            listener = try NWListener(using: parameters)
            listener?.newConnectionHandler = { [weak self] connection in
                Task { @MainActor in
                    self?.handleConnection(connection)
                }
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
                Task { @MainActor in
                    self.processMessage(message)
                }
            }
            
            if !isComplete && error == nil {
                Task { @MainActor in
                    self.receiveMessage(on: connection)
                }
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
}
