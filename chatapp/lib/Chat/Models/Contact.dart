import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:chatapp/Chat/Models/Message.dart';

class Contact {
  final int id;
  bool isDeleted;
  DateTime deletedLast;
  final ToUser touser;
  List<Message> messages;
  Contact({
    required this.id,
    required this.isDeleted,
    required this.deletedLast,
    required this.touser,
    required this.messages,
  });

  Contact copyWith({
    int? id,
    bool? isDeleted,
    DateTime? deletedLast,
    ToUser? touser,
    List<Message>? messages,
  }) {
    return Contact(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedLast: deletedLast ?? this.deletedLast,
      touser: touser ?? this.touser,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isDeleted': isDeleted,
      'deletedLast': deletedLast.millisecondsSinceEpoch,
      'touser': touser.toMap(),
      'messages': messages.map((x) => x.toMap()).toList(),
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      isDeleted: map['is_deleted'],
      deletedLast: DateTime.parse(map['deleted_last']),
      touser: ToUser.fromMap(map['touser']),
      messages:
          List<Message>.from(map['message']?.map((x) => Message.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Contact.fromJson(String source) =>
      Contact.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Contact(id: $id, isDeleted: $isDeleted, deletedLast: $deletedLast, touser: $touser, messages: $messages)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Contact &&
        other.id == id &&
        other.isDeleted == isDeleted &&
        other.deletedLast == deletedLast &&
        other.touser == touser &&
        listEquals(other.messages, messages);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isDeleted.hashCode ^
        deletedLast.hashCode ^
        touser.hashCode ^
        messages.hashCode;
  }
}

class ToUser {
  final int id;
  final String username;
  final Status status;
  ToUser({
    required this.id,
    required this.username,
    required this.status,
  });
  

  ToUser copyWith({
    int? id,
    String? username,
    Status? status,
  }) {
    return ToUser(
      id: id ?? this.id,
      username: username ?? this.username,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'status': status.toMap(),
    };
  }

  factory ToUser.fromMap(Map<String, dynamic> map) {
    return ToUser(
      id: map['id'],
      username: map['username'],
      status: Status.fromMap(map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ToUser.fromJson(String source) => ToUser.fromMap(json.decode(source));

  @override
  String toString() => 'ToUser(id: $id, username: $username, status: $status)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ToUser &&
      other.id == id &&
      other.username == username &&
      other.status == status;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ status.hashCode;
}

class Status {
  final int id;
  bool online;
  DateTime lastSeen;
  Status({
    required this.id,
    required this.online,
    required this.lastSeen,
  });

  Status copyWith({
    int? id,
    bool? online,
    DateTime? lastSeen,
  }) {
    return Status(
      id: id ?? this.id,
      online: online ?? this.online,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'online': online,
      'lastSeen': lastSeen.millisecondsSinceEpoch,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      id: map['id'],
      online: map['online']>0,
      lastSeen: DateTime.parse(map['lastseen']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Status.fromJson(String source) => Status.fromMap(json.decode(source));

  @override
  String toString() => 'Status(id: $id, online: $online, lastSeen: $lastSeen)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Status &&
        other.id == id &&
        other.online == online &&
        other.lastSeen == lastSeen;
  }

  @override
  int get hashCode => id.hashCode ^ online.hashCode ^ lastSeen.hashCode;
}
