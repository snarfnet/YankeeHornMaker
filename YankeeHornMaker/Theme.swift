import SwiftUI

enum Theme {
    static let bg = Color(red: 0.025, green: 0.020, blue: 0.030)
    static let panel = Color(red: 0.070, green: 0.060, blue: 0.052)
    static let panelHot = Color(red: 0.165, green: 0.065, blue: 0.040)
    static let gold = Color(red: 0.925, green: 0.610, blue: 0.105)
    static let deepGold = Color(red: 0.475, green: 0.255, blue: 0.045)
    static let red = Color(red: 0.735, green: 0.035, blue: 0.020)
    static let purple = Color(red: 0.180, green: 0.210, blue: 0.235)
    static let chrome = Color(red: 0.690, green: 0.710, blue: 0.700)
    static let text = Color(red: 0.930, green: 0.885, blue: 0.790)
    static let muted = Color(red: 0.590, green: 0.535, blue: 0.455)
    static let ink = Color.black.opacity(0.72)

    static let titleFont = Font.system(size: 34, weight: .black, design: .rounded)
    static let sectionFont = Font.system(size: 18, weight: .black, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .semibold, design: .rounded)
}

struct AppBackdrop: View {
    var body: some View {
        ZStack {
            Image("YankiiGritBackground")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                colors: [
                    .black.opacity(0.18),
                    .black.opacity(0.42),
                    .black.opacity(0.76)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.clear, Color.black.opacity(0.48)],
                center: .center,
                startRadius: 90,
                endRadius: 430
            )
            .ignoresSafeArea()
        }
        .background(Theme.bg)
    }
}

struct MetalPanel: ViewModifier {
    var cornerRadius: CGFloat = 18
    var isHot = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                isHot ? Theme.panelHot.opacity(0.96) : Theme.panel.opacity(0.94),
                                Color.black.opacity(0.86)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Theme.gold.opacity(0.95),
                                        Theme.chrome.opacity(0.38),
                                        Theme.red.opacity(0.72)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.4
                            )
                    )
                    .shadow(color: Theme.red.opacity(0.18), radius: 12, x: 0, y: 8)
                    .shadow(color: .black.opacity(0.45), radius: 10, x: 0, y: 6)
            )
    }
}

extension View {
    func metalPanel(cornerRadius: CGFloat = 18, isHot: Bool = false) -> some View {
        modifier(MetalPanel(cornerRadius: cornerRadius, isHot: isHot))
    }
}

struct BrushButtonStyle: ButtonStyle {
    var kind: Kind = .gold

    enum Kind {
        case gold
        case red
        case dark
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .black, design: .rounded))
            .foregroundStyle(kind == .gold ? Color.black : Theme.text)
            .frame(maxWidth: .infinity, minHeight: 54)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .stroke(Theme.chrome.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: shadowColor, radius: configuration.isPressed ? 4 : 10, x: 0, y: configuration.isPressed ? 2 : 8)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: configuration.isPressed)
    }

    private var background: some ShapeStyle {
        switch kind {
        case .gold:
            return LinearGradient(colors: [Theme.gold, Color.white.opacity(0.88), Theme.deepGold], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .red:
            return LinearGradient(colors: [Theme.red, Color(red: 0.36, green: 0.0, blue: 0.0)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .dark:
            return LinearGradient(colors: [Theme.panelHot, Color.black], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var shadowColor: Color {
        switch kind {
        case .gold: return Theme.gold.opacity(0.34)
        case .red: return Theme.red.opacity(0.34)
        case .dark: return Theme.purple.opacity(0.24)
        }
    }
}

struct ChromeIconButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundStyle(Theme.gold)
            .frame(width: 44, height: 44)
            .background(Circle().fill(Theme.ink))
            .overlay(Circle().stroke(Theme.gold.opacity(0.78), lineWidth: 1.4))
            .shadow(color: Theme.gold.opacity(0.25), radius: 8)
    }
}

extension View {
    func chromeIconButton() -> some View {
        modifier(ChromeIconButton())
    }
}
