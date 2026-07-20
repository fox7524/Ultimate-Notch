# Ultimate Notch Merge Plan

**Goal:** Merge `clicky` and `boring notch` into a single, unified Swift application, using `boring notch` as the base. We will adapt `clicky`'s capabilities to look and feel native to `boring notch`'s tabbed dropdown interface. We will also add a placeholder tab for `vibe island` (since its source code will be provided later), ensuring the application has all four requested tabs.

**Language/Framework:** Swift, SwiftUI, AppKit
**Base Architecture:** `boring notch` (GPLv3)

## 1. Project Initialization & Git Setup (✅ Completed)
- Create a new directory named `UltimateNotch` at the root.
- Copy the entire contents of `main apps/boring.notch-main` into `UltimateNotch`.
- Add `main apps/` to the `.gitignore` of the root repository to preserve the original source folders without polluting the new repository.

## 2. Licensing & IP Audit (✅ Completed)
- **Audit Result:** `boring notch` is licensed under **GPLv3**, and `clicky` is licensed under **MIT**. 
- **Action:** Merging MIT code into a GPLv3 project requires the combined project to be licensed under **GPLv3**.
- We updated the `THIRD_PARTY_LICENSES` file in the new `UltimateNotch` codebase to explicitly include the original MIT copyright notice from `clicky`.

## 3. Extending the Tab Navigation (✅ Completed)
- Modified `BoringViewCoordinator.swift` and `enums/generic.swift` to include two new cases: `.clicky` and `.vibeIsland`.
- Updated `TabSelectionView.swift` to include Clicky Tab and Vibe Island Tab.
- Updated the main switch statement in `ContentView.swift` to render `ClickyView` and `VibeIslandPlaceholderView` when their respective tabs are selected.

## 4. Merging & Adapting "Clicky" Functionality (🚧 In Progress)
- **Remove Menu Bar/Floating Panel (✅ Completed):** Stripped out Clicky's standalone lifecycle.
- **Migrate Core Logic (✅ Completed):** Copied Clicky's core managers into `UltimateNotch/boringNotch/components/Clicky`.
- **UI Adaptation (✅ Completed):** Rewrote `ClickyView.swift` to match Boring Notch's design system and included fields for API Keys.
- **API Key Configuration (🚧 In Progress):** 
  - *Completed:* Updated `AssemblyAIStreamingTranscriptionProvider`, `ClaudeAPI`, and `ElevenLabsTTSClient` to use direct APIs and read keys from `Defaults`.
  - *Pending:* Clean up `CompanionManager.swift` to remove obsolete `workerBaseURL` references and initialize clients correctly without proxies.

## 5. Vibe Island Placeholder (✅ Completed)
- Created `VibeIslandPlaceholderView.swift` that renders a "Coming Soon / Awaiting Source Code" UI to ensure 4-tab navigation is seamless.

## 6. Debugging & Testing (⏳ Pending)
- **Code Compilation:** Run Xcode build to verify all files are correctly linked and compiling without missing references or namespace collisions.
- **Error Resolution:** Fix any build errors that arise from merging the codebases (e.g. AppDelegate adjustments, missing dependencies).
- **Runtime Validation:** Test the seamless navigation between Home, Shelf, Clicky, and Vibe Island tabs. Verify Clicky's push-to-talk and transcription functionality natively inside the Notch dropdown.

---
*Once this plan is approved, I will exit Plan Mode and begin the final cleanup and execution phase immediately.*