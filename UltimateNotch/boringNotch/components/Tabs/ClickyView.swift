import SwiftUI
import Defaults

extension Defaults.Keys {
    static let anthropicAPIKey = Key<String>("anthropicAPIKey", default: "")
    static let elevenLabsAPIKey = Key<String>("elevenLabsAPIKey", default: "")
    static let assemblyAIAPIKey = Key<String>("assemblyAIAPIKey", default: "")
}

struct ClickyView: View {
    @StateObject private var companionManager = (NSApplication.shared.delegate as! AppDelegate).companionManager
    
    @Default(.anthropicAPIKey) var anthropicAPIKey
    @Default(.elevenLabsAPIKey) var elevenLabsAPIKey
    @Default(.assemblyAIAPIKey) var assemblyAIAPIKey
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("API Configuration")
                        .font(.headline)
                        .foregroundStyle(.white)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anthropic API Key")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        SecureField("sk-ant-...", text: $anthropicAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ElevenLabs API Key")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        SecureField("...", text: $elevenLabsAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("AssemblyAI API Key")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                        SecureField("...", text: $assemblyAIAPIKey)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Divider().padding(.vertical, 8)
                    
                    CompanionPanelView(companionManager: companionManager)
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
