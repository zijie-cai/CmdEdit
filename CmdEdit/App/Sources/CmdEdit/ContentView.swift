import SwiftUI
import AppKit

struct ContentView: View {
    @State var text: String
    let outputFile: String
    let statusFile: String
    
    @FocusState private var isFocused: Bool
    
    init(initialText: String, outputFile: String, statusFile: String) {
        _text = State(initialValue: initialText)
        self.outputFile = outputFile
        self.statusFile = statusFile
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor).opacity(0.88),
                    Color(NSColor.controlBackgroundColor).opacity(0.72)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                header
                editor
            }
            .padding(22)
        }
        .frame(minWidth: 720, minHeight: 420)
        .onAppear {
            isFocused = true
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            AppIconMark()

            VStack(alignment: .leading, spacing: 6) {
                Text("CmdEdit")
                    .font(.system(size: 26, weight: .semibold, design: .rounded))

                Text("Edit the shell buffer, then write it back to your prompt.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            HStack(spacing: 10) {
                HoverButton(
                    title: "Cancel",
                    shortcut: "Esc",
                    prominence: .secondary
                ) {
                    finish(status: "CANCEL")
                }
                .keyboardShortcut(.escape, modifiers: [])

                HoverButton(
                    title: "Save Back",
                    shortcut: "Cmd+S",
                    prominence: .primary
                ) {
                    finish(status: "SAVE")
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
        }
    }

    private var editor: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Shell Buffer", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Multiline supported")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }

            CommandEditor(text: $text, isFocused: $isFocused)
                .focused($isFocused)
        }
        .padding(18)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
    }
    
    func finish(status: String) {
        NSApplication.shared.keyWindow?.makeFirstResponder(nil)

        if !outputFile.isEmpty {
            try? text.write(toFile: outputFile, atomically: true, encoding: .utf8)
        }
        if !statusFile.isEmpty {
            try? status.write(toFile: statusFile, atomically: true, encoding: .utf8)
        }
        NSApplication.shared.terminate(nil)
    }
}

private struct ActionButtonLabel: View {
    let title: String
    let shortcut: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
            Text(shortcut)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(.secondary)
        }
        .font(.system(size: 12, weight: .medium))
    }
}

private struct HoverButton: View {
    enum Prominence {
        case primary
        case secondary
    }

    let title: String
    let shortcut: String
    let prominence: Prominence
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            ActionButtonLabel(title: title, shortcut: shortcut)
                .padding(.horizontal, 2)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        }
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeOut(duration: 0.14), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }

    private var backgroundStyle: some ShapeStyle {
        switch prominence {
        case .primary:
            return AnyShapeStyle(
                isHovered
                    ? Color.accentColor.opacity(0.92)
                    : Color.accentColor.opacity(0.82)
            )
        case .secondary:
            return AnyShapeStyle(
                isHovered
                    ? Color.white.opacity(0.12)
                    : Color.white.opacity(0.06)
            )
        }
    }

    private var borderColor: Color {
        switch prominence {
        case .primary:
            return isHovered ? Color.white.opacity(0.24) : Color.white.opacity(0.12)
        case .secondary:
            return isHovered ? Color.white.opacity(0.16) : Color.white.opacity(0.08)
        }
    }
}

private struct AppIconMark: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.20, green: 0.21, blue: 0.24),
                            Color(red: 0.09, green: 0.10, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.10),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )

            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.black.opacity(0.22), lineWidth: 0.5)
                .padding(3)

            Image(systemName: "command")
                .font(.system(size: 21, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.97, green: 0.97, blue: 0.98),
                            Color(red: 0.82, green: 0.83, blue: 0.86)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.25), radius: 1, y: 1)
        }
        .frame(width: 52, height: 52)
        .shadow(color: .black.opacity(0.18), radius: 12, y: 6)
    }
}

private struct CommandEditor: NSViewRepresentable {
    @Binding var text: String
    var isFocused: FocusState<Bool>.Binding

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let textView = NSTextView()
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = NSColor.labelColor
        textView.backgroundColor = .clear
        textView.insertionPointColor = NSColor.labelColor
        textView.textContainerInset = NSSize(width: 16, height: 16)
        textView.string = text
        textView.delegate = context.coordinator
        textView.drawsBackground = true
        textView.backgroundColor = NSColor.black.withAlphaComponent(0.16)

        scrollView.documentView = textView
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }

        if textView.string != text {
            textView.string = text
        }

        if isFocused.wrappedValue, textView.window?.firstResponder !== textView {
            textView.window?.makeFirstResponder(textView)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        weak var textView: NSTextView?

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            text = textView.string
        }

        func textDidEndEditing(_ notification: Notification) {
            guard let textView else { return }
            text = textView.string
        }
    }
}
