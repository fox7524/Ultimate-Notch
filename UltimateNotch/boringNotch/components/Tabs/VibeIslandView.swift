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
                TabButton(title: "Jump", icon: "arrow.up.right.square", isSelected: selectedTab == .jump) {
                    selectedTab = .jump
                    if let activeSession = vibeManager.sessions.first(where: { $0.isActive }) {
                        vibeManager.jumpToIDE(appName: activeSession.ide)
                    }
                }
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
