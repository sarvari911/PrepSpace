import 'topic.dart';

class Module {
  final String id;
  final String title;
  final String? description;
  final List<Topic> topics;

  const Module({
    required this.id,
    required this.title,
    this.description,
    this.topics = const [],
  });

  int get totalTopics => topics.length;
  int get completedTopics => topics.where((t) => t.isCompleted).length;
  double get progress => totalTopics == 0 ? 0.0 : completedTopics / totalTopics;

  Module copyWith({
    String? id,
    String? title,
    String? description,
    List<Topic>? topics,
  }) {
    return Module(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      topics: (json['topics'] as List<dynamic>?)
              ?.map((t) => Topic.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
