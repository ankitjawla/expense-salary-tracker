//
//  AppLockGate.swift
//  Expense & Salary Tracker
//

import LocalAuthentication
import SwiftUI

struct AppLockGate<Content: View>: View {
    @AppStorage("appLockEnabled") private var appLockEnabled = false

    @Environment(\.scenePhase) private var scenePhase

    @State private var unlocked = true
    @State private var authFailedMessage: String?
    @State private var showDisableLockConfirm = false

    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            content()
                .disabled(appLockEnabled && !unlocked)

            if appLockEnabled && !unlocked {
                lockOverlay
            }
        }
        .onAppear(perform: syncLockState)
        .onChange(of: scenePhase) { _, phase in
            if appLockEnabled, phase == .background {
                unlocked = false
            }
        }
        .onChange(of: appLockEnabled) { _, _ in
            syncLockState()
        }
        .alert("Turn off App Lock?", isPresented: $showDisableLockConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Turn Off", role: .destructive) {
                appLockEnabled = false
                authFailedMessage = nil
            }
        } message: {
            Text("Anyone with access to this device can open the app. Use this if Face ID or passcode unlock is not available (for example, in the Simulator).")
        }
    }

    private var lockOverlay: some View {
        ZStack {
            Color.black.opacity(0.92)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.secondary)
                Text("Expense & Salary Tracker")
                    .font(.headline)
                Button("Unlock with Face ID / Touch ID") {
                    authenticate(preferBiometricsOnly: true)
                }
                .buttonStyle(.borderedProminent)

                Button("Use device passcode") {
                    authenticate(preferBiometricsOnly: false)
                }
                .buttonStyle(.bordered)
                .font(.subheadline)

                if let authFailedMessage {
                    Text(authFailedMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button("Turn off App Lock…") {
                    showDisableLockConfirm = true
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
            .padding(32)
        }
    }

    private func syncLockState() {
        if appLockEnabled {
            unlocked = false
            authFailedMessage = nil
            let context = LAContext()
            var err: NSError?
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &err) {
                evaluate(context, policy: .deviceOwnerAuthentication)
            }
            // If local auth is not available (typical Simulator), overlay stays up; user can turn lock off.
        } else {
            unlocked = true
            authFailedMessage = nil
        }
    }

    private func authenticate(preferBiometricsOnly: Bool) {
        authFailedMessage = nil
        let context = LAContext()
        var error: NSError?

        if preferBiometricsOnly {
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                evaluate(context, policy: .deviceOwnerAuthenticationWithBiometrics)
                return
            }
            authFailedMessage = "Biometrics are not set up or not available. Try “Use device passcode” or turn off App Lock below."
            return
        }

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            evaluate(context, policy: .deviceOwnerAuthentication)
        } else {
            authFailedMessage =
                "This device cannot use Face ID, Touch ID, or passcode here (common in the Simulator). Tap “Turn off App Lock” below to continue."
        }
    }

    private func evaluate(_ context: LAContext, policy: LAPolicy) {
        context.evaluatePolicy(
            policy,
            localizedReason: "Unlock your finance data"
        ) { success, _ in
            DispatchQueue.main.async {
                if success {
                    authFailedMessage = nil
                    unlocked = true
                } else {
                    authFailedMessage = "Could not verify. Try again or use passcode."
                }
            }
        }
    }
}
