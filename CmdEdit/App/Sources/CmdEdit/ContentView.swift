import SwiftUI
import AppKit

struct ContentView: View {
    @State var text: String
    let historyFile: String
    let outputFile: String
    let statusFile: String

    @FocusState private var isFocused: Bool
    @State private var isHistoryPresented = false
    @State private var historyQuery = ""
    @State private var historySearchField: FocusAwareTextField?
    @State private var historySearchShouldFocus = false
    @State private var historyItems: [String] = []
    @State private var historyDisplayItems: [String] = []
    @State private var isHistoryLoaded = false
    @State private var starredCommands: Set<String> = []

    init(initialText: String, historyFile: String, outputFile: String, statusFile: String) {
        _text = State(initialValue: initialText)
        self.historyFile = historyFile
        self.outputFile = outputFile
        self.statusFile = statusFile
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(NSColor.windowBackgroundColor).opacity(0.9),
                    Color(NSColor.controlBackgroundColor).opacity(0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if isHistoryPresented {
                historyPage
            } else {
                mainPage
            }
        }
        .frame(minWidth: 720, minHeight: 420)
        .onAppear {
            isFocused = true
            loadStarredCommands()
            preloadHistoryIfNeeded()
        }
        .background(
            WindowEventMonitor(isHistoryPresented: isHistoryPresented) {
                clearHistorySearchFocus()
            } onEscape: {
                if isHistoryPresented {
                    closeHistory()
                } else {
                    finish(status: "CANCEL")
                }
            }
        )
        .onExitCommand {
            if isHistoryPresented {
                closeHistory()
            } else {
                finish(status: "CANCEL")
            }
        }
    }

    private var mainPage: some View {
        VStack(spacing: 18) {
            header
            editor
        }
        .padding(22)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            AppIconMark()

            Text("CmdEdit")
                .font(.system(size: 27, weight: .semibold, design: .rounded))
                .tracking(-0.15)
                .padding(.bottom, 1)
                .frame(height: 44, alignment: .center)

            Spacer()

            HStack(spacing: 10) {
                HoverButton(
                    title: "History",
                    shortcut: "Cmd+Shift+H",
                    prominence: .secondary
                ) {
                    openHistory()
                }
                .keyboardShortcut("H", modifiers: [.command, .shift])

                HoverButton(
                    title: "Save Back",
                    shortcut: "Cmd+S",
                    prominence: .primary
                ) {
                    finish(status: "SAVE")
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            .frame(height: 44, alignment: .center)
        }
        .frame(minHeight: 52)
    }

    private var editor: some View {
        VStack(spacing: 0) {
            HStack {
                Label("Shell Buffer", systemImage: "chevron.left.forwardslash.chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Multiline supported")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.04))

            Rectangle()
                .fill(Color.white.opacity(0.035))
                .frame(height: 1)
                .padding(.horizontal, 20)

            ZStack(alignment: .topLeading) {
                CommandEditor(text: $text, isFocused: $isFocused)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(nsColor: NSColor(calibratedWhite: 0.11, alpha: 1.0)))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var historyPage: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                Button {
                    closeHistory()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 23, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                HistorySearchBar(
                    text: $historyQuery,
                    shouldFocus: $historySearchShouldFocus,
                    textFieldReference: $historySearchField
                ) {
                    if let firstItem = filteredHistoryItems.first {
                        loadHistoryItem(firstItem)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 18)

            Divider()
                .overlay(Color.white.opacity(0.06))

            Group {
                if !isHistoryLoaded {
                    ProgressView()
                        .controlSize(.small)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 64)
                } else if filteredHistoryItems.isEmpty {
                    VStack(spacing: 8) {
                        Text("No matching commands")
                            .font(.system(size: 14, weight: .semibold))
                        Text(historyItems.isEmpty ? "Your current zsh session does not have recent history yet." : "Try a different search.")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 64)
                } else {
                    AppKitHistoryListView(
                        items: filteredHistoryItems,
                        starredCommands: starredCommands,
                        onToggleStar: toggleStarredCommand(_:),
                        onSelect: loadHistoryItem(_:)
                    )
                }
            }
        }
        .onAppear {
            historySearchShouldFocus = true
        }
        .onExitCommand {
            closeHistory()
        }
    }

    private var filteredHistoryItems: [String] {
        let trimmedQuery = historyQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let allItems = historyDisplayItems
        guard !trimmedQuery.isEmpty else { return allItems }
        return allItems.filter { item in
            item.localizedCaseInsensitiveContains(trimmedQuery)
        }
    }

    private var defaultOrderedHistoryItems: [String] {
        let starred = historyItems.filter { starredCommands.contains($0) }
        let savedOnlyStarred = starredCommands
            .filter { !historyItems.contains($0) }
            .sorted()
        let unstarred = historyItems.filter { !starredCommands.contains($0) }
        return starred + savedOnlyStarred + unstarred
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

    private func openHistory() {
        historyQuery = ""
        isHistoryPresented = true
        isFocused = false
        historyDisplayItems = defaultOrderedHistoryItems
        preloadHistoryIfNeeded()
    }

    private func closeHistory() {
        isHistoryPresented = false
        historyQuery = ""
        historySearchShouldFocus = false
        isFocused = true
    }

    private func loadHistoryItem(_ item: String) {
        text = item
        closeHistory()
    }

    private func clearHistorySearchFocus() {
        historySearchShouldFocus = false
        NSApplication.shared.keyWindow?.makeFirstResponder(nil)
    }

    private func focusHistorySearch() {
        historySearchShouldFocus = true
        historySearchField?.window?.makeFirstResponder(historySearchField)
    }

    private func toggleStarredCommand(_ command: String) {
        if starredCommands.contains(command) {
            starredCommands.remove(command)
        } else {
            starredCommands.insert(command)
        }
        historyDisplayItems = defaultOrderedHistoryItems
        saveStarredCommands()
    }

    private func loadStarredCommands() {
        starredCommands = StarredCommandsStore.load()
        historyDisplayItems = defaultOrderedHistoryItems
    }

    private func saveStarredCommands() {
        StarredCommandsStore.save(starredCommands)
    }

    private func preloadHistoryIfNeeded() {
        guard !isHistoryLoaded else { return }

        let path = historyFile
        DispatchQueue.global(qos: .userInitiated).async {
            let loadedItems = Self.loadHistoryItems(from: path)
            DispatchQueue.main.async {
                historyItems = loadedItems
                historyDisplayItems = defaultOrderedHistoryItems
                isHistoryLoaded = true
            }
        }
    }

    private static func loadHistoryItems(from historyFile: String) -> [String] {
        guard !historyFile.isEmpty,
              let data = try? Data(contentsOf: URL(fileURLWithPath: historyFile)),
              !data.isEmpty else {
            return []
        }

        return data
            .split(separator: 0)
            .compactMap { chunk in
                let item = String(data: Data(chunk), encoding: .utf8)?
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return item?.isEmpty == false ? item : nil
            }
    }
}

private enum StarredCommandsStore {
    private static let fileName = "starred-history.json"

    static func load() -> Set<String> {
        guard let url = fileURL(),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(items)
    }

    static func save(_ commands: Set<String>) {
        guard let url = fileURL() else { return }
        let sortedCommands = commands.sorted()
        guard let data = try? JSONEncoder().encode(sortedCommands) else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? data.write(to: url, options: .atomic)
    }

    private static func fileURL() -> URL? {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        return appSupport?
            .appendingPathComponent("CmdEdit", isDirectory: true)
            .appendingPathComponent(fileName)
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
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(backgroundStyle, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1)
                }
                .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
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
        .frame(width: 44, height: 44)
        .shadow(color: .black.opacity(0.14), radius: 8, y: 4)
    }
}

private struct KeycapBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
            }
    }
}

private struct HistorySearchBar: NSViewRepresentable {
    @Binding var text: String
    @Binding var shouldFocus: Bool
    @Binding var textFieldReference: FocusAwareTextField?
    let onSubmit: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, shouldFocus: $shouldFocus, onSubmit: onSubmit)
    }

    func makeNSView(context: Context) -> HistorySearchBarView {
        let view = HistorySearchBarView()
        view.textField.delegate = context.coordinator
        view.textField.target = context.coordinator
        view.textField.action = #selector(Coordinator.submit)
        view.textField.focusDidChange = { focused in
            view.setActive(focused)
            DispatchQueue.main.async {
                shouldFocus = focused
            }
        }
        view.onActivate = {
            view.window?.makeFirstResponder(view.textField)
        }
        DispatchQueue.main.async {
            textFieldReference = view.textField
        }
        return view
    }

    func updateNSView(_ view: HistorySearchBarView, context: Context) {
        if textFieldReference !== view.textField {
            DispatchQueue.main.async {
                textFieldReference = view.textField
            }
        }
        if view.textField.stringValue != text {
            view.textField.stringValue = text
        }
        view.setActive(view.textField.currentEditor() != nil || view.window?.firstResponder === view.textField.currentEditor())
        if shouldFocus, view.window?.firstResponder !== view.textField.currentEditor() {
            view.window?.makeFirstResponder(view.textField)
        }
    }

    final class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        @Binding var shouldFocus: Bool
        let onSubmit: () -> Void

        init(text: Binding<String>, shouldFocus: Binding<Bool>, onSubmit: @escaping () -> Void) {
            _text = text
            _shouldFocus = shouldFocus
            self.onSubmit = onSubmit
        }

        func controlTextDidChange(_ notification: Notification) {
            guard let textField = notification.object as? NSTextField else { return }
            text = textField.stringValue
        }

        func controlTextDidEndEditing(_ notification: Notification) {
            shouldFocus = false
        }

        @objc func submit() {
            onSubmit()
        }
    }
}

private final class FocusAwareTextField: NSTextField {
    var focusDidChange: ((Bool) -> Void)?

    override func becomeFirstResponder() -> Bool {
        let became = super.becomeFirstResponder()
        if became {
            focusDidChange?(true)
        }
        return became
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        if resigned {
            focusDidChange?(false)
        }
        return resigned
    }
}

private final class HistorySearchBarView: NSView {
    let iconView = NSImageView()
    let textField = FocusAwareTextField()
    let borderLayer = CAShapeLayer()
    let backgroundLayer = CAShapeLayer()
    var onActivate: (() -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = false

        backgroundLayer.fillColor = NSColor(calibratedWhite: 0.0, alpha: 0.14).cgColor
        layer?.addSublayer(backgroundLayer)

        borderLayer.lineWidth = 1.25
        borderLayer.fillColor = NSColor.clear.cgColor
        layer?.addSublayer(borderLayer)

        iconView.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: nil)
        iconView.symbolConfiguration = NSImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        iconView.contentTintColor = .secondaryLabelColor
        iconView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconView)

        textField.isBordered = false
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.focusRingType = .none
        textField.font = .systemFont(ofSize: 16, weight: .medium)
        textField.textColor = .labelColor
        textField.placeholderString = "Search commands..."
        textField.placeholderAttributedString = NSAttributedString(
            string: "Search commands...",
            attributes: [
                .foregroundColor: NSColor.secondaryLabelColor,
                .font: NSFont.systemFont(ofSize: 16, weight: .medium)
            ]
        )
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 50),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 20),
            textField.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 14),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(handleClick))
        addGestureRecognizer(click)
        setActive(false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        let path = CGPath(roundedRect: bounds.insetBy(dx: 0.625, dy: 0.625), cornerWidth: 14, cornerHeight: 14, transform: nil)
        backgroundLayer.path = path
        borderLayer.path = path
    }

    func setActive(_ active: Bool) {
        iconView.contentTintColor = active ? .controlAccentColor : .secondaryLabelColor
        borderLayer.strokeColor = (active ? NSColor.controlAccentColor : NSColor.white.withAlphaComponent(0.08)).cgColor
    }

    @objc private func handleClick() {
        onActivate?()
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
        let commandTextColor = NSColor(calibratedRed: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
        textView.isRichText = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        textView.textColor = commandTextColor
        textView.backgroundColor = .clear
        textView.insertionPointColor = commandTextColor
        textView.typingAttributes = [
            .font: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular),
            .foregroundColor: commandTextColor
        ]
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor.controlAccentColor.withAlphaComponent(0.38),
            .foregroundColor: commandTextColor
        ]
        textView.textContainerInset = NSSize(width: 18, height: 18)
        textView.string = text
        textView.delegate = context.coordinator
        textView.drawsBackground = true
        textView.backgroundColor = NSColor(calibratedWhite: 0.10, alpha: 1.0)
        textView.textStorage?.setAttributes([
            .font: NSFont.monospacedSystemFont(ofSize: 15, weight: .regular),
            .foregroundColor: commandTextColor
        ], range: NSRange(location: 0, length: textView.string.utf16.count))

        scrollView.documentView = textView
        context.coordinator.textView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView else { return }

        if textView.string != text {
            textView.string = text
            textView.textStorage?.setAttributes(textView.typingAttributes, range: NSRange(location: 0, length: textView.string.utf16.count))
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

private struct AppKitHistoryListView: NSViewRepresentable {
    let items: [String]
    let starredCommands: Set<String>
    let onToggleStar: (String) -> Void
    let onSelect: (String) -> Void

    func makeNSView(context: Context) -> HistoryHostingScrollView {
        let scrollView = HistoryHostingScrollView()
        let hostingView = NSHostingView(rootView: AnyView(historyContent))
        hostingView.frame = NSRect(origin: .zero, size: hostingView.fittingSize)
        scrollView.documentView = hostingView
        scrollView.hostingView = hostingView
        scrollView.updateDocumentLayout()
        return scrollView
    }

    func updateNSView(_ scrollView: HistoryHostingScrollView, context: Context) {
        if let hostingView = scrollView.hostingView {
            hostingView.rootView = AnyView(historyContent)
            scrollView.updateDocumentLayout()
        }
    }

    private var historyContent: some View {
        VStack(spacing: 0) {
            LazyVStack(spacing: 4) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HistoryCommandRow(
                        command: item,
                        isStarred: starredCommands.contains(item),
                        onToggleStar: {
                            onToggleStar(item)
                        },
                        onSelect: {
                            onSelect(item)
                        }
                    )
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .background(Color.clear)
    }
}

private final class HistoryHostingScrollView: NSScrollView {
    weak var hostingView: NSHostingView<AnyView>?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        drawsBackground = false
        borderType = .noBorder
        hasVerticalScroller = true
        hasHorizontalScroller = false
        autohidesScrollers = false
        contentInsets = NSEdgeInsets()
        scrollerInsets = NSEdgeInsets()
        verticalScroller = ThinHistoryScroller()
        if let verticalScroller {
            verticalScroller.scrollerStyle = .overlay
            verticalScroller.controlSize = .small
        }
    }

    convenience init() {
        self.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var documentView: NSView? {
        didSet {
            if let hosting = documentView as? NSHostingView<AnyView> {
                hostingView = hosting
            }
        }
    }

    override func layout() {
        super.layout()
        updateDocumentLayout()
    }

    func updateDocumentLayout() {
        guard let hostingView else { return }
        let width = contentSize.width
        guard width > 0 else { return }
        hostingView.frame = NSRect(x: 0, y: 0, width: width, height: hostingView.frame.height)
        hostingView.layoutSubtreeIfNeeded()
        let measured = hostingView.fittingSize
        hostingView.frame = NSRect(x: 0, y: 0, width: width, height: measured.height)
    }
}

private struct HistoryCommandRow: View {
    let command: String
    let isStarred: Bool
    let onToggleStar: () -> Void
    let onSelect: () -> Void

    @State private var isHovered = false

    private var primaryLine: String {
        command.components(separatedBy: .newlines).first ?? command
    }

    private var lineCountText: String {
        let lineCount = max(command.components(separatedBy: .newlines).count, 1)
        return lineCount == 1 ? "1 line" : "\(lineCount) lines"
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(isHovered ? 0.05 : 0.0))

            HStack(spacing: 0) {
                ZStack {
                    Color.clear
                    Image(systemName: isStarred ? "star.fill" : "star")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(isStarred ? Color.yellow : Color.secondary)
                }
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
                .onTapGesture {
                    onToggleStar()
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(primaryLine)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(lineCountText)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.leading, 24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 18)
            .padding(.trailing, 32)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 54)
        .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

private final class ThinHistoryScroller: NSScroller {
    override func drawKnobSlot(in slotRect: NSRect, highlight flag: Bool) {
        // Intentionally empty. CmdEdit wants no visible track/background.
    }

    override func drawKnob() {
        guard let slotRect = self.rect(for: .knobSlot).integral.nonEmpty else { return }

        let visibleWidth: CGFloat = 6
        let knobRect = self.rect(for: .knob).integral
        let x = slotRect.midX - (visibleWidth / 2)
        let insetKnob = NSRect(x: x, y: knobRect.minY, width: visibleWidth, height: knobRect.height)
            .insetBy(dx: 0, dy: 1)

        let path = NSBezierPath(roundedRect: insetKnob, xRadius: 3, yRadius: 3)
        NSColor.white.withAlphaComponent(0.45).setFill()
        path.fill()
    }
}

private extension NSRect {
    var nonEmpty: NSRect? {
        guard width > 0, height > 0 else { return nil }
        return self
    }
}


private struct WindowEventMonitor: NSViewRepresentable {
    let isHistoryPresented: Bool
    let onMouseDown: () -> Void
    let onEscape: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onMouseDown: onMouseDown, onEscape: onEscape)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        context.coordinator.attach()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.isHistoryPresented = isHistoryPresented
    }

    final class Coordinator {
        let onMouseDown: () -> Void
        let onEscape: () -> Void
        var mouseMonitor: Any?
        var keyMonitor: Any?
        var isHistoryPresented = false

        init(onMouseDown: @escaping () -> Void, onEscape: @escaping () -> Void) {
            self.onMouseDown = onMouseDown
            self.onEscape = onEscape
        }

        func attach() {
            if mouseMonitor == nil {
                mouseMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown]) { [weak self] event in
                    guard let self, self.isHistoryPresented else { return event }
                    if let window = event.window {
                        let location = window.contentView?.convert(event.locationInWindow, from: nil) ?? event.locationInWindow
                        if let hitView = window.contentView?.hitTest(location),
                           hitView.enclosingSearchField != nil {
                            return event
                        }
                    }
                    self.onMouseDown()
                    return event
                }
            }

            if keyMonitor == nil {
                keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                    guard let self else { return event }
                    if event.keyCode == 53 {
                        self.onEscape()
                        return nil
                    }
                    return event
                }
            }
        }

        deinit {
            if let mouseMonitor {
                NSEvent.removeMonitor(mouseMonitor)
            }
            if let keyMonitor {
                NSEvent.removeMonitor(keyMonitor)
            }
        }
    }
}

private extension NSView {
    var enclosingSearchField: NSTextField? {
        var currentView: NSView? = self
        while let view = currentView {
            if let textField = view as? NSTextField {
                return textField
            }
            currentView = view.superview
        }
        return nil
    }
}
