import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../models/enums.dart';
import '../../models/enums_ext.dart';
import '../../services/service_locator.dart';
import '../../services/auth_service.dart';
import '../auth/login_register_screen.dart';
import 'about_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  int _activeTab = 0;

  // Statistik
  int _jumlahDiary = 0;
  int _jumlahProdukRutin = 0;
  int _jumlahScan = 0;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _loading = false);
    });
    _loadStats();
  }

  AppAuthUser? get _user => ServiceLocator.auth.currentUser;

  Future<void> _loadStats() async {
    setState(() => _loadingStats = true);
    try {
      final diary = await ServiceLocator.diary.getAll();
      final products = await ServiceLocator.firestore.getProducts(
        ServiceLocator.auth.currentUid ?? '',
      );

      // Untuk scan, kita asumsikan ada collection terpisah
      // atau pakai placeholder 0 dulu — nanti setelah fitur Scan jadi
      // kita bisa ambil dari collection scan_history
      // Sementara: pakai 0
      const scanCount = 0;

      if (!mounted) return;
      setState(() {
        _jumlahDiary = diary.length;
        _jumlahProdukRutin = products.length;
        _jumlahScan = scanCount;
        _loadingStats = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingStats = false);
    }
  }

  void _showSnack(String msg, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Keluar dari akun?', style: AppText.cardTitle),
                const SizedBox(height: 8),
                Text(
                  'Kamu harus login lagi untuk mengakses profil.',
                  style: AppText.body,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusDanger,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true) {
      await ServiceLocator.auth.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _ubahJenisKulit(JenisKulit baru) async {
    await ServiceLocator.auth.updateJenisKulit(baru);
    if (!mounted) return;
    setState(() {});
    _showSnack(
      'Jenis kulit diubah ke ${baru.label}',
      AppColors.statusSafe,
    );
  }

  Future<void> _editNama() async {
    final ctrl = TextEditingController(text: _user?.nama ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Nama', style: AppText.cardTitle),
                const SizedBox(height: 6),
                Text(
                  'Ubah nama tampilan profilmu',
                  style: AppText.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: ctrl,
                    autofocus: true,
                    style: AppText.body,
                    decoration: InputDecoration(
                      hintText: 'Nama kamu',
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, ctrl.text.trim()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(88, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                      child: const Text('Simpan'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != null && result.isNotEmpty && mounted) {
      await ServiceLocator.auth.updateNama(result);
      if (!mounted) return;
      setState(() {});
      _showSnack('Nama berhasil diubah', AppColors.statusSafe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Profil')),
        body: const Center(child: Text('Belum login')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            onPressed: _loadStats,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(user),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTabBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildTabContent(user),
                  const SizedBox(height: AppSpacing.lg),
                  _buildMenuTentang(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLogoutButton(),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(AppAuthUser user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Row(
        children: [
          _buildAvatar(user, size: 80),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nama.isNotEmpty ? user.nama : 'User',
                  style: AppText.sectionTitle.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppText.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.jenisKulit.label,
                      style: AppText.badge.copyWith(
                        color: AppColors.accent,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _editNama,
            tooltip: 'Edit Profil',
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(AppAuthUser user, {double size = 80}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      alignment: Alignment.center,
      child: user.nama.isNotEmpty
          ? Text(
              user.nama[0].toUpperCase(),
              style: AppText.heroTitle.copyWith(
                color: AppColors.primary,
                fontSize: size * 0.4,
              ),
            )
          : Icon(
              Icons.person,
              size: size * 0.5,
              color: AppColors.primary,
            ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Jenis Kulit', 'Aktivitas', 'Riwayat Scan'];
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == _activeTab;
          return Padding(
            padding: EdgeInsets.only(
              right: i < tabs.length - 1 ? 24 : 0,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = i),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active
                          ? AppColors.accent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[i],
                  style: AppText.body.copyWith(
                    fontSize: 14,
                    fontWeight:
                        active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? AppColors.primary
                        : AppColors.textDark.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(AppAuthUser user) {
    switch (_activeTab) {
      case 0:
        return _buildJenisKulitSection(user);
      case 1:
        return _buildRingkasanAktivitas();
      case 2:
        return _buildRiwayatScan();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildJenisKulitSection(AppAuthUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kulit',
          style: AppText.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          'Digunakan untuk personalisasi Scan & Routine',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: JenisKulit.values.map((j) {
            final active = user.jenisKulit == j;
            return GestureDetector(
              onTap: () => _ubahJenisKulit(j),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.cream,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: active
                        ? AppColors.accent
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: active ? 2 : 1,
                  ),
                ),
                child: Text(
                  j.label,
                  style: AppText.badge.copyWith(
                    color: active ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRingkasanAktivitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ringkasan Aktivitas',
              style: AppText.cardTitle.copyWith(fontSize: 16),
            ),
            const Spacer(),
            if (_loadingStats)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.book_outlined,
                value: '$_jumlahDiary',
                label: 'Hari Diary',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.spa_outlined,
                value: '$_jumlahProdukRutin',
                label: 'Produk Rutin',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.qr_code_scanner,
                value: '$_jumlahScan',
                label: 'Kali Scan',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppText.sectionTitle.copyWith(
              fontSize: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.bodySmall.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatScan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Scan',
          style: AppText.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              const Icon(
                Icons.history,
                size: 32,
                color: AppColors.neutral,
              ),
              const SizedBox(height: 10),
              Text(
                'Belum ada riwayat scan',
                style: AppText.bodySmall.copyWith(
                  fontSize: 14,
                  color: AppColors.textDark.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mulai scan produk untuk melihat riwayat di sini',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTentang() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lainnya',
          style: AppText.cardTitle.copyWith(fontSize: 16),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tentang OurGlow',
                        style: AppText.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Info aplikasi, metode, & sumber',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.neutral,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('Keluar'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.statusDanger,
          side: const BorderSide(
            color: AppColors.statusDanger,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}