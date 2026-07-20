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
