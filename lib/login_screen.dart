import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  Future<void> signIn() async {
    setState(() => loading = true);
    try {
      final provider = GoogleAuthProvider();
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.35)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30)],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.event_available, size: 84, color: Colors.white)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.12, 1.12),
                        duration: 1600.ms,
                        curve: Curves.easeInOut),
                const SizedBox(height: 16),
                const Text('Schedule Tracker',
                        style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))
                    .animate()
                    .fadeIn(duration: 700.ms)
                    .slideY(begin: 0.4),
                const SizedBox(height: 8),
                const Text('Quizzes • Labs • Reports • Assignments',
                        textAlign: TextAlign.center, style: TextStyle(color: Colors.white70))
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 700.ms),
                const SizedBox(height: 32),
                (loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            ),
                            onPressed: signIn,
                            icon: const Icon(Icons.login),
                            label: const Text('Sign in with Google'),
                          ))
                    .animate()
                    .fadeIn(delay: 600.ms)
                    .slideY(begin: 0.5),
              ]),
            ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.92, 0.92)),
          ),
        ),
      ),
    );
  }
}
