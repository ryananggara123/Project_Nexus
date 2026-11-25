import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../data/account_service.dart';
import '../widgets/auth_widgets.dart';

/// Form registrasi siswa. Bila berhasil, layar ditutup dengan data
/// registrasinya agar layar login dapat mengisi NIM secara otomatis.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({required this.accounts, super.key});

  final AccountService accounts;

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
  bool _busy = false;

  /// Kesalahan dari server (misalnya NIM sudah dipakai), ditampilkan di kolom
  /// terkait sampai isinya diubah.
  final Map<AccountField, String> _serverErrors = {};

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
      backgroundColor: ProjectNexusColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: AuthBackdrop(
        child: SafeArea(
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
                        subtitle: 'Bergabung dan mulai berkolaborasi di ProjectNexus.',
                        onDark: true,
                      ),
                      const SizedBox(height: 28),
                      AuthCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                              onChanged: (_) =>
                                  _serverErrors.remove(AccountField.nim),
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
                              onChanged: (_) =>
                                  _serverErrors.remove(AccountField.username),
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
                              onChanged: (_) =>
                                  _serverErrors.remove(AccountField.email),
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
                              onChanged: (_) =>
                                  _serverErrors.remove(AccountField.password),
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
                              validator: (value) =>
                                  value == null || value.length < 6
                                  ? 'Kata sandi minimal 6 karakter.'
                                  : _serverErrors[AccountField.password],
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
                                    () => _obscureConfirmation =
                                        !_obscureConfirmation,
                                  ),
                                ),
                              ),
                              validator: (value) =>
                                  value != _passwordController.text
                                  ? 'Konfirmasi kata sandi tidak cocok.'
                                  : null,
                            ),
                            const SizedBox(height: 28),
                            FilledButton(
                              key: const Key('registration_submit'),
                              onPressed: _busy ? null : _submit,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                              ),
                              child: _busy
                                  ? const SizedBox.square(
                                      dimension: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Buat akun'),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.accounts.storageNote,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: ProjectNexusColors.muted,
                                fontSize: 12,
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
    return _serverErrors[AccountField.nim];
  }

  String? _validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (!RegExp(r'^[a-zA-Z0-9._-]{3,30}$').hasMatch(username)) {
      return 'Username 3–30 karakter: huruf, angka, titik, _ atau -.';
    }
    return _serverErrors[AccountField.username];
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Masukkan alamat email yang valid.';
    }
    return _serverErrors[AccountField.email];
  }

  Future<void> _submit() async {
    _serverErrors.clear();
    if (_busy || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final StudentRegistration registration = (
      fullName: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    setState(() => _busy = true);
    try {
      await widget.accounts.register(registration);
      if (mounted) Navigator.pop(context, registration);
    } on AccountException catch (error) {
      if (!mounted) return;
      final field = error.field;
      if (field == null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.message)));
      } else {
        _serverErrors[field] = error.message;
        _formKey.currentState!.validate();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
