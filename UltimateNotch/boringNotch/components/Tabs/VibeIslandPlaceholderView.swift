import SwiftUI

struct VibeIslandPlaceholderView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 32))
                .foregroundStyle(.gray)
            
            Text("Vibe Island")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Coming Soon. Awaiting source code.")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
