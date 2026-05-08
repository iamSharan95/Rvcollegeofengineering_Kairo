import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mail_provider.dart';
import '../models/email.dart';
import 'package:intl/intl.dart';

class MailScreen extends StatelessWidget {
  const MailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kairo Mail", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {
            Provider.of<MailProvider>(context, listen: false).fetchEmails();
          }),
        ],
      ),
      body: Consumer<MailProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.separated(
            itemCount: provider.emails.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
            itemBuilder: (context, index) {
              final email = provider.emails[index];
              return _EmailTile(email: email);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeDialog(context),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  void _showComposeDialog(BuildContext context) {
    final toController = TextEditingController();
    final subjectController = TextEditingController();
    final bodyController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Compose", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: toController, decoration: const InputDecoration(hintText: "To", border: InputBorder.none)),
            const Divider(),
            TextField(controller: subjectController, decoration: const InputDecoration(hintText: "Subject", border: InputBorder.none)),
            const Divider(),
            TextField(
              controller: bodyController,
              maxLines: 8,
              decoration: const InputDecoration(hintText: "Start writing...", border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<MailProvider>(context, listen: false).sendEmail(
                      toController.text,
                      subjectController.text,
                      bodyController.text,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("SEND"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _EmailTile extends StatelessWidget {
  final Email email;

  const _EmailTile({required this.email});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;

    switch (email.category) {
      case EmailCategory.travel:
        icon = Icons.flight_takeoff;
        iconColor = Colors.orange;
        break;
      case EmailCategory.meeting:
        icon = Icons.video_call;
        iconColor = Colors.blue;
        break;
      case EmailCategory.tech:
        icon = Icons.terminal;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.mail_outline;
        iconColor = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(email.sender, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(email.subject, style: const TextStyle(color: Colors.black87)),
          if (email.category == EmailCategory.travel && !email.isActioned)
            _smartActionChip(context, "Add to Calendar & Book Ride", () {
              Provider.of<MailProvider>(context, listen: false).markActioned(email.id);
            }),
        ],
      ),
      trailing: Text(DateFormat('hh:mm a').format(email.date), style: const TextStyle(fontSize: 12)),
      isThreeLine: email.category == EmailCategory.travel,
      onTap: () {},
    );
  }

  Widget _smartActionChip(BuildContext context, String label, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ActionChip(
        avatar: const Icon(Icons.auto_fix_high, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        onPressed: onAction,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}
