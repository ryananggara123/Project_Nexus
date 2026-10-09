import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/student_demo_account.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.existingAccounts, super.key});

  final List<StudentDemoAccount> existingAccounts;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: const BorderSide(color: Color(0xFFDDE5EA)),
    );
    final fieldTheme = Theme.of(context).inputDecorationTheme.copyWith(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: fieldBorder,
      enabledBorder: fieldBorder,
      focusedBorder: fieldBorder.copyWith(
        borderSide: const BorderSide(
          color: ProjectNexusColors.teal,
          width: 1.6,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    );
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FB),
      appBar: AppBar(
        title: const Text('Registrasi siswa'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD9EBFF), Color(0xFFF1F0FF), Color(0xFFDDF8EF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(inputDecorationTheme: fieldTheme),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.97),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF456A83)
                              .withValues(alpha: 0.15),
                          blurRadius: 34,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 94,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE7F1FF), Color(0xFFE8F8F3)],
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(
                                  Icons.groups_2_rounded,
                                  color: ProjectNexusColors.teal,
                                  size: 52,
                                ),
                                Positioned(
                                  top: 14,
                                  right: 112,
                                  child: Icon(
                                    Icons.auto_awesome_rounded,
                                    color: const Color(0xFFEDB34E)
                                        .withValues(alpha: 0.9),
                                    size: 18,
                                  ),
                                ),
                                Positioned(
                                  bottom: 14,
                                  left: 112,
                                  child: Icon(
                                    Icons.circle,
                                    color: const Color(0xFF7FCDB6)
                                        .withValues(alpha: 0.85),
                                    size: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Buat akun siswa',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: ProjectNexusColors.ink,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.4,
                                ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Bergabunglah dan mulai berkolaborasi di ProjectNexus.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ProjectNexusColors.muted,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),
                          TextFormField(
                            key: const Key('registration_name'),
                            controller: _nameController,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Nama lengkap',
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Nama lengkap wajib diisi.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('registration_nim'),
                            controller: _nimController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'NIM',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: _validateNim,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('registration_username'),
                            controller: _usernameController,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.alternate_email_rounded),
                            ),
                            validator: _validateUsername,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('registration_email'),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('registration_password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Kata sandi',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Tampilkan kata sandi'
                                    : 'Sembunyikan kata sandi',
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value == null || value.length < 6
                                ? 'Kata sandi minimal 6 karakter.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('registration_confirm_password'),
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmation,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Ulangi kata sandi',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                tooltip: _obscureConfirmation
                                    ? 'Tampilkan kata sandi'
                                    : 'Sembunyikan kata sandi',
                                onPressed: () => setState(
                                  () => _obscureConfirmation =
                                      !_obscureConfirmation,
                                ),
                                icon: Icon(
                                  _obscureConfirmation
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                            ),
                            validator: (value) =>
                                value != _passwordController.text
                                ? 'Konfirmasi kata sandi tidak cocok.'
                                : null,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 48,
                            child: FilledButton(
                              key: const Key('registration_submit'),
                              onPressed: _submit,
                              style: FilledButton.styleFrom(
                                backgroundColor: ProjectNexusColors.teal,
                                elevation: 3,
                                shadowColor: ProjectNexusColors.teal.withValues(
                                  alpha: 0.28,
                                ),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text('Daftar'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Akun tersimpan selama aplikasi berjalan dan belum tersimpan secara permanen.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ProjectNexusColors.muted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? _validateNim(String? value) {
    final nim = value?.trim() ?? '';
    if (nim.isEmpty) return 'NIM wajib diisi.';
    if (!RegExp(r'^\d{6,20}$').hasMatch(nim)) {
      return 'NIM harus terdiri dari 6–20 angka.';
    }
    if (widget.existingAccounts.any((account) => account.nim == nim)) {
      return 'NIM sudah terdaftar.';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (!RegExp(r'^[a-zA-Z0-9._-]{3,30}$').hasMatch(username)) {
      return 'Username 3–30 karakter: huruf, angka, titik, _ atau -.';
    }
    if (widget.existingAccounts.any(
      (account) => account.username.toLowerCase() == username.toLowerCase(),
    )) {
      return 'Username sudah digunakan.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    if (widget.existingAccounts.any(
      (account) => account.email.toLowerCase() == email.toLowerCase(),
    )) {
      return 'Email sudah terdaftar.';
    }
    return null;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      StudentDemoAccount(
        fullName: _nameController.text.trim(),
        nim: _nimController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }
}
