class Post {
  final int? id;
  final String title;
  final String content;

  Post({this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'content': content};
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(id: map['id'], title: map['title'], content: map['content']);
  }
}
