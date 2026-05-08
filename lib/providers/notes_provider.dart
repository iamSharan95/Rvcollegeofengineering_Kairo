import 'package:flutter/material.dart';
import '../models/note.dart';

class NotesProvider with ChangeNotifier {
  final List<Note> _notes = [
    Note(
      id: '1',
      title: 'Product Sync Transcript',
      content: 'Discussion about the new UI for Kairo...',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      type: NoteType.transcript,
    ),
    Note(
      id: '2',
      title: 'Groceries List',
      content: 'Milk, Eggs, Bread...',
      date: DateTime.now().subtract(const Duration(days: 1)),
      type: NoteType.personal,
    ),
  ];

  List<Note> get transcripts =>
      _notes.where((n) => n.type == NoteType.transcript).toList();
  List<Note> get personalNotes =>
      _notes.where((n) => n.type == NoteType.personal).toList();

  void addNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }
}
