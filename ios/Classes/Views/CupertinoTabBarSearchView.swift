import Flutter
import UIKit
import SwiftUI

/// iOS 26+ native tab bar with animated search expansion.
/// Creates the authentic Liquid Glass search behavior with custom animation.
@available(iOS 26.0, *)
class CupertinoTabBarSearchPlatformView: NSObject, FlutterPlatformView {
    private let channel: FlutterMethodChannel
    private let container: UIView
    private var hostingController: UIHostingController<AnyView>?
    private let viewModel: TabBarSearchViewModel

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        self.channel = FlutterMethodChannel(name: "CupertinoNativeTabBar_\(viewId)", binaryMessenger: messenger)
        self.container = UIView(frame: frame)
        self.viewModel = TabBarSearchViewModel()

        // Parse creation params
        var labels: [String] = []
        var symbols: [String] = []
        var activeSymbols: [String] = []
        var selectedIndex: Int = 0
        var isDark: Bool = false
        var tint: UIColor? = nil
        var searchPlaceholder: String = "Search"
        var searchSymbol: String = "magnifyingglass"

        if let dict = args as? [String: Any] {
            labels = (dict["labels"] as? [String]) ?? []
            symbols = (dict["sfSymbols"] as? [String]) ?? []
            activeSymbols = (dict["activeSfSymbols"] as? [String]) ?? []
            if let v = dict["selectedIndex"] as? NSNumber { selectedIndex = v.intValue }
            if let v = dict["isDark"] as? NSNumber { isDark = v.boolValue }
            if let style = dict["style"] as? [String: Any] {
                if let n = style["tint"] as? NSNumber {
                    tint = ImageUtils.colorFromARGB(n.intValue)
                }
            }
            searchPlaceholder = (dict["searchPlaceholder"] as? String) ?? "Search"
            searchSymbol = (dict["searchSymbol"] as? String) ?? "magnifyingglass"
        }

        // Parse automaticallyActivatesSearch
        let automaticallyActivatesSearch = ((args as? [String: Any])?["automaticallyActivatesSearch"] as? NSNumber)?.boolValue ?? true

        // Parse search style configuration
        let searchStyleDict = (args as? [String: Any])?["searchStyle"] as? [String: Any]
        let searchStyleConfig = SearchStyleConfig.from(dict: searchStyleDict)

        // Build tab items
        var items: [TabItemData] = []
        let count = max(labels.count, symbols.count)
        for i in 0..<count {
            let label = i < labels.count ? labels[i] : ""
            let symbol = i < symbols.count ? symbols[i] : "circle"
            let activeSymbol = i < activeSymbols.count && !activeSymbols[i].isEmpty ? activeSymbols[i] : symbol
            items.append(TabItemData(
                index: i,
                label: label,
                symbol: symbol,
                activeSymbol: activeSymbol
            ))
        }

        // Configure view model
        viewModel.items = items
        viewModel.selectedIndex = selectedIndex
        viewModel.searchPlaceholder = searchPlaceholder
        viewModel.searchSymbol = searchSymbol
        viewModel.tintColor = tint != nil ? Color(tint!) : .accentColor
        viewModel.style = searchStyleConfig
        viewModel.automaticallyActivatesSearch = automaticallyActivatesSearch

        super.init()

        container.backgroundColor = .clear
        if #available(iOS 13.0, *) {
            container.overrideUserInterfaceStyle = isDark ? .dark : .light
        }

        // Set up callbacks
        viewModel.onTabSelected = { [weak self] index in
            self?.channel.invokeMethod("valueChanged", arguments: ["index": index])
        }

        viewModel.onSearchTextChanged = { [weak self] text in
            self?.channel.invokeMethod("searchTextChanged", arguments: ["text": text])
        }

        viewModel.onSearchActiveChanged = { [weak self] isActive in
            self?.channel.invokeMethod("searchActiveChanged", arguments: ["isActive": isActive])
        }

        viewModel.onSearchSubmitted = { [weak self] text in
            self?.channel.invokeMethod("searchSubmitted", arguments: ["text": text])
        }

        // Create SwiftUI view with animated search
        let contentView = AnimatedSearchTabBar(viewModel: viewModel)
        let hosting = UIHostingController(rootView: AnyView(contentView))
        hosting.view.backgroundColor = .clear
        hosting.view.frame = container.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(hosting.view)
        self.hostingController = hosting

        // Set up method channel handler
        channel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { result(nil); return }

            switch call.method {
            case "getIntrinsicSize":
                result(["width": Double(self.container.bounds.width), "height": 50.0])

            case "setSelectedIndex":
                if let args = call.arguments as? [String: Any],
                   let idx = (args["index"] as? NSNumber)?.intValue {
                    self.viewModel.selectedIndex = idx
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing index", details: nil))
                }

            case "activateSearch":
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.viewModel.isSearchActive = true
                }
                result(nil)

            case "deactivateSearch":
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    self.viewModel.isSearchActive = false
                }
                result(nil)

            case "setSearchText":
                if let args = call.arguments as? [String: Any],
                   let text = args["text"] as? String {
                    self.viewModel.searchText = text
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing text", details: nil))
                }

            case "setBrightness":
                if let args = call.arguments as? [String: Any],
                   let isDark = (args["isDark"] as? NSNumber)?.boolValue {
                    if #available(iOS 13.0, *) {
                        self.container.overrideUserInterfaceStyle = isDark ? .dark : .light
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing isDark", details: nil))
                }

            case "setStyle":
                if let args = call.arguments as? [String: Any] {
                    if let n = args["tint"] as? NSNumber {
                        let color = ImageUtils.colorFromARGB(n.intValue)
                        self.viewModel.tintColor = Color(color)
                    }
                    result(nil)
                } else {
                    result(FlutterError(code: "bad_args", message: "Missing style", details: nil))
                }

            case "refresh":
                // Handle refresh - update view if needed
                result(nil)

            case "setLabels":
                // Handle label updates
                if let args = call.arguments as? [String: Any],
                   let labels = args["labels"] as? [String] {
                    for (index, label) in labels.enumerated() {
                        if index < self.viewModel.items.count {
                            // Update label (items are immutable, would need to recreate)
                        }
                    }
                }
                result(nil)

            case "setSfSymbols":
                // Handle symbol updates
                result(nil)

            case "setBadges":
                // Handle badge updates
                result(nil)

            case "setItems":
                // Handle full items update (when icons/labels change)
                if let args = call.arguments as? [String: Any] {
                    let labels = (args["labels"] as? [String]) ?? []
                    let symbols = (args["sfSymbols"] as? [String]) ?? []
                    let activeSymbols = (args["activeSfSymbols"] as? [String]) ?? []

                    var newItems: [TabItemData] = []
                    let count = max(labels.count, symbols.count)
                    for i in 0..<count {
                        let label = i < labels.count ? labels[i] : ""
                        let symbol = i < symbols.count ? symbols[i] : "circle"
                        let activeSymbol = i < activeSymbols.count && !activeSymbols[i].isEmpty ? activeSymbols[i] : symbol
                        newItems.append(TabItemData(
                            index: i,
                            label: label,
                            symbol: symbol,
                            activeSymbol: activeSymbol
                        ))
                    }
                    self.viewModel.items = newItems

                    if let idx = (args["selectedIndex"] as? NSNumber)?.intValue {
                        self.viewModel.selectedIndex = idx
                    }
                }
                result(nil)

            case "setLayout":
                // Handle layout changes (split mode, spacing, etc.)
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        return container
    }
}

// MARK: - Data Models

@available(iOS 26.0, *)
struct TabItemData: Identifiable {
    let id = UUID()
    let index: Int
    let label: String
    let symbol: String
    let activeSymbol: String
}

/// Style configuration for the search tab bar
@available(iOS 26.0, *)
struct SearchStyleConfig {
    // Icon styling
    var iconSize: CGFloat = 20
    var iconColor: Color? = nil
    var activeIconColor: Color? = nil

    // Search bar styling
    var searchBarBackgroundColor: Color? = nil
    var searchBarTextColor: Color? = nil
    var searchBarPlaceholderColor: Color? = nil
    var clearButtonColor: Color? = nil

    // Size configurations
    var buttonSize: CGFloat = 44
    var searchBarHeight: CGFloat = 44
    var searchBarBorderRadius: CGFloat? = nil // nil = capsule

    // Padding configurations
    var searchBarPaddingHorizontal: CGFloat = 12
    var searchBarPaddingVertical: CGFloat = 10
    var contentPaddingHorizontal: CGFloat = 16
    var contentPaddingVertical: CGFloat = 8
    var spacing: CGFloat = 12

    // Animation
    var animationDuration: Double = 0.4

    // Features
    var showClearButton: Bool = true
    var collapsedTabIcon: String? = nil

    /// Parse from Flutter dictionary
    static func from(dict: [String: Any]?) -> SearchStyleConfig {
        var config = SearchStyleConfig()
        guard let dict = dict else { return config }

        if let v = dict["iconSize"] as? NSNumber { config.iconSize = CGFloat(v.doubleValue) }
        if let v = dict["iconColor"] as? NSNumber { config.iconColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["activeIconColor"] as? NSNumber { config.activeIconColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["searchBarBackgroundColor"] as? NSNumber { config.searchBarBackgroundColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["searchBarTextColor"] as? NSNumber { config.searchBarTextColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["searchBarPlaceholderColor"] as? NSNumber { config.searchBarPlaceholderColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["clearButtonColor"] as? NSNumber { config.clearButtonColor = Color(ImageUtils.colorFromARGB(v.intValue)) }
        if let v = dict["buttonSize"] as? NSNumber { config.buttonSize = CGFloat(v.doubleValue) }
        if let v = dict["searchBarHeight"] as? NSNumber { config.searchBarHeight = CGFloat(v.doubleValue) }
        if let v = dict["searchBarBorderRadius"] as? NSNumber { config.searchBarBorderRadius = CGFloat(v.doubleValue) }
        if let v = dict["searchBarPaddingLeft"] as? NSNumber, let r = dict["searchBarPaddingRight"] as? NSNumber {
            config.searchBarPaddingHorizontal = (CGFloat(v.doubleValue) + CGFloat(r.doubleValue)) / 2
        }
        if let v = dict["searchBarPaddingTop"] as? NSNumber, let b = dict["searchBarPaddingBottom"] as? NSNumber {
            config.searchBarPaddingVertical = (CGFloat(v.doubleValue) + CGFloat(b.doubleValue)) / 2
        }
        if let v = dict["contentPaddingLeft"] as? NSNumber, let r = dict["contentPaddingRight"] as? NSNumber {
            config.contentPaddingHorizontal = (CGFloat(v.doubleValue) + CGFloat(r.doubleValue)) / 2
        }
        if let v = dict["contentPaddingTop"] as? NSNumber, let b = dict["contentPaddingBottom"] as? NSNumber {
            config.contentPaddingVertical = (CGFloat(v.doubleValue) + CGFloat(b.doubleValue)) / 2
        }
        if let v = dict["spacing"] as? NSNumber { config.spacing = CGFloat(v.doubleValue) }
        if let v = dict["animationDuration"] as? NSNumber { config.animationDuration = v.doubleValue / 1000.0 }
        if let v = dict["showClearButton"] as? NSNumber { config.showClearButton = v.boolValue }
        if let v = dict["collapsedTabIcon"] as? String { config.collapsedTabIcon = v }

        return config
    }
}

// MARK: - View Model

@available(iOS 26.0, *)
class TabBarSearchViewModel: ObservableObject {
    @Published var items: [TabItemData] = []
    @Published var selectedIndex: Int = 0
    @Published var searchText: String = ""
    @Published var isSearchActive: Bool = false
    @Published var tintColor: Color = .accentColor
    @Published var style: SearchStyleConfig = SearchStyleConfig()

    var searchPlaceholder: String = "Search"
    var searchSymbol: String = "magnifyingglass"
    var automaticallyActivatesSearch: Bool = true

    var onTabSelected: ((Int) -> Void)?
    var onSearchTextChanged: ((String) -> Void)?
    var onSearchActiveChanged: ((Bool) -> Void)?
    var onSearchSubmitted: ((String) -> Void)?
}

// MARK: - Animated Search Tab Bar View

@available(iOS 26.0, *)
struct AnimatedSearchTabBar: View {
    @ObservedObject var viewModel: TabBarSearchViewModel
    @FocusState private var isSearchFocused: Bool
    /// When automaticallyActivatesSearch is false, we show a fake text field first
    /// and only show the real one when user explicitly taps on it
    @State private var showRealTextField: Bool = false

    private var style: SearchStyleConfig { viewModel.style }

    // Computed colors with fallbacks
    private var iconColor: Color { style.iconColor ?? .secondary }
    private var activeIconColor: Color { style.activeIconColor ?? viewModel.tintColor }
    private var searchBarTextColor: Color { style.searchBarTextColor ?? .primary }
    private var placeholderColor: Color { style.searchBarPlaceholderColor ?? .secondary }
    private var clearButtonColor: Color { style.clearButtonColor ?? .secondary }

    // Collapsed tab icon (customizable)
    private var collapsedIcon: String {
        style.collapsedTabIcon ?? viewModel.items.first?.symbol ?? "square.grid.2x2"
    }

    var body: some View {
        HStack(spacing: style.spacing) {
            // Left side: Tab items (collapse when search is active)
            if !viewModel.isSearchActive {
                // Regular tabs with glass effect
                HStack(spacing: 0) {
                    ForEach(viewModel.items) { item in
                        TabButton(
                            item: item,
                            isSelected: viewModel.selectedIndex == item.index,
                            tintColor: viewModel.tintColor,
                            iconSize: style.iconSize
                        ) {
                            viewModel.selectedIndex = item.index
                            viewModel.onTabSelected?(item.index)
                        }
                    }
                }
                .glassEffect(.regular)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.8).combined(with: .opacity),
                    removal: .scale(scale: 0.8).combined(with: .opacity)
                ))
            } else {
                // Collapsed tab indicator when search is active
                Button(action: {
                    withAnimation(.spring(response: style.animationDuration, dampingFraction: 0.8)) {
                        viewModel.isSearchActive = false
                        viewModel.onSearchActiveChanged?(false)
                    }
                    isSearchFocused = false
                }) {
                    Image(systemName: collapsedIcon)
                        .font(.system(size: style.iconSize, weight: .medium))
                        .foregroundStyle(activeIconColor)
                        .frame(width: style.buttonSize, height: style.buttonSize)
                }
                .glassEffect(.regular)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity),
                    removal: .scale(scale: 0.5).combined(with: .opacity)
                ))
            }

            Spacer(minLength: 0)

            // Right side: Search button or expanded search bar
            if viewModel.isSearchActive {
                // Expanded search bar
                HStack(spacing: 8) {
                    Image(systemName: viewModel.searchSymbol)
                        .foregroundStyle(placeholderColor)
                        .font(.system(size: style.iconSize * 0.8, weight: .medium))

                    // Show real TextField OR fake placeholder based on settings
                    if viewModel.automaticallyActivatesSearch || showRealTextField {
                        // Real TextField - shows immediately if auto-activate, or after user taps
                        TextField(viewModel.searchPlaceholder, text: Binding(
                            get: { viewModel.searchText },
                            set: { newValue in
                                viewModel.searchText = newValue
                                viewModel.onSearchTextChanged?(newValue)
                            }
                        ))
                        .textFieldStyle(.plain)
                        .foregroundStyle(searchBarTextColor)
                        .focused($isSearchFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            viewModel.onSearchSubmitted?(viewModel.searchText)
                        }
                        .onAppear {
                            // Auto-focus only if automaticallyActivatesSearch is true
                            // OR if user explicitly tapped to show the real TextField
                            if viewModel.automaticallyActivatesSearch {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    isSearchFocused = true
                                }
                            } else if showRealTextField {
                                // User tapped the fake field, now focus the real one
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    isSearchFocused = true
                                }
                            }
                        }
                    } else {
                        // Fake TextField placeholder - tapping this activates the real TextField
                        Button(action: {
                            showRealTextField = true
                        }) {
                            Text(viewModel.searchPlaceholder)
                                .foregroundStyle(placeholderColor)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }

                    if style.showClearButton && !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.searchText = ""
                            viewModel.onSearchTextChanged?("")
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(clearButtonColor)
                                .font(.system(size: style.iconSize * 0.8))
                        }
                    }
                }
                .padding(.horizontal, style.searchBarPaddingHorizontal)
                .padding(.vertical, style.searchBarPaddingVertical)
                .frame(height: style.searchBarHeight)
                .glassEffect(.regular)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.3, anchor: .trailing).combined(with: .opacity),
                    removal: .scale(scale: 0.3, anchor: .trailing).combined(with: .opacity)
                ))
            } else {
                // Collapsed search button
                Button(action: {
                    withAnimation(.spring(response: style.animationDuration, dampingFraction: 0.8)) {
                        viewModel.isSearchActive = true
                        viewModel.onSearchActiveChanged?(true)
                    }
                    // Note: Focus is now handled in the TextField's .onAppear
                    // based on automaticallyActivatesSearch and showRealTextField states
                }) {
                    Image(systemName: viewModel.searchSymbol)
                        .font(.system(size: style.iconSize, weight: .medium))
                        .foregroundStyle(iconColor)
                        .frame(width: style.buttonSize, height: style.buttonSize)
                }
                .glassEffect(.regular)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.5).combined(with: .opacity),
                    removal: .scale(scale: 0.5).combined(with: .opacity)
                ))
            }
        }
        .padding(.horizontal, style.contentPaddingHorizontal)
        .padding(.vertical, style.contentPaddingVertical)
        .animation(.spring(response: style.animationDuration, dampingFraction: 0.8), value: viewModel.isSearchActive)
        .onChange(of: viewModel.isSearchActive) { oldValue, newValue in
            if !newValue {
                // Reset all state when search is closed
                isSearchFocused = false
                showRealTextField = false
            }
        }
    }
}

// MARK: - Tab Button

@available(iOS 26.0, *)
struct TabButton: View {
    let item: TabItemData
    let isSelected: Bool
    let tintColor: Color
    var iconSize: CGFloat = 20
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? item.activeSymbol : item.symbol)
                    .font(.system(size: iconSize, weight: isSelected ? .semibold : .regular))
                    .symbolRenderingMode(.hierarchical)

                if !item.label.isEmpty {
                    Text(item.label)
                        .font(.system(size: iconSize * 0.5, weight: isSelected ? .semibold : .regular))
                }
            }
            .foregroundStyle(isSelected ? tintColor : .secondary)
            .frame(minWidth: iconSize * 3.2)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
