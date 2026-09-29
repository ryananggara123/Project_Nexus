import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLogin, super.key});

  final ValueChanged<UserRole> onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBrand(),
                    const SizedBox(height: 36),
                    Text(
                      'Selamat datang kembali',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: ProjectNexusColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Masuk untuk melanjutkan kolaborasi dan proyekmu.',
                      style: TextStyle(
                        color: ProjectNexusColors.muted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Masuk sebagai',
                      style: TextStyle(
                        color: ProjectNexusColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<UserRole>(
                      key: const Key('login_role_selector'),
                      segments: const [
                        ButtonSegment(
                          value: UserRole.student,
                          label: Text('Siswa'),
                          icon: Icon(Icons.school_outlined),
                        ),
                        ButtonSegment(
                          value: UserRole.teacher,
                          label: Text('Guru'),
                          icon: Icon(Icons.co_present_outlined),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (selection) {
                        setState(() => _selectedRole = selection.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      key: const Key('login_email'),
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'nama@sekolah.sch.id',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty || !email.contains('@')) {
                          return 'Masukkan alamat email yang valid.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      key: const Key('login_password'),
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        labelText: 'Kata sandi',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
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
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 6) {
                          return 'Kata sandi minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEAD5B5)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 19,
                            color: Color(0xFF94602A),
                          ),
                          SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              'Mode demo: akun belum diverifikasi Firebase. Gunakan email dan kata sandi valid untuk melihat alur aplikasi.',
                              style: TextStyle(
                                color: Color(0xFF76532F),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      key: const Key('login_submit'),
                      onPressed: _submit,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Masuk'),
                      style: FilledButton.styleFrom(
                        backgroundColor: ProjectNexusColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
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

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ProjectNexusColors.teal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 27),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ProjectNexus',
              style: TextStyle(
                color: ProjectNexusColors.ink,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              'RUANG KOLABORASI SISWA',
              style: TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onLogin(_selectedRole);
  }
}
