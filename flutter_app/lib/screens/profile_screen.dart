import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/app_widgets.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  final _senhaController = TextEditingController();
  XFile? _selectedImage;
  bool _loading = false;
  bool _obscurePassword = true;
  final _api = ApiService();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.user['nome']);
    _emailController = TextEditingController(text: widget.user['email']);
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  String _getPhotoUrl() {
    if (widget.user['foto'] == null || widget.user['foto'] == 'assets/default.png') {
      return '';
    }
    return '${ApiService.baseUrl}/${widget.user['foto']}?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Fecha o bottom sheet
    
    try {
      final ImagePicker picker = ImagePicker();
      
      debugPrint('=== INICIANDO PICKER ===');
      debugPrint('Source: $source');
      
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      debugPrint('=== RESULTADO ===');
      debugPrint('Image: $image');
      debugPrint('Path: ${image?.path}');
      
      if (image != null && mounted) {
        // Verifica se arquivo existe
        final file = File(image.path);
        final exists = await file.exists();
        debugPrint('Arquivo existe: $exists');
        
        if (exists) {
          setState(() => _selectedImage = image);
          AppSnackBar.showSuccess(context, 'Imagem selecionada!');
        } else {
          AppSnackBar.showError(context, 'Arquivo não encontrado');
        }
      } else {
        debugPrint('Nenhuma imagem selecionada ou widget desmontado');
      }
    } catch (e, stack) {
      debugPrint('=== ERRO ===');
      debugPrint('Erro: $e');
      debugPrint('Stack: $stack');
      
      // Mostra erro completo na tela
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.danger),
                SizedBox(width: 8),
                Text('Erro Detalhado'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erro:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        '$e',
                        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Stack Trace:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          '$stack',
                          style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Escolher foto',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Câmera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeria',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    final res = await _api.updateProfile(
      id: widget.user['id'].toString(),
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      senha: _senhaController.text.isNotEmpty ? _senhaController.text : null,
      image: _selectedImage,
    );
    
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['success'] == true) {
      AppSnackBar.showSuccess(context, 'Perfil atualizado com sucesso!');
      Navigator.pop(context);
    } else {
      AppSnackBar.showError(context, res['message'] ?? 'Erro ao atualizar');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 360;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          child: ResponsiveContainer(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPhotoSection(),
                  const SizedBox(height: 32),
                  _buildForm(isSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    final photoUrl = _getPhotoUrl();
    
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePicker,
            child: Hero(
              tag: 'profile-photo',
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _buildPhotoWidget(photoUrl),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.gradientPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedImage != null ? 'Nova foto selecionada ✓' : 'Toque para alterar',
            style: TextStyle(
              fontSize: 13,
              color: _selectedImage != null ? AppColors.secondary : AppColors.textMuted,
              fontWeight: _selectedImage != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(String photoUrl) {
    // Se tem uma nova imagem selecionada, mostra ela
    if (_selectedImage != null) {
      return Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, error, __) {
          debugPrint('Erro ao carregar imagem local: $error');
          return _buildPlaceholder();
        },
      );
    }
    
    // Se tem foto no servidor, mostra ela
    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(isLoading: true);
        },
      );
    }
    
    // Placeholder padrão
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      width: 120,
      height: 120,
      color: AppColors.primary.withOpacity(0.1),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : const Icon(
              Icons.person,
              color: AppColors.primary,
              size: 48,
            ),
    );
  }

  Widget _buildForm(bool isSmall) {
    return AppCard(
      padding: EdgeInsets.all(isSmall ? 20 : 28),
      child: Column(
        children: [
          AppTextField(
            label: 'Nome completo',
            hint: 'Seu nome',
            controller: _nomeController,
            prefixIcon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe seu nome';
              if (v.length < 3) return 'Nome muito curto';
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'E-mail',
            hint: 'seu@email.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe o e-mail';
              if (!v.contains('@')) return 'E-mail inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Nova senha (opcional)',
            hint: 'Deixe vazio para manter',
            controller: _senhaController,
            obscure: _obscurePassword,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword 
                    ? Icons.visibility_off_outlined 
                    : Icons.visibility_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 28),
          
          AppButton(
            text: 'Salvar Alterações',
            icon: Icons.check_rounded,
            onPressed: _handleSave,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}