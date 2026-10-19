import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/student_demo_account.dart';
import '../models/user_role.dart';
import '../widgets/auth_widgets.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    required this.onLogin,
    required this.onRegister,
    required this.studentAccounts,
    super.key,
  });

  final void Function(UserRole role, {String? studentName, String? teacherName})
  onLogin;
  final ValueChanged<StudentDemoAccount> onRegister;
  final List<StudentDemoAccount> studentAccounts;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = _selectedRole == UserRole.student;

    return Scaffold(
      backgroundColor: ProjectNexusColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BrandMark(),
                    ),
                    const SizedBox(height: 40),
                    const AuthHeading(
                      title: 'Selamat datang kembali!',
                      subtitle: 'Masuk untuk melanjutkan kolaborasi timmu.',
                    ),
                    const SizedBox(height: 28),
                    PillSwitch<UserRole>(
                      key: const Key('login_role_selector'),
                      options: const {
                        UserRole.student: 'Siswa',
                        UserRole.teacher: 'Guru',
                      },
                      selected: _selectedRole,
                      onChanged: (role) => setState(() => _selectedRole = role),
                    ),
                    const SizedBox(height: 24),
                    FieldLabel(
                      isStudent ? 'Email, NIM, atau username' : 'Email sekolah',
                    ),
                    TextFormField(
                      key: const Key('login_email'),
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        hintText: isStudent
                            ? 'contoh: 2413025074'
                            : 'nama@sekolah.sch.id',
                        prefixIcon: Icon(
                          isStudent
                              ? Icons.person_outline_rounded
                              : Icons.mail_outline_rounded,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        final identifier = value?.trim() ?? '';
                        if (identifier.isEmpty) {
                          return isStudent
                              ? 'Masukkan email, NIM, atau username.'
                              : 'Masukkan alamat email yang valid.';
                        }
                        if (!isStudent) {
                          if (!_isValidEmail(identifier)) {
                            return 'Masukkan alamat email yang valid.';
                          }
                        } else if (!_isValidStudentIdentifier(identifier)) {
                          return 'Masukkan email, NIM, atau username yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    const FieldLabel('Kata sandi'),
                    TextFormField(
                      key: const Key('login_password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'Minimal 6 karakter',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                        ),
                        suffixIcon: PasswordVisibilityButton(
                          obscured: _obscurePassword,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Kata sandi minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      key: const Key('login_submit'),
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: const Text('Masuk'),
                    ),
                    const SizedBox(height: 16),
                    if (isStudent)
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun?',
                            style: TextStyle(
                              color: ProjectNexusColors.muted,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            key: const Key('open_registration'),
                            onPressed: _openRegistration,
                            child: const Text('Daftar'),
                          ),
                        ],
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Akun guru dikelola oleh administrator sekolah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ProjectNexusColors.muted,
                            fontSize: 13,
                          ),
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

  Future<void> _openRegistration() async {
    final account = await Navigator.of(context).push<StudentDemoAccount>(
      MaterialPageRoute(
        builder: (context) =>
            RegistrationScreen(existingAccounts: widget.studentAccounts),
      ),
    );
    if (account == null || !mounted) return;

    widget.onRegister(account);
    setState(() {
      _selectedRole = UserRole.student;
      _identifierController.text = account.nim;
    });
    _showMessage(
      const SnackBar(
        content: Text(
          'Akun berhasil dibuat. Masuk menggunakan NIM atau username.',
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    if (_selectedRole == UserRole.student) {
      final identifier = _identifierController.text.trim();
      StudentDemoAccount? account;
      for (final candidate in widget.studentAccounts) {
        if (candidate.matchesIdentifier(identifier)) {
          account = candidate;
          break;
        }
      }

      if (account != null && account.password != _passwordController.text) {
        _showMessage(const SnackBar(content: Text('Kata sandi tidak sesuai.')));
        return;
      }
      if (account == null && widget.studentAccounts.isNotEmpty) {
        _showMessage(
          const SnackBar(
            content: Text('Akun siswa tidak ditemukan. Periksa data masuk.'),
          ),
        );
        return;
      }

      widget.onLogin(_selectedRole, studentName: account?.fullName);
      return;
    }

    widget.onLogin(
      _selectedRole,
      teacherName: _teacherNameForEmail(_identifierController.text.trim()),
    );
  }

  void _showMessage(SnackBar message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(message);
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidStudentIdentifier(String value) {
    return _isValidEmail(value) ||
        RegExp(r'^\d{6,20}$').hasMatch(value) ||
        RegExp(r'^[a-zA-Z0-9._-]{3,30}$').hasMatch(value);
  }

  String _teacherNameForEmail(String email) {
    return email.toLowerCase() == 'siti.rahmawati@school.id'
        ? 'Siti Rahmawati'
        : 'Budi Santoso';
  }
}
