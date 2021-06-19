import 'dart:convert';

class Message {
  final int id;
  final String message;
  final int touser;
  final int fromuser;
  bool seen;
  final DateTime createdAt;
  Message({
    required this.id,
    required this.message,
    required this.touser,
    required this.fromuser,
    required this.seen,
    required this.createdAt,
  });

  Message copyWith({
    int? id,
    String? message,
    int? touser,
    int? fromuser,
    bool? seen,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      message: message ?? this.message,
      touser: touser ?? this.touser,
      fromuser: fromuser ?? this.fromuser,
      seen: seen ?? this.seen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'touser': touser,
      'fromuser': fromuser,
      'seen': seen,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      message: map['message'],
      touser: map['touser'],
      fromuser: map['fromuser'],
      seen: map['seen_by_to_user'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Message(id: $id, message: $message, touser: $touser, fromuser: $fromuser, seen: $seen, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message &&
        other.id == id &&
        other.message == message &&
        other.touser == touser &&
        other.fromuser == fromuser &&
        other.seen == seen &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        message.hashCode ^
        touser.hashCode ^
        fromuser.hashCode ^
        seen.hashCode ^
        createdAt.hashCode;
  }
}
