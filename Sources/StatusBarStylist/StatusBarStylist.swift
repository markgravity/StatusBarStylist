// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

extension UIApplication {

    var keyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first {
                $0.isKeyWindow
            }
    }
}

extension UIViewController {

    enum Holder {
        static var statusBarStyleStack: [UIStatusBarStyle] = .init()
    }

    func interpose() -> Bool {
        let sel1: Selector = #selector(
            getter: preferredStatusBarStyle
        )
        let sel2: Selector = #selector(
            getter: preferredStatusBarStyleModified
        )

        let original = class_getInstanceMethod(Self.self, sel1)
        let new = class_getInstanceMethod(Self.self, sel2)

        if let original = original, let new = new {
            method_exchangeImplementations(original, new)

            return true
        }

        return false
    }

    @objc dynamic var preferredStatusBarStyleModified: UIStatusBarStyle {
        Holder.statusBarStyleStack.last ?? .default
    }
}

struct StatusBarStyle: ViewModifier {

    @Environment(\.interposed) private var interposed

    let statusBarStyle: UIStatusBarStyle
    let animationDuration: TimeInterval

    private func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) {
        UIViewController.Holder.statusBarStyleStack.append(statusBarStyle)

        UIView.animate(withDuration: animationDuration) {
            UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                setStatusBarStyle(statusBarStyle)
            }
            .onChange(of: statusBarStyle) {
                _ = UIViewController.Holder.statusBarStyleStack.removeLast()
                setStatusBarStyle($0)
            }
            .onDisappear {
                _ = UIViewController.Holder.statusBarStyleStack.removeLast()

                UIView.animate(withDuration: animationDuration) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
            // Interposing might still be pending on initial render
            .onChange(of: interposed) { _ in
                UIView.animate(withDuration: animationDuration) {
                    UIApplication.shared.keyWindow?.rootViewController?.setNeedsStatusBarAppearanceUpdate()
                }
            }
    }
}

public extension View {

    func statusBarStyle(
        _ statusBarStyle: UIStatusBarStyle,
        animationDuration: TimeInterval = 0.3
    ) -> some View {
        modifier(StatusBarStyle(statusBarStyle: statusBarStyle, animationDuration: animationDuration))
    }
}

public struct RootView<Content>: View where Content: View {

    @Environment(\.scenePhase) var scenePhase
    @State var interposed: Interposed = .pending
    @ViewBuilder let content: () -> Content
    var interposeLock = NSLock()

    public var body: some View {
        content()
            .environment(\.interposed, interposed)
            .onChange(of: scenePhase) { phase in
                if case .active = phase {
                    interposeLock.lock()
                    if case .pending = interposed,
                       case true = UIApplication.shared.keyWindow?.rootViewController?.interpose() {
                        interposed = .successful
                    } else {
                        interposed = .failed
                    }
                    interposeLock.unlock()
                }
            }
    }

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}
