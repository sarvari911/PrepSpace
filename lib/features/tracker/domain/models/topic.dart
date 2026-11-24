import 'topic_status.dart';

class Topic {
  final String id;
  final String title;
  final String? description;
  final TopicStatus status;
  final DateTime? completedAt;
  final DateTime createdAt;

  const Topic({
    required this.id,
    required this.title,
    this.description,
    this.status = TopicStatus.notStarted,
    this.completedAt,
    required this.createdAt,
  });

  bool get isCompleted => status == TopicStatus.completed;

  Topic copyWith({
    String? id,
    String? title,
    String? description,
    TopicStatus? status,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toJson(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TopicStatus.fromString(json['status'] as String?),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Topic &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          status == other.status;

  @override
  int get hashCode => Object.hash(id, title, description, status);
}
