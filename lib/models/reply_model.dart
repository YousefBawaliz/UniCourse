// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Reply {
  final String id;
  final String text;
  final DateTime createdAt;
  final String username;
  final String profilePic;
  final String commentID;
  Reply({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.username,
    required this.profilePic,
    required this.commentID,
  });

  Reply copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? username,
    String? profilePic,
    String? commentID,
  }) {
    return Reply(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      commentID: commentID ?? this.commentID,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'username': username,
      'profilePic': profilePic,
      'commentID': commentID,
    };
  }

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'] as String,
      text: map['text'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      username: map['username'] as String,
      profilePic: map['profilePic'] as String,
      commentID: map['commentID'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Reply.fromJson(String source) =>
      Reply.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Reply(id: $id, text: $text, createdAt: $createdAt, username: $username, profilePic: $profilePic, commentID: $commentID)';
  }

  @override
  bool operator ==(covariant Reply other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.text == text &&
        other.createdAt == createdAt &&
        other.username == username &&
        other.profilePic == profilePic &&
        other.commentID == commentID;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        text.hashCode ^
        createdAt.hashCode ^
        username.hashCode ^
        profilePic.hashCode ^
        commentID.hashCode;
  }
}
