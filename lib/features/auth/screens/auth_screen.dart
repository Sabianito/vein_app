import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../routing/vein_router.dart';
import '../../../providers/app_session.dart';
import '../../../core/theme/vein_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.session});

  final AppSession session;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _displayName = TextEditingController();

  bool _isLogin = true;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _displayName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final session = widget.session;
    final result = _isLogin
        ? await session.login(email: _email.text, password: _password.text)
        : await session.signUp(
            email: _email.text,
            password: _password.text,
            displayName: _displayName.text,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.ok) {
      Navigator.of(context).pushReplacementNamed(VeinRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Something went wrong')),
      );
    }
  }

  Future<void> _guest() async {
    setState(() => _busy = true);
    await widget.session.loginAsGuest();
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).pushReplacementNamed(VeinRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Center(
              child: Image.asset(
                'assets/images/vv.png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ).animate().fadeIn(duration: 220.ms),
            const SizedBox(height: 16),
            Text(
              _isLogin ? 'Welcome back' : 'Create your profile',
              style: t.headlineSmall?.copyWith(
                letterSpacing: 0.6,
                fontWeight: FontWeight.w600,
              ),
            ).animate().fadeIn(duration: 220.ms),
            const SizedBox(height: 8),
            Text(
              _isLogin
                  ? 'Sign in to keep your progress synced on this device.'
                  : 'Simple offline login. No internet required.',
              style: t.bodyMedium?.copyWith(
                color: VeinTheme.cream.withValues(alpha: 0.78),
                height: 1.3,
              ),
            ).animate().fadeIn(delay: 60.ms, duration: 220.ms),
            const SizedBox(height: 22),
            if (!_isLogin) ...[
              TextField(
                controller: _displayName,
                textInputAction: TextInputAction.next,
                style: const TextStyle(letterSpacing: 0.2),
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  hintText: 'e.g. Mia',
                ),
              ).animate().fadeIn(delay: 80.ms, duration: 200.ms),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(letterSpacing: 0.2),
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'you@example.com',
              ),
            ).animate().fadeIn(delay: 90.ms, duration: 200.ms),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _busy ? null : _submit(),
              style: const TextStyle(letterSpacing: 0.2),
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: '\u2022\u2022\u2022\u2022',
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 200.ms),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: AnimatedSwitcher(
                  duration: 160.ms,
                  child: _busy
                      ? const SizedBox(
                          key: ValueKey('busy'),
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _isLogin ? 'Sign in' : 'Create account',
                          key: const ValueKey('idle'),
                          style: const TextStyle(letterSpacing: 0.6),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Create account' : 'I have an account',
                      style: const TextStyle(letterSpacing: 0.4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: VeinTheme.cream.withValues(alpha: 0.15)),
                color: VeinTheme.maroonDeep.withValues(alpha: 0.25),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Try the demo',
                    style: t.titleMedium?.copyWith(letterSpacing: 0.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore everything as a guest. Progress stays on this device.',
                    style: t.bodyMedium?.copyWith(
                      color: VeinTheme.cream.withValues(alpha: 0.76),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _busy ? null : _guest,
                      child: const Text(
                        'Login as Guest',
                        style: TextStyle(letterSpacing: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 140.ms, duration: 220.ms),
          ],
        ),
      ),
    );
  }
}
