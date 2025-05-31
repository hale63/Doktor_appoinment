import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordChangePage extends StatefulWidget {
  const PasswordChangePage({super.key});

  @override
  State<PasswordChangePage> createState() => _PasswordChangePageState();
}

class _PasswordChangePageState extends State<PasswordChangePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isChangingPassword = false;
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Yeni şifreler eşleşmiyor', isError: true);
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Kullanıcıyı yeniden doğrula
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPasswordController.text);

        _showSnackBar('Şifre başarıyla güncellendi');
        _clearPasswordFields();

        // Başarılı olursa geri dön
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Şifre güncellenemedi';
      if (e.code == 'wrong-password') {
        message = 'Mevcut şifre hatalı';
      } else if (e.code == 'weak-password') {
        message = 'Şifre çok zayıf';
      } else if (e.code == 'requires-recent-login') {
        message = 'Güvenlik nedeniyle lütfen tekrar giriş yapın';
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      _showSnackBar('Bir hata oluştu', isError: true);
    } finally {
      setState(() {
        _isChangingPassword = false;
      });
    }
  }

  void _clearPasswordFields() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : const Color(0xFF6B46C1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mevcut şifre gerekli';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yeni şifre gerekli';
    }
    if (value.length < 6) {
      return 'Şifre en az 6 karakter olmalıdır';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre tekrarı gerekli';
    }
    if (value != _newPasswordController.text) {
      return 'Şifreler eşleşmiyor';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6B46C1),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B46C1),
              Color(0xFFF8F7FF),
            ],
            stops: [0.0, 0.15],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Başlık ve açıklama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B46C1).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE91E63).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFFE91E63),
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Şifrenizi Değiştirin',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hesabınızın güvenliği için düzenli olarak şifrenizi değiştirin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form alanları
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6B46C1).withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          controller: _currentPasswordController,
                          label: 'Mevcut Şifre',
                          hint: 'Mevcut şifrenizi girin',
                          isVisible: _currentPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _currentPasswordVisible = !_currentPasswordVisible;
                            });
                          },
                          validator: _validateCurrentPassword,
                        ),

                        const SizedBox(height: 24),

                        _buildPasswordField(
                          controller: _newPasswordController,
                          label: 'Yeni Şifre',
                          hint: 'Yeni şifrenizi girin',
                          isVisible: _newPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _newPasswordVisible = !_newPasswordVisible;
                            });
                          },
                          validator: _validateNewPassword,
                        ),

                        const SizedBox(height: 24),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          label: 'Yeni Şifre Tekrar',
                          hint: 'Yeni şifrenizi tekrar girin',
                          isVisible: _confirmPasswordVisible,
                          onVisibilityToggle: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                          validator: _validateConfirmPassword,
                        ),

                        const SizedBox(height: 32),

                        // Güncelle butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isChangingPassword ? null : _updatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B46C1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: _isChangingPassword
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text(
                              'Şifreyi Güncelle',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Güvenlik ipuçları
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: const Color(0xFF4CAF50),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Güvenlik İpuçları',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• En az 8 karakter kullanın\n'
                              '• Büyük ve küçük harf karışımı kullanın\n'
                              '• Rakam ve özel karakter ekleyin\n'
                              '• Kişisel bilgilerinizi kullanmayın',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF2E7D32).withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF8F7FF),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6B46C1), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              onPressed: onVisibilityToggle,
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}