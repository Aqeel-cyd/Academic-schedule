import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'admin_screen.dart';
import 'app_background.dart';
import 'notification_service.dart';

const eventTypes = {
  'quiz': 'Quiz',
  'lab': 'Lab',
  'report_deadline': 'Lab report submission',
  'assignment': 'Assignment',
};

IconData iconFor(String t) => switch (t) {
      'quiz' => Icons.quiz,
      'lab' => Icons.science,
      'report_deadline' => Icons.description,
      _ => Icons.assignment,
    };

Color colorFor(String t) => switch (t) {
      'quiz' => Colors.orange,
      'lab' => Colors.teal,
      'report_deadline' => Colors.redAccent,
      _ => Colors.blue,
    };

String countdown(DateTime d) {
  final diff = d.difference(DateTime.now());
  if (diff.inDays >= 1) return 'in ${diff.inDays}d';
  if (diff.inHours >= 1) return 'in ${diff.inHours}h';
  return 'in ${diff.inMinutes.clamp(0, 59)}m';
}

class HomeScreen extends StatefulWidget {
  final User user;
  final Map<String, dynamic> profile;
  const HomeScreen({super.key, required this.user, required this.profile});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String filter = 'all';

  List<Map<String, dynamic>> _mine(QuerySnapshot<Map<String, dynamic>> snap) {
    final section = (widget.profile['section'] ?? '').toString();
    final now = DateTime.now();
    final out = <Map<String, dynamic>>[];
    for (final d in snap.docs) {
      final m = d.data();
      final when = (m['dateTime'] as Timestamp).toDate();
      final okSection = m['section'] == 'ALL' || m['section'] == section;
      if (okSection && when.isAfter(now)) {
        out.add({...m, 'id': d.id, 'dateTime': when});
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final adminStream =
        FirebaseFirestore.instance.collection('admins').doc(widget.user.uid).snapshots();
    return StreamBuilder<DocumentSnapshot>(
      stream: adminStream,
      builder: (context, adminSnap) {
        final isAdmin = adminSnap.data?.exists ?? false;
        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            title: Text('ID: ${widget.profile['studentId']}'),
            actions: [
              if (isAdmin)
                IconButton(
                  tooltip: 'Admin panel',
                  icon: const Icon(Icons.admin_panel_settings),
                  onPressed: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => AdminScreen(user: widget.user))),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 900.ms),
              IconButton(
                  icon: const Icon(Icons.logout), onPressed: () => FirebaseAuth.instance.signOut()),
            ],
          ),
          body: AppBackground(
            child: SafeArea(
              child: Column(children: [
                const SizedBox(height: 56),
                SizedBox(
                  height: 56,
                  child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      children: [
                        for (final e in {'all': 'All', ...eventTypes}.entries)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(e.value),
                              selected: filter == e.key,
                              backgroundColor: Colors.white.withOpacity(0.85),
                              selectedColor: Colors.amberAccent,
                              onSelected: (_) => setState(() => filter = e.key),
                            ),
                          ),
                      ]).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('events')
                        .orderBy('dateTime')
                        .snapshots(),
                    builder: (context, snap) {
                      if (snap.hasError) {
                        return Center(
                            child: Text('Error: ${snap.error}',
                                style: const TextStyle(color: Colors.white)));
                      }
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      final mine = _mine(snap.data!);
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => NotificationService.reschedule(mine));
                      final shown =
                          mine.where((e) => filter == 'all' || e['type'] == filter).toList();
                      if (shown.isEmpty) {
                        return Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: const [
                            Icon(Icons.celebration, size: 72, color: Colors.white70),
                            SizedBox(height: 12),
                            Text('Nothing upcoming!',
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                          ]).animate().fadeIn(duration: 600.ms).scale(),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: shown.length,
                        itemBuilder: (_, i) {
                          final e = shown[i];
                          final c = colorFor(e['type']);
                          final notes = (e['notes'] ?? '').toString();
                          return Card(
                            color: Colors.white.withOpacity(0.92),
                            elevation: 4,
                            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(color: c.withOpacity(0.6), width: 1.5),
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: c.withOpacity(0.15),
                                child: Icon(iconFor(e['type']), color: c),
                              ),
                              title: Text(e['title'] ?? '',
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  '${eventTypes[e['type']]}\n'
                                  '${DateFormat('EEE, d MMM y • h:mm a').format(e['dateTime'])}'
                                  '${notes.isEmpty ? '' : '\n$notes'}'),
                              isThreeLine: true,
                              trailing: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: c.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(countdown(e['dateTime']),
                                    style: TextStyle(color: c, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: (60 * (i > 8 ? 8 : i)).ms, duration: 450.ms)
                              .slideX(begin: 0.2, curve: Curves.easeOutCubic);
                        },
                      );
                    },
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
