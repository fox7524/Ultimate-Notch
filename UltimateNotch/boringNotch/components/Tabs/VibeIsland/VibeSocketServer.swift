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
