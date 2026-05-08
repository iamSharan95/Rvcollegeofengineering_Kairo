import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/notes_provider.dart';
import '../providers/meeting_assistant_provider.dart';
import '../providers/auth_provider.dart';
import '../models/note.dart';
import 'package:intl/intl.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("New Personal Note", style: GoogleFonts.instrumentSerif(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "Title",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            TextField(
              controller: contentController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Start writing...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CANCEL", style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isNotEmpty) {
                      final newNote = Note(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: titleController.text,
                        content: contentController.text,
                        date: DateTime.now(),
                        type: NoteType.personal,
                      );
                      Provider.of<NotesProvider>(context, listen: false).addNote(newNote);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A2E1A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text("SAVE NOTE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final assistant = Provider.of<MeetingAssistantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: authProvider.user?.photoURL != null 
                ? NetworkImage(authProvider.user!.photoURL!) 
                : null,
            child: authProvider.user?.photoURL == null ? const Icon(Icons.person_outline, size: 20) : null,
          ),
        ),
        title: Text("Hub", style: GoogleFonts.instrumentSerif(
          fontSize: 24, fontStyle: FontStyle.italic, color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hub", style: GoogleFonts.instrumentSerif(fontSize: 36, color: Colors.black)),
                Text("Manage your knowledge base", 
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF1A2E1A),
            indicatorWeight: 1,
            dividerColor: Colors.transparent,
            labelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
            tabs: const [
              Tab(text: "TRANSCRIPTS"),
              Tab(text: "KNOWLEDGE"),
            ],
          ),
          
          Expanded(
            child: Consumer<NotesProvider>(
              builder: (context, provider, child) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReportList(provider.transcripts),
                    _buildReportList(provider.personalNotes),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: const Color(0xFF1A2E1A),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_comment_outlined, color: Colors.white),
      ),
    );
  }


  void _showNoteDetail(Note note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: note.type == NoteType.transcript ? Colors.blue.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      note.type == NoteType.transcript ? "TRANSCRIPT" : "PERSONAL",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: note.type == NoteType.transcript ? Colors.blue.shade800 : Colors.green.shade800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(DateFormat('MMM dd, yyyy').format(note.date), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              Text(note.title, style: GoogleFonts.instrumentSerif(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              Text(
                note.content,
                style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.black87),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportList(List<Note> reports) {
    if (reports.isEmpty) return const Center(child: Text("No entries recorded."));
    
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return GestureDetector(
          onTap: () => _showNoteDetail(report),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('MMM dd').format(report.date), style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 12),
                Text(report.title, style: GoogleFonts.instrumentSerif(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  report.content, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text("View Detail >", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade400)),
              ],
            ),
          ),
        );
      },
    );
  }
}
