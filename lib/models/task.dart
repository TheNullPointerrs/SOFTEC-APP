class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final bool isCompleted;
  final String? colorCode;
  final String parentId; // This will store the parent task's ID or '-' if it's a parent task.

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
    this.colorCode,
    this.parentId = '-', // Default to '-' if it's a parent task.
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    bool? isCompleted,
    String? colorCode,
    String? parentId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      colorCode: colorCode ?? this.colorCode,
      parentId: parentId ?? this.parentId, // Ensure parentId is passed correctly
    );
  }
}
