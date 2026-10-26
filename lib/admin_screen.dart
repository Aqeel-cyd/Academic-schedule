import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'home_screen.dart';

class AdminScreen extends StatelessWidget {
  final User user;
  const AdminScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final col = FirebaseFirestore.instance.collection('events');
    return Scaffold(
      appBar: AppBar(title: const Text('Admin: manage events')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New event'),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => EventDialog(user: user),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: col.orderBy('dateTime').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];
              final m = d.data();
              final when = (m['dateTime'] as Timestamp).toDate();
              return ListTile(
                leading: Icon(iconFor(m['type'])),
                title: Text('${m['title']} (${m['section']})'),
                subtitle: Text(
                  DateFormat('EEE, d MMM y • h:mm a').format(when),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (_) =>
                            EventDialog(user: user, docId: d.id, existing: m),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => d.reference.delete(),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EventDialog extends StatefulWidget {
  final User user;
  final String? docId;
  final Map<String, dynamic>? existing;
  const EventDialog({super.key, required this.user, this.docId, this.existing});
  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final title = TextEditingController(
    text: widget.existing?['title'] ?? '',
  );

  late final section = TextEditingController(
    text: widget.existing?['section'] ?? 'ALL',
  );
  late final notes = TextEditingController(
    text: widget.existing?['notes'] ?? '',
  );
  late String type = widget.existing?['type'] ?? 'quiz';
  late DateTime when = widget.existing != null
      ? (widget.existing!['dateTime'] as Timestamp).toDate()
      : DateTime.now().add(const Duration(days: 1));

  Future<void> pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(when),
    );
    if (t == null) return;
    setState(() => when = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  Future<void> save() async {
    final data = {
      'type': type,
      'title': title.text.trim(),

      'section': section.text.trim().toUpperCase(), // use ALL for every section
      'dateTime': Timestamp.fromDate(when),
      'notes': notes.text.trim(),
      'createdBy': widget.user.uid,
    };
    final col = FirebaseFirestore.instance.collection('events');
    try {
      widget.docId == null
          ? await col.add(data)
          : await col.doc(widget.docId).update(data);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.docId == null ? 'New event' : 'Edit event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: type,
              items: [
                for (final e in eventTypes.entries)
                  DropdownMenuItem(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) => setState(() => type = v!),
              decoration: const InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: 'Title'),
            ),

            TextField(
              controller: section,
              decoration: const InputDecoration(
                labelText: 'Lab Groups (or ALL)',
              ),
            ),
            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: pickDateTime,
              icon: const Icon(Icons.calendar_month),
              label: Text(DateFormat('d MMM y • h:mm a').format(when)),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: save, child: const Text('Save')),
      ],
    );
  }
}
