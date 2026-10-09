import 'package:flutter/material.dart';

import '../../../core/theme/project_nexus_colors.dart';
import '../models/student_demo_account.dart';
import '../models/user_role.dart';
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
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: _AuthBackdrop()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: wide ? 28 : 18,
                      vertical: 22,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: _buildLoginCard(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF456A83).withValues(alpha: 0.16),
            blurRadius: 38,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 25, 26, 18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _AuthIllustration(),
              const SizedBox(height: 21),
              Text(
                'Selamat datang kembali!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ProjectNexusColors.ink,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.55,
                  fontSize: 23,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Masuk untuk melanjutkan petualanganmu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 19),
              const Text(
                'Masuk sebagai',
                style: TextStyle(
                  color: ProjectNexusColors.ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
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
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.comfortable,
                  selectedBackgroundColor: const Color(0xFFDCE9FF),
                  selectedForegroundColor: ProjectNexusColors.tealDark,
                  side: const BorderSide(color: Color(0xFFDDE5EA)),
                  shape: const StadiumBorder(),
                ),
              ),
              const SizedBox(height: 13),
              TextFormField(
                key: const Key('login_email'),
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autocorrect: false,
                autofillHints: const [AutofillHints.username],
                decoration: _fieldDecoration(
                  label: _selectedRole == UserRole.student
                      ? 'Email, NIM, atau username'
                      : 'Email sekolah',
                  hint: _selectedRole == UserRole.student
                      ? 'Masukkan akun sekolahmu'
                      : 'nama@sekolah.sch.id',
                  icon: _selectedRole == UserRole.student
                      ? Icons.person_outline_rounded
                      : Icons.mail_outline_rounded,
                ),
                validator: (value) {
                  final identifier = value?.trim() ?? '';
                  if (identifier.isEmpty) {
                    return _selectedRole == UserRole.student
                        ? 'Masukkan email, NIM, atau username.'
                        : 'Masukkan alamat email yang valid.';
                  }
                  if (_selectedRole == UserRole.teacher) {
                    if (!_isValidEmail(identifier)) {
                      return 'Masukkan alamat email yang valid.';
                    }
                  } else if (!_isValidStudentIdentifier(identifier)) {
                    return 'Masukkan email, NIM, atau username yang valid.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 11),
              TextFormField(
                key: const Key('login_password'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: _fieldDecoration(
                  label: 'Kata sandi',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Tampilkan kata sandi'
                        : 'Sembunyikan kata sandi',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
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
              const SizedBox(height: 11),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: ProjectNexusColors.muted,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      _selectedRole == UserRole.student
                          ? 'Siswa dapat masuk dengan email, NIM, atau username.'
                          : 'Guru menggunakan email sekolah yang terdaftar.',
                      style: const TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 48,
                child: FilledButton(
                  key: const Key('login_submit'),
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: ProjectNexusColors.teal,
                    elevation: 3,
                    shadowColor: ProjectNexusColors.teal.withValues(alpha: 0.3),
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text('Masuk'),
                ),
              ),
              const SizedBox(height: 6),
              if (_selectedRole == UserRole.student)
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun?',
                      style: TextStyle(
                        color: ProjectNexusColors.muted,
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      key: const Key('open_registration'),
                      onPressed: _openRegistration,
                      child: const Text('Daftar sekarang'),
                    ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Akun guru dikelola oleh administrator sekolah.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ProjectNexusColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    OutlineInputBorder border({
      Color color = const Color(0xFFDDE5EA),
      double width = 1,
    }) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(color: ProjectNexusColors.teal, width: 1.6),
      errorBorder: border(color: const Color(0xFFBA3B35)),
      focusedErrorBorder: border(color: const Color(0xFFBA3B35), width: 1.6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFD9EBFF), Color(0xFFF1F0FF), Color(0xFFDDF8EF)],
            ),
          ),
        ),
        Positioned(
          top: -110,
          left: -95,
          child: _BackdropShape(size: 300, color: Colors.white, opacity: 0.24),
        ),
        Positioned(
          bottom: -150,
          right: -75,
          child: _BackdropShape(
            size: 360,
            color: const Color(0xFF8EDFC7),
            opacity: 0.19,
          ),
        ),
        Positioned(
          top: 110,
          right: 32,
          child: Icon(
            Icons.auto_awesome,
            size: 23,
            color: Colors.white.withValues(alpha: 0.76),
          ),
        ),
        Positioned(
          bottom: 110,
          left: 32,
          child: Icon(
            Icons.auto_awesome,
            size: 17,
            color: const Color(0xFFFFD58A).withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _BackdropShape extends StatelessWidget {
  const _BackdropShape({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _AuthIllustration extends StatelessWidget {
  const _AuthIllustration();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ilustrasi siswa berkolaborasi mengembangkan ide',
      child: Container(
        height: 142,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE7F1FF), Color(0xFFE8F8F3)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -40,
              right: -22,
              child: _BackdropShape(
                size: 125,
                color: Colors.white,
                opacity: 0.52,
              ),
            ),
            Positioned(
              left: 27,
              bottom: 15,
              child: _IllustratedStudent(
                color: const Color(0xFF42B89B),
                skin: const Color(0xFFEAB792),
                icon: Icons.lightbulb_outline_rounded,
              ),
            ),
            Positioned(
              right: 28,
              bottom: 15,
              child: _IllustratedStudent(
                color: const Color(0xFF637DE0),
                skin: const Color(0xFFD89B77),
                icon: Icons.code_rounded,
              ),
            ),
            Positioned(
              bottom: 10,
              child: Container(
                width: 116,
                height: 49,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFD8E4EE)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F314D69),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hub_rounded,
                      size: 20,
                      color: ProjectNexusColors.teal,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'IDE + TIM',
                      style: TextStyle(
                        color: ProjectNexusColors.ink,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 20,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFEDB34E),
                size: 21,
              ),
            ),
            const Positioned(
              top: 28,
              left: 82,
              child: Icon(Icons.circle, color: Color(0xFF85B7F2), size: 8),
            ),
            const Positioned(
              top: 36,
              right: 83,
              child: Icon(Icons.circle, color: Color(0xFF7FCDB6), size: 7),
            ),
          ],
        ),
      ),
    );
  }
}

class _IllustratedStudent extends StatelessWidget {
  const _IllustratedStudent({
    required this.color,
    required this.skin,
    required this.icon,
  });

  final Color color;
  final Color skin;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 62,
      height: 85,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: skin,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(Icons.face_rounded, size: 20, color: color),
          ),
          Container(
            width: 48,
            height: 42,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
                bottom: Radius.circular(8),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 21),
          ),
        ],
      ),
    );
  }
}
