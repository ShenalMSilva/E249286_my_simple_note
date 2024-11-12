class Note {
  int? id;
  String title;
  String content;

  Note({this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }

  Note.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        content = map['content'];
}