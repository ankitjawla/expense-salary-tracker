//
//  OnboardingView.swift
//  Expense & Salary Tracker
//

import SwiftUI

private struct OnboardingPage: Sendable {
    let icon: String
    let title: String
    let subtitle: String
    let accentColor: Color
    let gradientStart: Color
    let gradientEnd: Color
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var pageIndex = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "chart.pie.fill",
            title: "Your finances, simplified",
            subtitle: "A clear dashboard, monthly totals, and savings — all at a glance. No account needed.",
            accentColor: .teal,
            gradientStart: Color(red: 0.08, green: 0.55, blue: 0.55),
            gradientEnd: Color(red: 0.02, green: 0.35, blue: 0.45)
        ),
        OnboardingPage(
            icon: "list.bullet.rectangle.fill",
            title: "Every transaction, under control",
            subtitle: "Search, filter, categorize, and edit entries anytime. Spot trends in Analytics.",
            accentColor: .indigo,
            gradientStart: Color(red: 0.28, green: 0.24, blue: 0.72),
            gradientEnd: Color(red: 0.15, green: 0.10, blue: 0.50)
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Private by design",
            subtitle: "All data lives on your iPhone with SwiftData. No sign-in, no cloud, no tracking.",
            accentColor: .green,
            gradientStart: Color(red: 0.10, green: 0.60, blue: 0.30),
            gradientEnd: Color(red: 0.04, green: 0.38, blue: 0.20)
        ),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Page background gradient (animates on page change)
            LinearGradient(
                colors: [
                    pages[pageIndex].gradientStart,
                    pages[pageIndex].gradientEnd
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.4), value: pageIndex)

            TabView(selection: $pageIndex) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageContent(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            // Bottom action area
            VStack(spacing: 12) {
                Button(action: advance) {
                    HStack {
                        Text(pageIndex == pages.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                        Image(systemName: pageIndex == pages.count - 1 ? "checkmark" : "arrow.right")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(pages[pageIndex].gradientStart)
                }
                .padding(.horizontal, 24)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.25), value: pageIndex)

                Button("Skip") {
                    completeOnboarding()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.75))
                .padding(.bottom, 28)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Skip") {
                    completeOnboarding()
                }
                .fontWeight(.medium)
                .foregroundStyle(.white.opacity(0.9))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func pageContent(_ page: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 48)

            // Icon in a large frosted circle
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(.white.opacity(0.08))
                    .frame(width: 150, height: 150)
                Image(systemName: page.icon)
                    .font(.system(size: 52, weight: .medium))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
            .shadow(color: .black.opacity(0.2), radius: 24, x: 0, y: 8)

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)

                Text(page.subtitle)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 32)
            }

            Spacer(minLength: 160)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }

    private func advance() {
        if pageIndex < pages.count - 1 {
            withAnimation(.spring(duration: 0.4, bounce: 0.1)) {
                pageIndex += 1
            }
            Haptics.lightTap()
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        hasCompletedOnboarding = true
        Haptics.success()
    }
}

#Preview {
    OnboardingView()
}
