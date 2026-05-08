enum NoteType { transcript, personal }

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final NoteType type;
  final List<String> attachments; // URLs or file paths

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.type,
    this.attachments = const [],
  });
}
