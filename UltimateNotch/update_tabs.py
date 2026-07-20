import os

tab_selection = """//
//  TabSelectionView.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-25.
//

import SwiftUI

struct TabModel: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let isSystemIcon: Bool
    let view: NotchViews
}

let tabs = [
    TabModel(label: "Home", icon: "house.fill", isSystemIcon: true, view: .home),
    TabModel(label: "Shelf", icon: "tray.fill", isSystemIcon: true, view: .shelf),
    TabModel(label: "Clicky", icon: "clicky_icon", isSystemIcon: false, view: .clicky),
    TabModel(label: "Island", icon: "vibe_island_icon", isSystemIcon: false, view: .vibeIsland)
]

struct TabSelectionView: View {
    @ObservedObject var coordinator = BoringViewCoordinator.shared
    @Namespace var animation
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs) { tab in
                    TabButton(label: tab.label, icon: tab.icon, isSystemIcon: tab.isSystemIcon, selected: coordinator.currentView == tab.view) {
                        withAnimation(.smooth) {
                            coordinator.currentView = tab.view
                        }
                    }
                    .frame(height: 26)
                    .foregroundStyle(tab.view == coordinator.currentView ? .white : .gray)
                    .background {
                        if tab.view == coordinator.currentView {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                        } else {
                            Capsule()
                                .fill(coordinator.currentView == tab.view ? Color(nsColor: .secondarySystemFill) : Color.clear)
                                .matchedGeometryEffect(id: "capsule", in: animation)
                                .hidden()
                        }
                    }
            }
        }
        .clipShape(Capsule())
    }
}

#Preview {
    BoringHeader().environmentObject(BoringViewModel())
}
"""

tab_button = """//
//  TabButton.swift
//  boringNotch
//
//  Created by Hugo Persson on 2024-08-24.
//

import SwiftUI

struct TabButton: View {
    let label: String
    let icon: String
    let isSystemIcon: Bool
    let selected: Bool
    let onClick: () -> Void
    
    var body: some View {
        Button(action: onClick) {
            Group {
                if isSystemIcon {
                    Image(systemName: icon)
                } else {
                    Image(icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 15)
            .contentShape(Capsule())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TabButton(label: "Home", icon: "tray.fill", isSystemIcon: true, selected: true) {
        print("Tapped")
    }
}
"""

with open("/Users/fox/Documents/PROJECTS/Ultimate Notch/UltimateNotch/boringNotch/components/Tabs/TabSelectionView.swift", "w") as f:
    f.write(tab_selection)

with open("/Users/fox/Documents/PROJECTS/Ultimate Notch/UltimateNotch/boringNotch/components/Tabs/TabButton.swift", "w") as f:
    f.write(tab_button)

print("Done updating tabs")
