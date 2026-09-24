import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../data/mock_products.dart';
import '../../models/product.dart';
import '../../services/service_locator.dart';
import '../auth/login_register_screen.dart';
import '../product/product_detail_screen.dart';
import '../product/product_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentMenu = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const List<String> _menus = [
    'Beranda',
    'Scan Produk',
    'Routine Checker',
    'Skin Diary',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _AppDrawer(
        menus: _menus,
        currentIndex: _currentMenu,
        onMenuTap: (i) {
          setState(() => _currentMenu = i);
          Navigator.pop(context);
        },
      ),
      body: Column(
        children: [
          _Navbar(
            menus: _menus,
            currentIndex: _currentMenu,
            onMenuTap: (i) => setState(() => _currentMenu = i),
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const Expanded(
            child: _HomeBody(),
          ),
        ],
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  final List<String> menus;
  final int currentIndex;
  final ValueChanged<int> onMenuTap;

  const _AppDrawer({
    required this.menus,
    required this.currentIndex,
    required this.onMenuTap,
  });

  bool get _isLoggedIn => ServiceLocator.auth.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.primary,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    width: 40,
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        const SizedBox(width: 40, height: 40),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'OurGlow',
                    style: AppText.sectionTitle.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: AppSpacing.md),
            ...List.generate(menus.length, (i) {
              final active = i == currentIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: InkWell(
                  onTap: () => onMenuTap(i),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      menus[i],
                      style: AppText.body.copyWith(
                        color: active ? AppColors.accent : Colors.white,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }),
            const Spacer(),
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: _isLoggedIn
                  ? _buildProfileSection(context)
                  : _buildLoginButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginRegisterScreen(),
            ),
          );
        },
        icon: const Icon(Icons.login, size: 18),
        label: Text(
          'Login Sekarang',
          style: AppText.buttonLabel.copyWith(fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final user = ServiceLocator.auth.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                user?.nama.isNotEmpty == true
                    ? user!.nama[0].toUpperCase()
                    : '?',
                style: AppText.sectionTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.nama ?? '',
                    style: AppText.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.email ?? '',
                    style: AppText.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline, size: 18),
            label: const Text('Lihat Profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(
                color: AppColors.accent,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: const Column(
        children: [
          _HeroSection(),
          _ScanCardSection(),
          _FeatureRow(),
          _WhySection(),
          _RoutineSection(),
          _TipsSection(),
          _CopyrightBar(),
        ],
      ),
    );
  }
}

class _CopyrightBar extends StatelessWidget {
  const _CopyrightBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Text(
            '© 2026 OurGlow — Skincare Checker',
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dea Apriani Agustin',
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

enum _DeviceSize { mobile, tablet, desktop }

_DeviceSize _getSize(BuildContext context) {
  final w = MediaQuery.of(context).size.width;
  if (w < 600) return _DeviceSize.mobile;
  if (w < 1024) return _DeviceSize.tablet;
  return _DeviceSize.desktop;
}

double _hPad(BuildContext context) {
  switch (_getSize(context)) {
    case _DeviceSize.mobile:
      return 16;
    case _DeviceSize.tablet:
      return 32;
    case _DeviceSize.desktop:
      return 60;
  }
}

class _Navbar extends StatelessWidget {
  final List<String> menus;
  final int currentIndex;
  final ValueChanged<int> onMenuTap;
  final VoidCallback onOpenDrawer;

  const _Navbar({
    required this.menus,
    required this.currentIndex,
    required this.onMenuTap,
    required this.onOpenDrawer,
  });

  bool get _isLoggedIn => ServiceLocator.auth.currentUser != null;

  void _onProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isMobile = size == _DeviceSize.mobile;
    final isTablet = size == _DeviceSize.tablet;

    if (isMobile || isTablet) {
      return Container(
        height: 56,
        color: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: InkWell(
                onTap: onOpenDrawer,
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            Image.asset(
              AppAssets.logo,
              height: 32,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: 32),
            ),
          ],
        ),
      );
    }

    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Image.asset(
            AppAssets.logo,
            width: 54,
            height: 54,
            errorBuilder: (_, __, ___) => const SizedBox(
              width: 54,
              height: 54,
            ),
          ),
          const Spacer(),
          ...List.generate(menus.length, (i) {
            final active = i == currentIndex;
            return InkWell(
              onTap: () => onMenuTap(i),
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                alignment: Alignment.center,
                child: Text(
                  menus[i],
                  style: AppText.body.copyWith(
                    color: active
                        ? AppColors.accent
                        : Colors.white.withValues(alpha: 0.85),
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    decoration: active
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: AppColors.accent,
                    decorationThickness: 2,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          if (_isLoggedIn)
            OutlinedButton.icon(
              onPressed: () => _onProfileTap(context),
              icon: const Icon(Icons.person_outline, size: 18),
              label: const Text('Lihat Profil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: AppColors.accent,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginRegisterScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              child: Text(
                'Login Sekarang',
                style: AppText.buttonLabel.copyWith(fontSize: 14),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % mockProducts.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isDesktop = size == _DeviceSize.desktop;
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    final user = ServiceLocator.auth.currentUser;
    final sapaan = user != null
        ? 'Halo, ${user.nama}! Gimana Kulitmu Hari Ini?'
        : 'Halo, Selamat Datang! Gimana Kulitmu Hari Ini?';

    final header = Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            sapaan,
            style: AppText.badge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 10 : 12,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: isMobile ? 12 : AppSpacing.md),
        _ExtrudedLogoText(size: size),
        SizedBox(height: isMobile ? 6 : AppSpacing.sm),
        Text(
          'Scan Komposisi, Pilih yang Tepat Untuk Kulitmu, Pancarkan Glowing',
          style: AppText.body.copyWith(
            fontSize: isMobile ? 12.5 : 15,
            color: isMobile
                ? const Color(0xFF555555)
                : AppColors.textDark,
            height: 1.5,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
      ],
    );

    return _ScrollReveal(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 20 : AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            SizedBox(height: isMobile ? 20 : AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Produk Pilihan',
                    style: AppText.sectionTitle.copyWith(
                      fontSize: isMobile ? 18 : 22,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProductListScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Lihat Semua',
                        style: AppText.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (isMobile) {
                  return SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mockProducts.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final product = mockProducts[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child:
                                _ProductCarouselCard(product: product),
                          ),
                        );
                      },
                    ),
                  );
                }
                return SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: mockProducts.length,
                    onPageChanged: (i) {
                      setState(() => _currentPage = i);
                      _startAutoPlay();
                    },
                    itemBuilder: (context, index) {
                      final product = mockProducts[index];
                      return _ProductCarouselCard(product: product);
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mockProducts.length,
                (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
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

class _ProductCarouselCard extends StatelessWidget {
  final Product product;
  const _ProductCarouselCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final isMobile = _getSize(context) == _DeviceSize.mobile;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: isMobile
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.pill),
                              ),
                              child: Text(
                                product.kategori.name,
                                style: AppText.badge.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.nama,
                              style: AppText.sectionTitle.copyWith(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Bahan: ${product.bahan.take(3).join(', ')}',
                              style: AppText.bodySmall.copyWith(
                                color:
                                    Colors.white.withValues(alpha: 0.85),
                                fontSize: 11.5,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.schedule,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.waktuPakai.name,
                                    style: AppText.caption.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          child: Image.asset(
                            product.fotoUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white24,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.spa_outlined,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(
                                    AppRadius.pill),
                              ),
                              child: Text(
                                product.kategori.name,
                                style: AppText.badge.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.nama,
                              style: AppText.sectionTitle.copyWith(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Bahan: ${product.bahan.take(3).join(', ')}',
                              style: AppText.bodySmall.copyWith(
                                color:
                                    Colors.white.withValues(alpha: 0.85),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.pill),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        product.waktuPakai.name,
                                        style:
                                            AppText.caption.copyWith(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppRadius.card),
                          child: Image.asset(
                            product.fotoUrl ?? '',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.white24,
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.spa_outlined,
                                size: 56,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ExtrudedLogoText extends StatelessWidget {
  final _DeviceSize size;
  const _ExtrudedLogoText({required this.size});

  @override
  Widget build(BuildContext context) {
    final fontSize = size == _DeviceSize.desktop
        ? 56.0
        : size == _DeviceSize.tablet
            ? 44.0
            : 28.0;

    final baseStyle = AppText.heroTitle.copyWith(
      fontSize: fontSize,
      letterSpacing: -1,
    );

    return Stack(
      children: [
        Text(
          'OurGlow',
          style: baseStyle.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = AppColors.accent,
          ),
        ),
        Text(
          'OurGlow',
          style: baseStyle.copyWith(
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                color: AppColors.accent.withValues(alpha: 0.9),
                blurRadius: 0,
              ),
              Shadow(
                offset: const Offset(0, 4),
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 6,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanCardSection extends StatelessWidget {
  const _ScanCardSection();

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isDesktop = size == _DeviceSize.desktop;
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    return _ScrollReveal(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 16 : AppSpacing.md,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          clipBehavior: Clip.antiAlias,
          child: isDesktop
              ? SizedBox(
                  height: 280,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: _scanContent(isMobile, isDesktop),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Image.asset(
                            AppAssets.girlScan,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 18 : AppSpacing.lg,
                    vertical: isMobile ? 18 : AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: isMobile ? 110 : 160,
                        child: Image.asset(
                          AppAssets.girlScan,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 110,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.white54,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _scanContent(isMobile, isDesktop),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _scanContent(bool isMobile, bool isDesktop) {
    return Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isMobile ? 52 : 72,
          height: isMobile ? 52 : 72,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.camera_alt_outlined,
            size: isMobile ? 26 : 36,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: isMobile ? 8 : AppSpacing.md),
        Text(
          'Scan Produk Skincare',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: AppText.sectionTitle.copyWith(
            color: Colors.white,
            fontSize: isDesktop
                ? 26
                : isMobile
                    ? 20
                    : 24,
          ),
        ),
        SizedBox(height: isMobile ? 4 : AppSpacing.sm),
        Text(
          'Foto komposisi atau barcode produk untuk analisis kandungan skincare',
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: AppText.body.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: isMobile ? 13 : 14,
            height: 1.5,
          ),
        ),
        SizedBox(height: isMobile ? 10 : AppSpacing.lg),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 32,
              vertical: 12,
            ),
          ),
          child: const Text('Yuk Scan!'),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    final features = [
      {'icon': Icons.qr_code_scanner, 'label': 'Scan dan Analisis Bahan'},
      {'icon': Icons.warning_amber_rounded, 'label': 'Cek Kombinasi Aman'},
      {'icon': Icons.favorite_border, 'label': 'Rekomendasi Sesuai Kulit'},
    ];

    Widget buildCard(Map<String, dynamic> f) {
      return InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.accent, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: isMobile ? 56 : 64,
                height: isMobile ? 56 : 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  f['icon'] as IconData,
                  size: isMobile ? 26 : 32,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: isMobile ? 14 : AppSpacing.md),
              Text(
                f['label'] as String,
                textAlign: TextAlign.center,
                style: AppText.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 13 : 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _ScrollReveal(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 16 : AppSpacing.md,
        ),
        child: isMobile
            ? Column(
                children: features
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: buildCard(f),
                      ),
                    )
                    .toList(),
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: features
                      .map(
                        (f) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: buildCard(f),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
      ),
    );
  }
}

class _WhySection extends StatelessWidget {
  const _WhySection();

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isDesktop = size == _DeviceSize.desktop;
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    const bullets = [
      'Simpan semua riwayat scan produk kamu',
      'Rekomendasi dipersonalisasi sesuai jenis kulit',
      'Catat progress kulit tiap hari di Skin Diary',
      'Dapat notifikasi kalau produkmu ternyata gak cocok dipakai bareng',
    ];

    return _ScrollReveal(
      child: Container(
        width: double.infinity,
        color: AppColors.sectionBg,
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 24 : AppSpacing.xl,
        ),
        child: Column(
          children: [
            Text(
              'Kenapa Harus OurGlow?',
              style: AppText.sectionTitle.copyWith(
                fontSize: isDesktop
                    ? 32
                    : isMobile
                        ? 22
                        : 28,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 16 : AppSpacing.lg),
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _whyBullets(bullets, isMobile)),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(flex: 2, child: _whyAmanCard(isMobile)),
                ],
              )
            else
              Column(
                children: [
                  _whyBullets(bullets, isMobile),
                  SizedBox(height: isMobile ? 16 : AppSpacing.lg),
                  _whyAmanCard(isMobile),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _whyBullets(List<String> bullets, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 16,
            vertical: isMobile ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(
            'Lebih dari sekedar cek sekali pakai',
            style: AppText.badge.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: isMobile ? 10 : 12,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : AppSpacing.md),
        ...bullets.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    b,
                    style: AppText.body.copyWith(
                      fontSize: isMobile ? 13 : 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _whyAmanCard(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.accent, width: 3),
      ),
      child: Column(
        children: [
          Container(
            width: isMobile ? 50 : 60,
            height: isMobile ? 50 : 60,
            decoration: const BoxDecoration(
              color: AppColors.statusSafe,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: isMobile ? 28 : 34,
            ),
          ),
          SizedBox(height: isMobile ? 12 : AppSpacing.md),
          Text(
            'Aman',
            style: AppText.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: isMobile ? 22 : 28,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Contoh hasil analisis produk',
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: isMobile ? 11.5 : 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutineSection extends StatelessWidget {
  const _RoutineSection();

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isDesktop = size == _DeviceSize.desktop;
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    final items = [
      {
        'title': 'Routine Checker',
        'desc':
            'Masukin semua produk yang kamu pakai tiap hari, kita cek apa urutannya udah tepat dan gak ada kombinasi yang bikin iritasi.',
        'image': AppAssets.routine,
      },
      {
        'title': 'Skin Diary',
        'desc':
            'Log kondisi kulit harian, lihat pola nya waktu ke waktu, dan pahami produk mana yang beneran cocok buat kulitmu.',
        'image': AppAssets.diary,
      },
    ];

    return _ScrollReveal(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 24 : AppSpacing.xl,
        ),
        child: Column(
          children: [
            Align(
              alignment:
                  isDesktop ? Alignment.centerRight : Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 20,
                  vertical: isMobile ? 8 : 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  'Lengkapi Rutinmu Bareng OurGlow',
                  style: AppText.badge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 11 : 14,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: isMobile ? 16 : AppSpacing.lg),
            if (isDesktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items
                      .map(
                        (it) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildRoutineCard(it, isMobile),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            else
              Column(
                children: items
                    .map(
                      (it) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRoutineCard(it, isMobile),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(Map<String, String> it, bool isMobile) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              it['image']!,
              width: isMobile ? 60 : 80,
              errorBuilder: (_, __, ___) => SizedBox(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primary,
                ),
              ),
            ),
            SizedBox(width: isMobile ? 12 : AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    it['title']!,
                    style: AppText.cardTitle.copyWith(
                      fontSize: isMobile ? 15 : 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    it['desc']!,
                    style: AppText.bodySmall.copyWith(
                      fontSize: isMobile ? 12 : 13,
                      height: 1.5,
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
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final size = _getSize(context);
    final isDesktop = size == _DeviceSize.desktop;
    final isMobile = size == _DeviceSize.mobile;
    final hPad = _hPad(context);

    const tips = [
      {
        'q': 'Kenapa retinol tidak boleh dicampur dengan vitamin C?',
        'a':
            'Kombinasi ini bisa bikin kulit iritasi jika dipakai waktu yang sama.',
      },
      {
        'q': 'Urutan skincare pagi yang benar bagaimana?',
        'a':
            'Cleanser → toner → serum → pelembap → sunscreen. Sunscreen wajib dipakai walau di dalam ruangan.',
      },
      {
        'q': 'Kenali bahan yang sering bikin kulit sensitif bereaksi!',
        'a':
            'Fragrance, alkohol denat, dan essential oil adalah tiga bahan yang paling sering memicu iritasi pada kulit sensitif.',
      },
    ];

    return _ScrollReveal(
      child: Container(
        width: double.infinity,
        color: AppColors.sectionBg,
        padding: EdgeInsets.symmetric(
          horizontal: hPad,
          vertical: isMobile ? 24 : AppSpacing.xl,
        ),
        child: Column(
          children: [
            Text(
              'Tips Skincare Buat Kamu!',
              style: AppText.sectionTitle.copyWith(
                fontSize: isDesktop
                    ? 32
                    : isMobile
                        ? 22
                        : 28,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isMobile ? 16 : AppSpacing.lg),
            if (isDesktop)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: tips
                      .map(
                        (t) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            child: _buildTipCard(t, isMobile),
                          ),
                        ),
                      )
                      .toList(),
                ),
              )
            else
              Column(
                children: tips
                    .map(
                      (t) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildTipCard(t, isMobile),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(Map<String, String> t, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.small),
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t['q']!,
              style: AppText.body.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 13 : 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t['a']!,
                  style: AppText.bodySmall.copyWith(
                    fontSize: isMobile ? 11.5 : 12,
                    color: AppColors.primary,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollReveal extends StatefulWidget {
  final Widget child;
  const _ScrollReveal({required this.child});

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _scaleAnim = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkVisibility() {
    if (!mounted || _hasAnimated) return;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      Future.delayed(const Duration(milliseconds: 100), _checkVisibility);
      return;
    }

    final position = box.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    final isVisible = position.dy < screenHeight * 0.9;

    if (isVisible) {
      _hasAnimated = true;
      _controller.forward();
    } else {
      Future.delayed(const Duration(milliseconds: 200), _checkVisibility);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value * 60,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}