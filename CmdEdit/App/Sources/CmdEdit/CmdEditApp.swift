import SwiftUI
import AppKit

@main
struct CmdEditApp {
    static let delegate = AppDelegate()
    
    static func main() {
        let app = NSApplication.shared
        app.delegate = delegate
        app.run()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.applicationIconImage = AppIconImage.make()

        // Parse arguments
        let args = ProcessInfo.processInfo.arguments
        var inputFile = ""
        var outputFile = ""
        var statusFile = ""
        
        if args.count >= 4 {
            inputFile = args[1]
            outputFile = args[2]
            statusFile = args[3]
        }
        
        let initialText = (try? String(contentsOfFile: inputFile)) ?? ""

        let contentView = ContentView(
            initialText: initialText,
            outputFile: outputFile,
            statusFile: statusFile
        )

        // Create a custom borderless window
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 400),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.center()
        
        // Add visual effect view for glass effect
        let visualEffect = NSVisualEffectView()
        visualEffect.blendingMode = .behindWindow
        visualEffect.state = .active
        visualEffect.material = .popover
        
        let hostingView = NSHostingView(rootView: contentView)
        
        visualEffect.addSubview(hostingView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: visualEffect.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: visualEffect.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: visualEffect.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: visualEffect.trailingAnchor)
        ])
        
        window.contentView = visualEffect
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

enum AppIconImage {
    static func make(size: CGFloat = 512) -> NSImage {
        let image = NSImage(size: NSSize(width: size, height: size))
        image.lockFocus()

        let rect = NSRect(origin: .zero, size: image.size)
        let roundedRect = NSBezierPath(roundedRect: rect, xRadius: size * 0.22, yRadius: size * 0.22)

        let gradient = NSGradient(colors: [
            NSColor(calibratedRed: 0.20, green: 0.21, blue: 0.24, alpha: 1.0),
            NSColor(calibratedRed: 0.09, green: 0.10, blue: 0.12, alpha: 1.0)
        ])!
        gradient.draw(in: roundedRect, angle: -35)

        let topGloss = NSGradient(colors: [
            NSColor.white.withAlphaComponent(0.10),
            NSColor.clear
        ])!
        topGloss.draw(in: roundedRect, angle: 120)

        NSColor.white.withAlphaComponent(0.08).setStroke()
        roundedRect.lineWidth = max(6, size * 0.014)
        roundedRect.stroke()

        let innerBorder = NSBezierPath(
            roundedRect: rect.insetBy(dx: size * 0.03, dy: size * 0.03),
            xRadius: size * 0.18,
            yRadius: size * 0.18
        )
        NSColor.black.withAlphaComponent(0.22).setStroke()
        innerBorder.lineWidth = max(2, size * 0.004)
        innerBorder.stroke()

        if let commandSymbol = NSImage(
            systemSymbolName: "command",
            accessibilityDescription: "CmdEdit command icon"
        )?.withSymbolConfiguration(.init(pointSize: size * 0.40, weight: .bold)) {
            let symbolRect = NSRect(
                x: size * 0.24,
                y: size * 0.22,
                width: size * 0.52,
                height: size * 0.52
            )
            NSColor(calibratedRed: 0.95, green: 0.95, blue: 0.97, alpha: 1.0).set()
            commandSymbol.draw(
                in: symbolRect,
                from: .zero,
                operation: .sourceOver,
                fraction: 1.0
            )
        }

        image.unlockFocus()
        return image
    }
}
