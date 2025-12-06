// main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const CrimsonM3DemoApp());
}

class CrimsonM3DemoApp extends StatefulWidget {
  const CrimsonM3DemoApp({Key? key}) : super(key: key);

  @override
  State<CrimsonM3DemoApp> createState() => _CrimsonM3DemoAppState();
}

class _CrimsonM3DemoAppState extends State<CrimsonM3DemoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  // Colors based on mockup
  static const Color lightPrimary = Color(0xFFCC3333);
  static const Color lightPrimaryContainer = Color(0xFFFDE0E6);
  static const Color lightSecondary = Color(0xFF800000);
  static const Color lightTertiary = Color(0xFF8A2BE2);

  static const Color darkPrimary = Color(0xFFFFB3B3);
  static const Color darkPrimaryContainer = Color(0xFF990000);
  static const Color darkBackground = Color(0xFF1C1B1F);

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: Color(0xFF800000),
        secondary: lightSecondary,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Color(0xFF1F2937),
        error: Color(0xFFB3261E),
        onError: Colors.white,
        tertiary: lightTertiary,
        onTertiary: Colors.white,
        outline: Color(0xFFD1D5DB),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    final dark = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: Color(0xFF660000),
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: Color(0xFFFFDADA),
        secondary: Color(0xFFFFDADA),
        onSecondary: Color(0xFF400000),
        background: darkBackground,
        onBackground: Color(0xFFE6E1E5),
        surface: darkBackground,
        onSurface: Color(0xFFE6E1E5),
        error: Color(0xFFFFB4AB),
        onError: Colors.black,
        tertiary: Color(0xFFCFBCFF),
        onTertiary: Color(0xFF3E247D),
        outline: Color(0xFF8E9094),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'PlayfairDisplay',
          fontSize: 36,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return MaterialApp(
      title: 'Crimson Romance M3',
      theme: light,
      darkTheme: dark,
      themeMode: _themeMode,
      home: HomePage(themeMode: _themeMode, toggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;
  const HomePage({Key? key, required this.themeMode, required this.toggleTheme})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _bottomSheetShown = false;
  int _selectedBottomNavIndex = 0;
  int _selectedSegment = 0;
  int _selectedTab = 0;

  // Time picker simulation
  int currentHour = 10;
  bool isAM = true;

  void _changeHour(int delta) {
    setState(() {
      currentHour += delta;
      if (currentHour > 12) currentHour = 1;
      if (currentHour < 1) currentHour = 12;
    });
  }

  void _toggleAmPm() {
    setState(() {
      isAM = !isAM;
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác Nhận Thay Đổi'),
        content: const Text(
          'Bạn có chắc chắn muốn lưu các thay đổi này không? Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Xác Nhận'),
          ),
        ],
      ),
    );
  }

  void _toggleBottomSheet() {
    if (_bottomSheetShown) {
      Navigator.of(context).pop();
      setState(() => _bottomSheetShown = false);
    } else {
      setState(() => _bottomSheetShown = true);
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tùy Chọn Khác',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Đây là nơi bạn có thể đặt các hành động phụ hoặc thông tin bổ sung.',
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Chia Sẻ'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.flag),
                label: const Text('Báo Cáo'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Xóa Mục Này',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ).whenComplete(() {
        setState(() => _bottomSheetShown = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Navigation',
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: cs.primary),
                ),
                const SizedBox(height: 16),
                const DrawerItem(
                  icon: Icons.home,
                  label: 'Trang Chủ',
                  selected: true,
                ),
                const DrawerItem(icon: Icons.collections, label: 'Bộ Sưu Tập'),
                const DrawerItem(icon: Icons.person, label: 'Hồ Sơ Cá Nhân'),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Row(
          children: [
            // Optional navigation rail for wide screens
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return NavigationRail(
                    extended: false,
                    selectedIndex: 0,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.collections),
                        label: Text('Library'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings),
                        label: Text('Settings'),
                      ),
                    ],
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Theme.of(context).colorScheme.surfaceVariant,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Crimson Romance M3 System',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(color: cs.primary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Trưng bày tất cả thành phần UI Material 3 - 14 Mục - Light & Dark Theme',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: cs.secondary),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: [
                              FilledButton(
                                onPressed: widget.toggleTheme,
                                child: Text(
                                  widget.themeMode == ThemeMode.light
                                      ? '🌙 Chế độ Tối'
                                      : '🌞 Chế độ Sáng',
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () =>
                                    _scaffoldKey.currentState?.openDrawer(),
                                child: const Text('Mở Drawer (Ngăn Kéo)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Colors & Typography
                    Section(
                      title: 'Bảng Màu & Typography (Tham Khảo)',
                      child: Wrap(
                        runSpacing: 12,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Vai trò Màu Sắc M3',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Primary / On Primary: #CC3333 / #FFFFFF',
                                  ),
                                  const Text(
                                    'Secondary / On Secondary: #800000 / #FFFFFF',
                                  ),
                                  const Text(
                                    'Tertiary / On Tertiary: #8A2BE2 / #FFFFFF',
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Typography M3',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Display Large (Playfair)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineLarge,
                                  ),
                                  Text(
                                    'Headline Medium (Inter - 700)',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 1. Buttons
                    Section(
                      title: '1. Nút Bấm (Buttons)',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Filled Button'),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Elevated Button'),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Outlined Button'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Text Button'),
                          ),
                          // FAB
                          FloatingActionButton.small(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                          ),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.add),
                            label: const Text('Tạo Mẫu Mới'),
                          ),
                        ],
                      ),
                    ),

                    // 2. Chips & Badge
                    Section(
                      title: '2. Chip & Huy Hiệu (Badge)',
                      child: Wrap(
                        spacing: 12,
                        children: [
                          FilterChip(
                            label: const Text('Filter Chip (Selected)'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          ActionChip(
                            label: const Text('Assist Chip'),
                            onPressed: () {},
                          ),
                          InputChip(
                            label: const Text('Input Chip'),
                            onDeleted: () {},
                            onPressed: () {},
                          ),
                          Stack(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.mail, size: 28),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    '99+',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 3. Text Fields & Controls
                    Section(
                      title: '3. Thanh Nhập Liệu & Điều Khiển',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Text Fields',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                const TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Outlined (Mặc định)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Mô phỏng Filled',
                                    filled: true,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Văn bản trợ giúp/lỗi.',
                                  style: TextStyle(color: cs.secondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Selection Controls',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Checkbox(value: true, onChanged: (_) {}),
                                    const Text('Checkbox'),
                                    const SizedBox(width: 12),
                                    Radio<int>(
                                      value: 1,
                                      groupValue: 1,
                                      onChanged: (_) {},
                                    ),
                                    const Text('Radio'),
                                    const SizedBox(width: 12),
                                    Switch(value: true, onChanged: (_) {}),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Slider (Thanh Trượt)',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                Slider(
                                  value: 75,
                                  min: 0,
                                  max: 100,
                                  onChanged: (v) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 4. Cards
                    Section(
                      title: '4. Cards (Thẻ)',
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tùy chọn Khung ảnh',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.secondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Dùng cho các mục có thể chọn hoặc tùy chỉnh.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            elevation: 4,
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sản phẩm nổi bật',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Card này sử dụng màu Surface Container High.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Thông báo Gần đây',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: cs.tertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Card này sử dụng màu Surface Container Low, ít nổi bật hơn.',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 5. Navigation Bar & App Bar
                    Section(
                      title: '5. Navigation Bar & App Bar',
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                top: BorderSide(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  width: 4,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimaryContainer,
                                    ),
                                    Text(
                                      'Trang Chủ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                const Column(
                                  children: [
                                    Icon(Icons.library_books),
                                    Text(
                                      'Thư Viện',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                const Column(
                                  children: [
                                    Icon(Icons.settings),
                                    Text(
                                      'Cài Đặt',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Bottom App Bar simulated
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _scaffoldKey.currentState
                                          ?.openDrawer(),
                                      icon: Icon(Icons.menu, color: cs.primary),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Icons.chat_bubble),
                                    ),
                                  ],
                                ),
                                FloatingActionButton.small(
                                  onPressed: () {},
                                  backgroundColor: cs.secondary,
                                  child: const Icon(Icons.add),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 6. Segmented Buttons & Tabs
                    Section(
                      title: '6. Nút Phân Đoạn & Thanh Tab',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              ToggleButtons(
                                isSelected: List.generate(
                                  3,
                                      (i) => i == _selectedSegment,
                                ),
                                onPressed: (index) =>
                                    setState(() => _selectedSegment = index),
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8,
                                    ),
                                    child: Icon(Icons.notifications),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8,
                                    ),
                                    child: Icon(Icons.people),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 8,
                                    ),
                                    child: Icon(Icons.settings),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Mua Hàng'),
                                selected: _selectedTab == 0,
                                onSelected: (_) =>
                                    setState(() => _selectedTab = 0),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Đã Xem'),
                                selected: _selectedTab == 1,
                                onSelected: (_) =>
                                    setState(() => _selectedTab = 1),
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('Ưa Thích'),
                                selected: _selectedTab == 2,
                                onSelected: (_) =>
                                    setState(() => _selectedTab = 2),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 7. Progress Indicators
                    Section(
                      title: '7. Progress Indicators (Tiến Trình)',
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Linear Progress (65%)'),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: 0.65,
                                  color: cs.primary,
                                  backgroundColor: cs.primaryContainer,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            children: [
                              Text('Circular Progress'),
                              SizedBox(height: 6),
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Indeterminate (Chờ)'),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(color: cs.primary),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 8. Complex Inputs & Pickers (Date + Dropdown)
                    Section(
                      title: '8. Complex Inputs & Pickers',
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Date Picker (Mô phỏng Lịch)'),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tháng 12, 2025',
                                            style: TextStyle(color: cs.primary),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.chevron_left,
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {},
                                                icon: const Icon(
                                                  Icons.chevron_right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GridView.count(
                                        crossAxisCount: 7,
                                        shrinkWrap: true,
                                        childAspectRatio: 1.6,
                                        physics:
                                        const NeverScrollableScrollPhysics(),
                                        children: List.generate(35, (i) {
                                          final day =
                                              i - 1; // rough placeholder
                                          final isSelected = (i == 16);
                                          return Center(
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: isSelected
                                                  ? BoxDecoration(
                                                color:
                                                cs.primaryContainer,
                                                shape: BoxShape.circle,
                                              )
                                                  : null,
                                              child: Text(
                                                '${(i <= 0) ? '' : (i <= 31 ? i : '')}',
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? cs.onPrimaryContainer
                                                      : null,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Dropdown/Menu (Mô phỏng)'),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  items: const [
                                    DropdownMenuItem(
                                      value: '1',
                                      child: Text('Tùy Chọn 1'),
                                    ),
                                    DropdownMenuItem(
                                      value: '2',
                                      child: Text('Tùy Chọn 2'),
                                    ),
                                    DropdownMenuItem(
                                      value: '3',
                                      child: Text('Tùy Chọn 3'),
                                    ),
                                  ],
                                  onChanged: (_) {},
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 9. Navigation Overlays
                    Section(
                      title: '9. Navigation Overlays',
                      child: Wrap(
                        spacing: 12,
                        children: [
                          FilledButton(
                            onPressed: () =>
                                _scaffoldKey.currentState?.openDrawer(),
                            child: const Text('Mở Drawer (Ngăn Kéo Bên)'),
                          ),
                          FilledButton(
                            onPressed: _toggleBottomSheet,
                            child: const Text('Mở Bottom Sheet'),
                          ),
                        ],
                      ),
                    ),

                    // 10. Dialogs & Feedback
                    Section(
                      title: '10. Dialogs & Feedback',
                      child: Wrap(
                        spacing: 12,
                        children: [
                          FilledButton(
                            onPressed: _showConfirmationDialog,
                            child: const Text('Mở Dialog (Xác Nhận)'),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.error, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lỗi: Không thể kết nối máy chủ.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSurface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Đã lưu tệp thành công!',
                                  style: TextStyle(color: Colors.black),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'HOÀN TÁC',
                                    style: TextStyle(color: cs.primary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 11. Data Table
                    Section(
                      title: '11. Data Table (Bảng Dữ Liệu)',
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Tên Sản Phẩm')),
                            DataColumn(label: Text('Số Lượng')),
                            DataColumn(label: Text('Giá (VND)')),
                            DataColumn(label: Text('Trạng Thái')),
                          ],
                          rows: [
                            DataRow(
                              cells: [
                                const DataCell(Text('Áo Sơ Mi Cotton')),
                                const DataCell(Text('12')),
                                const DataCell(Text('350,000')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Đã bán',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(Text('Quần Jeans Slim')),
                                const DataCell(Text('5')),
                                const DataCell(Text('680,000')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Tồn kho ít',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            DataRow(
                              cells: [
                                const DataCell(Text('Váy Hoa Nhí')),
                                const DataCell(Text('25')),
                                const DataCell(Text('420,000')),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Đang về',
                                      style: TextStyle(color: cs.onPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 12. Navigation Rail note (already shown conditionally)

                    // 13. List items (example)
                    Section(
                      title: '13. List Items',
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Icon(
                                Icons.album,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            title: const Text('Danh Mục Một Dòng'),
                            subtitle: const Text('Dòng phụ'),
                          ),
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Icon(
                                Icons.star,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            title: const Text('Danh Mục Ba Dòng Rất Dài'),
                            subtitle: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dòng phụ đầu tiên.'),
                                Text(
                                  'Một dòng phụ thứ hai cung cấp ngữ cảnh đầy đủ.',
                                ),
                              ],
                            ),
                            trailing: Switch(value: true, onChanged: (_) {}),
                          ),
                        ],
                      ),
                    ),

                    // 14. Simulated Time Picker
                    Section(
                      title: '14. Simulated Time Picker (Bộ Chọn Thời Gian)',
                      child: Row(
                        children: [
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: cs.primary,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () => _changeHour(-1),
                                        icon: const Icon(
                                          Icons.chevron_left,
                                          color: Colors.white,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Text(
                                          currentHour.toString().padLeft(
                                            2,
                                            '0',
                                          ),
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        onTap: () {},
                                      ),
                                      IconButton(
                                        onPressed: () => _changeHour(1),
                                        icon: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: _toggleAmPm,
                                            child: Text(
                                              isAM ? 'SA' : 'CH',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const Text(
                                            '00',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Clock face
                                SizedBox(
                                  height: 180,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 150,
                                        height: 150,
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surface,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.outline,
                                          ),
                                        ),
                                      ),
                                      Transform.rotate(
                                        angle:
                                        ((currentHour % 12) * 30 +
                                            (isAM ? 0 : 180) -
                                            90) *
                                            math.pi /
                                            180,
                                        child: Container(
                                          width: 2,
                                          height: 60,
                                          color: cs.primary,
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        child: Text(
                                          '12',
                                          style: TextStyle(
                                            color: cs.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        child: Text(
                                          '6',
                                          style: TextStyle(color: cs.onSurface),
                                        ),
                                      ),
                                      Positioned(
                                        right: 16,
                                        child: Text(
                                          '3',
                                          style: TextStyle(color: cs.onSurface),
                                        ),
                                      ),
                                      Positioned(
                                        left: 16,
                                        child: Text(
                                          '9',
                                          style: TextStyle(color: cs.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'Hủy',
                                        style: TextStyle(color: cs.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton(
                                      onPressed: () {},
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Hệ thống Material 3 Showcase: Phiên bản mở rộng (14 mục).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedBottomNavIndex,
        onTap: (i) => setState(() => _selectedBottomNavIndex = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang Chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Thư Viện',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài Đặt',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Section extends StatelessWidget {
  final String title;
  final Widget child;
  const Section({Key? key, required this.title, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.secondary),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  const DrawerItem({
    Key? key,
    required this.icon,
    required this.label,
    this.selected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer : null,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Icon(icon, color: selected ? cs.onPrimaryContainer : null),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? cs.onPrimaryContainer : null,
            ),
          ),
        ],
      ),
    );
  }
}
