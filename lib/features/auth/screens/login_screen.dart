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

  final void Function(
    UserRole role, {
    String? studentName,
    String? teacherName,
  })
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
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF2F5F5)),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8E8)),
                    boxShadow: [
                      BoxShadow(
                        color: ProjectNexusColors.ink.withValues(alpha: 0.055),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(26, 26, 26, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildBrand(),
                          const SizedBox(height: 28),
                          Text(
                            'Masuk ke akun',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: ProjectNexusColors.ink,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.35,
                                ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Gunakan akun sekolah untuk melanjutkan.',
                            style: TextStyle(
                              color: ProjectNexusColors.muted,
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 23),
                          const Text(
                            'Peran akun',
                            style: TextStyle(
                              color: ProjectNexusColors.ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              side: const BorderSide(
                                color: ProjectNexusColors.border,
                              ),
                            ),
                          ),
                          const SizedBox(height: 17),
                          TextFormField(
                            key: const Key('login_email'),
                            controller: _identifierController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.username],
                            decoration: InputDecoration(
                              labelText: _selectedRole == UserRole.student
                                  ? 'Email, NIM, atau username'
                                  : 'Email sekolah',
                              hintText: _selectedRole == UserRole.student
                                  ? 'nama@sekolah.sch.id / NIM / username'
                                  : 'nama@sekolah.sch.id',
                              prefixIcon: Icon(
                                _selectedRole == UserRole.student
                                    ? Icons.person_search_outlined
                                    : Icons.mail_outline_rounded,
                              ),
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
                              } else if (!_isValidStudentIdentifier(
                                identifier,
                              )) {
                                return 'Masukkan email, NIM, atau username yang valid.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            key: const Key('login_password'),
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) => _submit(),
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
                            validator: (value) {
                              if ((value ?? '').length < 6) {
                                return 'Kata sandi minimal 6 karakter.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildLoginHint(),
                          const SizedBox(height: 18),
                          FilledButton(
                            key: const Key('login_submit'),
                            onPressed: _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: ProjectNexusColors.tealDark,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            child: const Text('Masuk'),
                          ),
                          const SizedBox(height: 13),
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
                                  child: const Text('Daftar siswa'),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'Akun guru dikelola oleh administrator sekolah.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ProjectNexusColors.muted,
                                fontSize: 11,
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

  Widget _buildBrand() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: ProjectNexusColors.tealDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.hub_rounded, color: Colors.white, size: 23),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ProjectNexus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ProjectNexusColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                'RUANG KOLABORASI SEKOLAH',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ProjectNexusColors.muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginHint() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: ProjectNexusColors.muted,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Siswa dapat masuk dengan email, NIM, atau username. Guru menggunakan email sekolah.',
              style: TextStyle(
                color: ProjectNexusColors.muted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
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
