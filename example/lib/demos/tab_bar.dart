import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TabController, TabBarView, Colors;
import 'package:cupertino_native_better/cupertino_native_better.dart';

class TabBarDemoPage extends StatefulWidget {
  const TabBarDemoPage({super.key});

  @override
  State<TabBarDemoPage> createState() => _TabBarDemoPageState();
}

class _TabBarDemoPageState extends State<TabBarDemoPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _index = 0;
  bool _useAlternateIcons = false;
  bool _useSearchMode = true; // Toggle between regular and search mode

  // Search state
  String _searchQuery = '';
  bool _isSearchActive = false;
  final CNTabBarSearchController _searchController = CNTabBarSearchController();

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
    _controller.addListener(() {
      final i = _controller.index;
      if (i != _index) setState(() => _index = i);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Native Tab Bar'),
      ),
      child: Stack(
        children: [
          // Content below
          Positioned.fill(
            child: _isSearchActive
                ? _buildSearchResults()
                : TabBarView(
                    controller: _controller,
                    children: const [
                      _ImageTabPage(asset: 'assets/home.jpg', label: 'Home'),
                      _ImageTabPage(
                        asset: 'assets/profile.jpg',
                        label: 'Profile',
                      ),
                      _ImageTabPage(
                        asset: 'assets/settings.jpg',
                        label: 'Settings',
                      ),
                    ],
                  ),
          ),
          // Native tab bar overlay with search
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 8,
            child: _useSearchMode
                ? CNTabBar(
                    items: [
                      CNTabBarItem(
                        label: 'Overview',
                        icon: CNSymbol('square.grid.2x2.fill'),
                        activeIcon: CNSymbol('square.grid.2x2.fill'),
                      ),
                      CNTabBarItem(
                        label: 'Projects',
                        icon: CNSymbol('folder'),
                        activeIcon: CNSymbol('folder.fill'),
                      ),
                    ],
                    currentIndex: _index,
                    onTap: (i) {
                      setState(() => _index = i);
                      _controller.animateTo(i);
                    },
                    // iOS 26 Search Tab Feature with full customization
                    searchItem: CNTabBarSearchItem(
                      placeholder: 'Find customer',
                      // Disable automatic keyboard - search expands but keyboard doesn't open
                      automaticallyActivatesSearch: false,
                      onSearchChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                      onSearchSubmit: (query) {
                        // Handle search submit
                        debugPrint('Search submitted: $query');
                      },
                      onSearchActiveChanged: (isActive) {
                        setState(() => _isSearchActive = isActive);
                      },
                      // Fully customizable style options
                      style: const CNTabBarSearchStyle(
                        iconSize: 20,
                        buttonSize: 44,
                        searchBarHeight: 44,
                        spacing: 12,
                        searchBarPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        animationDuration: Duration(milliseconds: 400),
                        showClearButton: true,
                        // Custom colors (uncomment to customize):
                        // iconColor: CupertinoColors.systemGrey,
                        // activeIconColor: CupertinoColors.systemBlue,
                        // searchBarTextColor: CupertinoColors.black,
                        // searchBarPlaceholderColor: CupertinoColors.systemGrey2,
                        // clearButtonColor: CupertinoColors.systemGrey,
                      ),
                    ),
                    searchController: _searchController,
                  )
                : CNTabBar(
                    items: _useAlternateIcons
                        ? [
                            // Alternate SVG icons to test setState
                            CNTabBarItem(
                              label: 'Home',
                              imageAsset: CNImageAsset(
                                'assets/icons/profile.svg',
                              ),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/profile-filled.svg',
                              ),
                              badge: '5',
                            ),
                            CNTabBarItem(
                              label: 'Search',
                              imageAsset: CNImageAsset('assets/icons/chat.svg'),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/chat-filled.svg',
                              ),
                              badge: '8',
                            ),
                            CNTabBarItem(
                              label: 'Profile',
                              imageAsset: CNImageAsset('assets/icons/home.svg'),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/home_filled.svg',
                              ),
                            ),
                          ]
                        : [
                            // Original SVG icons
                            CNTabBarItem(
                              label: 'Home',
                              imageAsset: CNImageAsset('assets/icons/home.svg'),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/home_filled.svg',
                              ),
                              badge: '3',
                            ),
                            CNTabBarItem(
                              label: 'Search',
                              imageAsset: CNImageAsset(
                                'assets/icons/search.svg',
                              ),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/search-filled.svg',
                              ),
                              badge: '12',
                            ),
                            CNTabBarItem(
                              label: 'Profile',
                              imageAsset: CNImageAsset(
                                'assets/icons/profile.svg',
                              ),
                              activeImageAsset: CNImageAsset(
                                'assets/icons/profile-filled.svg',
                              ),
                            ),
                          ],
                    currentIndex: _index,
                    split: true,
                    rightCount: 1,
                    splitSpacing: 8,
                    shrinkCentered: true,
                    tint: Colors.red,
                    onTap: (i) {
                      setState(() => _index = i);
                      _controller.animateTo(i);
                    },
                  ),
          ),
          // Toggle buttons
          Positioned(
            top: 100,
            right: 20,
            child: Column(
              children: [
                // Toggle search mode
                CupertinoButton(
                  onPressed: () {
                    setState(() {
                      _useSearchMode = !_useSearchMode;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _useSearchMode
                          ? CupertinoColors.systemGreen.withValues(alpha: 0.8)
                          : CupertinoColors.inactiveGray.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      _useSearchMode
                          ? CupertinoIcons.search
                          : CupertinoIcons.search_circle,
                      color: CupertinoColors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Toggle icons (only when not in search mode)
                if (!_useSearchMode)
                  CupertinoButton(
                    onPressed: () {
                      setState(() {
                        _useAlternateIcons = !_useAlternateIcons;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBlue.withValues(
                          alpha: 0.8,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        _useAlternateIcons
                            ? CupertinoIcons.refresh
                            : CupertinoIcons.arrow_2_squarepath,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Search query indicator (when search is active)
          if (_isSearchActive && _searchQuery.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Searching: $_searchQuery',
                  style: TextStyle(color: CupertinoColors.white, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Mock search results UI
    final mockResults =
        [
              'Customer: John Doe',
              'Customer: Jane Smith',
              'Customer: Bob Johnson',
              'Customer: Alice Williams',
              'Customer: Charlie Brown',
            ]
            .where(
              (item) => item.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Container(
      color: CupertinoColors.systemBackground,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _searchQuery.isEmpty
                    ? 'Start typing to search...'
                    : 'Results for "$_searchQuery"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                      child: Icon(
                        CupertinoIcons.search,
                        size: 64,
                        color: CupertinoColors.inactiveGray,
                      ),
                    )
                  : ListView.builder(
                      itemCount: mockResults.length,
                      itemBuilder: (context, index) {
                        return CupertinoListTile(
                          title: Text(mockResults[index]),
                          leading: const Icon(CupertinoIcons.person),
                          trailing: const Icon(CupertinoIcons.chevron_forward),
                          onTap: () {
                            debugPrint('Selected: ${mockResults[index]}');
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTabPage extends StatelessWidget {
  const _ImageTabPage({required this.asset, required this.label});
  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(asset, fit: BoxFit.cover),
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoColors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 12),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
