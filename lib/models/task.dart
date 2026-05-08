class KairoTask {
  final String id;
  final String title;
  final bool isCompleted;
  final bool isPriority;
  final DateTime createdAt;
  final String source; // e.g., "Meeting: Strategy Sync"

  KairoTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.isPriority = false,
    required this.createdAt,
    required this.source,
  });

  KairoTask copyWith({bool? isCompleted, bool? isPriority}) {
    return KairoTask(
      id: id,
      title: title,
      isCompleted: isCompleted ?? this.isCompleted,
      isPriority: isPriority ?? this.isPriority,
      createdAt: createdAt,
      source: source,
    );
  }
}
