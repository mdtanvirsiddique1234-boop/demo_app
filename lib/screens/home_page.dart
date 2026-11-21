import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'food_log_page.dart';

class PushtiBondhuApp extends StatelessWidget {
  const PushtiBondhuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pushti Bondhu',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.bg,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
      ),
      home: const HomePage(),
    );
  }
}

class AppColors {
  static const green = Color(0xFF2E7D32);
  static const darkGreen = Color(0xFF123D2B);
  static const lightGreen = Color(0xFFE3F0DF);
  static const bg = Color(0xFFF6F7F2);
  static const orange = Color(0xFFF4A261);
  static const textMuted = Color(0xFF7A8580);
}

BoxShadow get softShadow => const BoxShadow(
      color: Color(0x14123D2B),
      blurRadius: 24,
      offset: Offset(0, 10),
    );

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  int water = 0;
  int meals = 0;
  String userName = 'Bondhu';
  bool isLoadingData = true;

  String get todayKey {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> get dailyDoc {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance.collection('users').doc(user!.uid)
        .collection('daily_logs').doc(todayKey);
  }

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final profile = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final profileData = profile.data();
      if (profileData != null) {
        userName = (profileData['name'] ?? profileData['fullName'] ?? user.displayName ?? 'Bondhu').toString();
      }
      final daily = await dailyDoc.get();
      final data = daily.data();
      if (data != null) {
        water = (data['water'] as num?)?.toInt() ?? 0;
        meals = (data['meals'] as num?)?.toInt() ?? 0;
      }
    } catch (e) {
      debugPrint('Could not load home data: $e');
    }
    if (mounted) setState(() => isLoadingData = false);
  }

  Future<void> _updateDailyValue(String field, int value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await dailyDoc.set({field: value, 'date': todayKey, 'updatedAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save. Check your internet and Firestore rules.')));
      debugPrint('Save failed: $e');
    }
  }

  void _changeWater(int delta) {
    final next = (water + delta).clamp(0, waterGoal);
    setState(() => water = next);
    _updateDailyValue('water', next);
  }

  void _changeMeals(int delta) {
    final next = (meals + delta).clamp(0, mealGoal);
    setState(() => meals = next);
    _updateDailyValue('meals', next);
  }
  static const int waterGoal = 8;
  static const int mealGoal = 3;

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get dateLabel {
    final d = DateTime.now();
    return '${d.day} ${_months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: selectedIndex,
          children: [
            _homeContent(),
            _placeholderPage('My Progress', Icons.bar_chart_rounded),
            _placeholderPage('AI Nutritionist', Icons.smart_toy_outlined),
            _placeholderPage('My Profile', Icons.person_outline_rounded),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(child: _navBar()),
    );
  }

  // ───────────────────────── NAV BAR ─────────────────────────

  Widget _navBar() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.bar_chart_rounded, 'Progress'),
      (Icons.auto_awesome_rounded, 'AI'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkGreen,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40123D2B),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.symmetric(
                horizontal: selected ? 18 : 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(
                    items[i].$1,
                    size: 22,
                    color: selected ? AppColors.darkGreen : Colors.white70,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              items[i].$2,
                              style: const TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ───────────────────────── HOME ─────────────────────────

  Widget _homeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 20),
          _searchBar(),
          const SizedBox(height: 22),
          _heroCard(),
          const SizedBox(height: 28),
          _sectionHeader("Today's overview", trailing: dateLabel),
          const SizedBox(height: 14),
          _overviewRow(),
          const SizedBox(height: 28),
          _sectionHeader('Quick actions'),
          const SizedBox(height: 16),
          _quickActions(),
          const SizedBox(height: 28),
          _sectionHeader('Meal inspiration', trailing: 'See all'),
          const SizedBox(height: 14),
          _mealList(),
          const SizedBox(height: 24),
          _tipCard(),
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          height: 50,
          width: 50,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF69A96C), AppColors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Text(
              'B',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hello, $userName 👋',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [softShadow],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.darkGreen,
              ),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                height: 9,
                width: 9,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [softShadow],
      ),
      child: TextField(
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search foods, recipes, tips…',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 20,
                color: AppColors.green,
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.darkGreen, Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: _circle(150, 20),
            ),
            Positioned(
              right: 40,
              bottom: -60,
              child: _circle(130, 14),
            ),
            const Positioned(
              right: 22,
              top: 22,
              child: Text('🥗', style: TextStyle(fontSize: 46)),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(36),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome,
                            size: 13, color: Color(0xFFD5E9D1)),
                        SizedBox(width: 6),
                        Text(
                          'AI NUTRITION PARTNER',
                          style: TextStyle(
                            color: Color(0xFFD5E9D1),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Eat better.\nFeel better.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Personalized guidance for your\neveryday health.',
                    style: TextStyle(
                      color: Color(0xFFD9E8D6),
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => setState(() => selectedIndex = 2),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ask AI Nutritionist',
                              style: TextStyle(
                                color: AppColors.darkGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: AppColors.darkGreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, int alpha) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(alpha),
      ),
    );
  }

  Widget _sectionHeader(String title, {String? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGreen,
            letterSpacing: -0.3,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(
              color: AppColors.green,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
      ],
    );
  }

  // ───────────────────────── OVERVIEW ─────────────────────────

  Widget _overviewRow() {
    return Row(
      children: [
        Expanded(
          child: _progressCard(
            title: 'Water',
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF3FA7D6),
            value: water,
            goal: waterGoal,
            subtitle: 'glasses',
            onAdd: () => _changeWater(1),
            onRemove: () => _changeWater(-1),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _progressCard(
            title: 'Meals',
            icon: Icons.restaurant_rounded,
            color: AppColors.green,
            value: meals,
            goal: mealGoal,
            subtitle: 'tracked',
            onAdd: () => _changeMeals(1),
            onRemove: () => _changeMeals(-1),
          ),
        ),
      ],
    );
  }

  Widget _progressCard({
    required String title,
    required IconData icon,
    required Color color,
    required int value,
    required int goal,
    required String subtitle,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [softShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.darkGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ProgressRing(
            progress: value / goal,
            color: color,
            size: 96,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$value/$goal',
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _roundButton(Icons.remove_rounded, onRemove, filled: false),
              const SizedBox(width: 12),
              _roundButton(Icons.add_rounded, onAdd, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roundButton(
    IconData icon,
    VoidCallback onTap, {
    bool filled = true,
    Color color = AppColors.green,
  }) {
    return Material(
      color: filled ? color : AppColors.bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: filled ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // ───────────────────────── QUICK ACTIONS ─────────────────────────

  Widget _quickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _actionTile(
          Icons.camera_alt_rounded,
          'Scan food',
          AppColors.green,
          const Color(0xFFE3F0DF),
          () => setState(() => selectedIndex = 2),
        ),
        _actionTile(
          Icons.chat_bubble_rounded,
          'Ask AI',
          const Color(0xFFB86C35),
          const Color(0xFFFBE9D8),
          () => setState(() => selectedIndex = 2),
        ),
        _actionTile(
            Icons.menu_book_rounded,
            'Diary',
            const Color(0xFF617344),
            const Color(0xFFE6E9D8),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FoodLogPage(),
                ),
              );
            },
          ),
        _actionTile(
          Icons.flag_rounded,
          'Goals',
          const Color(0xFFB35C67),
          const Color(0xFFF5E1E2),
          () => setState(() => selectedIndex = 1),
        ),
      ],
    );
  }

  Widget _actionTile(
    IconData icon,
    String label,
    Color iconColor,
    Color bg,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 66,
            width: 66,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.darkGreen,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── MEALS ─────────────────────────

  Widget _mealList() {
    const meals = [
      ('🍛', 'Dal & Rice Bowl', '420 kcal', 'Lunch', Color(0xFFFBE9D8)),
      ('🐟', 'Fish Curry & Greens', '380 kcal', 'Dinner', Color(0xFFE3F0DF)),
      ('🥗', 'Veggie Bhorta Salad', '240 kcal', 'Light', Color(0xFFE6E9D8)),
      ('🥣', 'Oats with Banana', '310 kcal', 'Breakfast', Color(0xFFF5E1E2)),
    ];

    return SizedBox(
      height: 190,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: meals.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final m = meals[i];
          return Container(
            width: 158,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [softShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 76,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: m.$5,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(m.$1, style: const TextStyle(fontSize: 38)),
                      ),
                      Positioned(
                        left: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            m.$4,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  m.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.25,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 15,
                      color: AppColors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      m.$3,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────── TIP ─────────────────────────

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFCEBDA), Color(0xFFFAE0C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFE08A3C),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily wellness tip',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Small healthy choices every day can make a big difference.',
                  style: TextStyle(
                    color: Color(0xFF6B5A4A),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── PLACEHOLDER ─────────────────────────

  Widget _placeholderPage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: const BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 46, color: AppColors.green),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This section will be developed next.',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── PROGRESS RING ─────────────────────────

class ProgressRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;
  final Widget child;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          painter: _RingPainter(value, color),
          child: SizedBox(
            height: size,
            width: size,
            child: Center(child: child),
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 9.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color.withAlpha(30);
    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);

    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * progress, false, arc);
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
