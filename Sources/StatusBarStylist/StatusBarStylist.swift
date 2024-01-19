// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

private struct StatusBarViewModifier: ViewModifier {

    // This `currentStatusBarStyle` is needed to make the modifier work when
    // a view is presented as a `sheet` or `fullScreenCover`.
    private var currentStatusBarStyle: UIStatusBarStyle?
    private let preferredStatusBarStyle: UIStatusBarStyle
    private var statusBarWindow: UIWindow?

    private var statusBarViewController: StatusBarViewController? {
        statusBarWindow?.rootViewController as? StatusBarViewController
    }

    @SwiftUI.Environment(\.isPresented)
    private var isPresented

    init(style: UIStatusBarStyle) {
        preferredStatusBarStyle = style

        statusBarWindow = UIApplication.shared.statusBarWindow
        currentStatusBarStyle = statusBarViewController?.statusBarStyle
        statusBarViewController?.statusBarStyle = preferredStatusBarStyle
    }

    func body(content: Content) -> some View {
        content
            .onAppear {
                statusBarViewController?.statusBarStyle = preferredStatusBarStyle
            }
            .onDisappear {
                if isPresented, let currentStatusBarStyle {
                    statusBarViewController?.statusBarStyle = currentStatusBarStyle
                }
            }
    }
}

private class StatusBarViewController: UIViewController {

    var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension View {

    func preferredStatusBarStyle(_ style: UIStatusBarStyle) -> some View {
        modifier(StatusBarViewModifier(style: style))
    }
}

extension UIApplication {

    private static let statusBarWindowTag = -9999

    fileprivate var statusBarWindow: UIWindow? {
        guard let windowScene = connectedScenes.first as? UIWindowScene else {
            return nil
        }

        if let window = windowScene.windows.first(where: { $0.tag == Self.statusBarWindowTag }) {
            return window
        } else {
            let window = UIWindow(windowScene: windowScene)
            window.windowLevel = .statusBar
            window.tag = Self.statusBarWindowTag
            window.isUserInteractionEnabled = false
            window.rootViewController = StatusBarViewController()
            window.isHidden = false
            return window
        }
    }
}
