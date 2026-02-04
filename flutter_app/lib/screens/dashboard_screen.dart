import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/app_button.dart';
import '../widgets/app_widgets.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String userId;
  
  const DashboardScreen({super.key, required this.userId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _user;
  final _api = ApiService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() => _loading = true);
    
    final res = await _api.getUser(widget.userId);
    
    if (!mounted) return;
    
    if (res['success'] == true) {
      setState(() {
        _user = res['user'];
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  String _getPhotoUrl() {
    if (_user?['foto'] == null || _user!['foto'] == 'assets/default.png') {
      return '';
    }
    return '${ApiService.baseUrl}/${_user!['foto']}?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(c);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const LoginScreen()),
              );
            },
            child: const Text('Sair', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => ProfileScreen(user: _user!)),
    ).then((_) => _fetchUser());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'Erro ao carregar dados',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  text: 'Tentar novamente',
                  icon: Icons.refresh,
                  onPressed: _fetchUser,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUser,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(_isSmallScreen ? 16 : 24),
            child: ResponsiveContainer(
              maxWidth: 500,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildStats(),
                  const SizedBox(height: 32),
                  _buildMenu(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isSmallScreen => MediaQuery.of(context).size.width < 360;

  String get _firstName => _user!['nome']?.split(' ')[0] ?? 'Usuário';

  bool get _isActive => _user!['status'] == 'ativo';

  Widget _buildHeader() {
    final photoUrl = _getPhotoUrl();
    
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $_firstName! 👋',
                style: TextStyle(
                  fontSize: _isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _user!['email'] ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Hero(
          tag: 'profile-photo',
          child: AppAvatar(
            imageUrl: photoUrl,
            size: 60,
            onTap: _navigateToProfile,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Acessos',
                value: _user!['acessos']?.toString() ?? '0',
                icon: Icons.login_rounded,
                gradient: AppColors.gradientCard,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                label: 'Status',
                value: _isActive ? 'Ativo' : 'Inativo',
                icon: _isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
                gradient: _isActive ? AppColors.gradientSuccess : AppColors.gradientDanger,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Menu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              MenuItem(
                icon: Icons.person_outline,
                title: 'Editar Perfil',
                subtitle: 'Altere suas informações',
                onTap: _navigateToProfile,
              ),
              const Divider(height: 1, indent: 60),
              MenuItem(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                subtitle: 'Preferências do app',
                onTap: () {
                  AppSnackBar.show(context, 'Em breve!');
                },
              ),
              const Divider(height: 1, indent: 60),
              MenuItem(
                icon: Icons.help_outline,
                title: 'Ajuda',
                subtitle: 'Central de suporte',
                onTap: () {
                  AppSnackBar.show(context, 'Em breve!');
                },
              ),
              const Divider(height: 1, indent: 60),
              MenuItem(
                icon: Icons.logout_rounded,
                title: 'Sair',
                subtitle: 'Encerrar sessão',
                iconColor: AppColors.danger,
                titleColor: AppColors.danger,
                onTap: _logout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
