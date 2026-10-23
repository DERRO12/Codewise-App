import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/mock/mock_repositories.dart';
import '../data/repositories.dart';
import '../routes.dart';
import '../state/auth_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

String? _validateEmail(String? v) {
  if (v == null || v.trim().isEmpty) return 'Enter your email';
  if (!_emailPattern.hasMatch(v.trim())) return 'Enter a valid email address';
  return null;
}

String? _validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Enter your password';
  if (v.length < 6) return 'Password must be at least 6 characters';
  return null;
}

void _goHome(BuildContext context) =>
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (_) => false);

class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: IconButton(
          tooltip: _hidden ? 'Show password' : 'Hide password',
          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.red),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LogoMark(size: 52),
        const SizedBox(height: 22),
        Text(title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: AppColors.grey)),
        const SizedBox(height: 26),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({required this.text, required this.action, required this.onTap});

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text.rich(TextSpan(children: [
          TextSpan(text: '$text ', style: const TextStyle(color: AppColors.grey)),
          TextSpan(
              text: action,
              style: const TextStyle(
                  color: AppColors.yellow, fontWeight: FontWeight.w700)),
        ])),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    setState(() => _error = null);
    try {
      await context
          .read<AuthController>()
          .logIn(email: _email.text, password: _password.text);
      if (mounted) _goHome(context);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  Future<void> _google() async {
    setState(() => _error = null);
    await context.read<AuthController>().signInWithGoogle();
    if (mounted) _goHome(context);
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text);
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your email and we'll send you a reset link.",
                style: TextStyle(color: AppColors.grey)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Send link')),
        ],
      ),
    );
    controller.dispose();
    if (email == null || !mounted) return;
    if (_validateEmail(email) != null) {
      showSnack(context, 'Enter a valid email address.');
      return;
    }
    try {
      await context.read<AuthController>().sendPasswordReset(email);
      if (mounted) showSnack(context, 'Reset link sent to ${email.trim()}.');
    } on AuthException catch (e) {
      if (mounted) showSnack(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AuthHeader(
                    title: 'Welcome back',
                    subtitle: 'Log in to continue learning'),
                if (_error != null) _ErrorBanner(_error!),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                _PasswordField(
                  controller: _password,
                  hint: 'Password',
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _submit,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot password?'),
                  ),
                ),
                const SizedBox(height: 6),
                ElevatedButton(
                  onPressed: busy ? null : _submit,
                  child: busy ? const ButtonSpinner() : const Text('LOG IN'),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or', style: TextStyle(color: AppColors.grey)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: busy ? null : _google,
                  icon: const Text('G',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18)),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 18),
                _FooterLink(
                  text: 'New here?',
                  action: 'Create account',
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(Routes.signUp),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo account: ${MockAuthRepository.demoEmail} / ${MockAuthRepository.demoPassword}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agreed = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final valid = _form.currentState!.validate();
    if (!valid) return;
    if (!_agreed) {
      setState(() => _error = 'Please agree to the Terms & Privacy to continue.');
      return;
    }
    setState(() => _error = null);
    try {
      await context.read<AuthController>().signUp(
            name: _name.text,
            email: _email.text,
            password: _password.text,
          );
      if (mounted) _goHome(context);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final busy = context.watch<AuthController>().busy;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AuthHeader(
                    title: 'Create account',
                    subtitle: 'Start learning to code today'),
                if (_error != null) _ErrorBanner(_error!),
                TextFormField(
                  controller: _name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(hintText: 'Full name'),
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? 'Enter your full name'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                _PasswordField(
                  controller: _password,
                  hint: 'Password',
                  validator: _validatePassword,
                ),
                const SizedBox(height: 14),
                _PasswordField(
                  controller: _confirm,
                  hint: 'Confirm password',
                  textInputAction: TextInputAction.done,
                  onSubmitted: _submit,
                  validator: (v) =>
                      v != _password.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _agreed,
                        onChanged: (v) => setState(() => _agreed = v ?? false),
                      ),
                      const Expanded(
                        child: Text('I agree to the Terms & Privacy',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: busy ? null : _submit,
                  child: busy ? const ButtonSpinner() : const Text('SIGN UP'),
                ),
                const SizedBox(height: 14),
                _FooterLink(
                  text: 'Already have an account?',
                  action: 'Log in',
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(Routes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
