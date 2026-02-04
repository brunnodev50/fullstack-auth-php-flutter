import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../widgets/app_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _senhaController = TextEditingController();
  final _api = ApiService();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _loading = true);
    
    final res = await _api.redefinirSenha(
      widget.email,
      _codigoController.text.trim(),
      _senhaController.text,
    );
    
    if (!mounted) return;
    setState(() => _loading = false);
    
    if (res['success'] == true) {
      Navigator.popUntil(context, (route) => route.isFirst);
      AppSnackBar.showSuccess(context, 'Senha alterada com sucesso!');
    } else {
      AppSnackBar.showError(context, res['message'] ?? 'Erro ao redefinir senha');
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmall ? 16 : 24),
          child: ResponsiveContainer(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(isSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          // Ícone
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.vpn_key_rounded,
              color: AppColors.secondary,
              size: 40,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Título
          const Text(
            'Nova Senha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Código enviado para:\n${widget.email}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isSmall) {
    return AppCard(
      padding: EdgeInsets.all(isSmall ? 20 : 28),
      child: Column(
        children: [
          AppTextField(
            label: 'Código de verificação',
            hint: '000000',
            controller: _codigoController,
            prefixIcon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe o código';
              if (v.length < 6) return 'Código inválido';
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'Nova senha',
            hint: 'Mínimo 6 caracteres',
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
              if (v == null || v.isEmpty) return 'Informe a nova senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          
          const SizedBox(height: 28),
          
          AppButton(
            text: 'Redefinir Senha',
            icon: Icons.check_rounded,
            onPressed: _reset,
            loading: _loading,
          ),
        ],
      ),
    );
  }
}
