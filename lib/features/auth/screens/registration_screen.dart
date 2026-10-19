import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/student_demo_account.dart';
import '../widgets/auth_widgets.dart';

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
    return Scaffold(
      backgroundColor: ProjectNexusColors.surface,
      appBar: AppBar(backgroundColor: ProjectNexusColors.surface),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AuthHeading(
                      title: 'Buat akun siswa',
                      subtitle:
                          'Bergabung dan mulai berkolaborasi di ProjectNexus.',
                    ),
                    const SizedBox(height: 28),
                    const FieldLabel('Nama lengkap'),
                    TextFormField(
                      key: const Key('registration_name'),
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Nama sesuai data sekolah',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Nama lengkap wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('NIM'),
                    TextFormField(
                      key: const Key('registration_nim'),
                      controller: _nimController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'contoh: 2413025074',
                      ),
                      validator: _validateNim,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Username'),
                    TextFormField(
                      key: const Key('registration_username'),
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'huruf, angka, titik, _ atau -',
                      ),
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Email'),
                    TextFormField(
                      key: const Key('registration_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'nama@sekolah.sch.id',
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Kata sandi'),
                    TextFormField(
                      key: const Key('registration_password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: 'Minimal 6 karakter',
                        suffixIcon: PasswordVisibilityButton(
                          obscured: _obscurePassword,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 6
                          ? 'Kata sandi minimal 6 karakter.'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Ulangi kata sandi'),
                    TextFormField(
                      key: const Key('registration_confirm_password'),
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmation,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Ketik ulang kata sandi',
                        suffixIcon: PasswordVisibilityButton(
                          obscured: _obscureConfirmation,
                          onPressed: () => setState(
                            () => _obscureConfirmation = !_obscureConfirmation,
                          ),
                        ),
                      ),
                      validator: (value) => value != _passwordController.text
                          ? 'Konfirmasi kata sandi tidak cocok.'
                          : null,
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      key: const Key('registration_submit'),
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('Buat akun'),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Akun hanya tersimpan selama aplikasi berjalan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
