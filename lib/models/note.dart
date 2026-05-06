
class Note {
  final int? id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt; 
  final String? colorHex;
  final String? tags;

  const Note({
    this.id,
    required this.title,
    required this.content,
    this.colorHex,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

 Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'colorHex': colorHex,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      colorHex: map['colorHex'],
      tags: map['tags'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}