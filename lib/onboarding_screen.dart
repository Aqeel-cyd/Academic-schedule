import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  final User user;
  const OnboardingScreen({super.key, required this.user});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final id = TextEditingController();
  final section = TextEditingController();

  bool saving = false;

  Future<void> save() async {
    if (id.text.trim().isEmpty || section.text.trim().isEmpty) return;
    setState(() => saving = true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .set({
          'name': widget.user.displayName ?? '',
          'email': widget.user.email ?? '',
          'studentId': id.text.trim(),
          'section': section.text.trim().toUpperCase(),

          'role': 'student',
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete your profile'),
        actions: [
          TextButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Welcome, ${widget.user.displayName ?? ''}'),
          const SizedBox(height: 16),
          TextField(
            controller: id,
            decoration: const InputDecoration(
              labelText: 'Student ID',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: section,
            decoration: const InputDecoration(
              labelText: 'Lab Group (e.g. CE 04)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          saving
              ? const Center(child: CircularProgressIndicator())
              : FilledButton(onPressed: save, child: const Text('Save')),
        ],
      ),
    );
  }
}
