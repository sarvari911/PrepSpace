import 'module.dart';
import 'topic.dart';

class Subject {
  final String id;
  final String title;
  final String subtitle;
  final int iconCodePoint;
  final String? iconFontFamily;
  final int colorValue;
  final List<Module> modules;

  const Subject({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.colorValue,
    this.modules = const [],
  });

  int get totalTopics => modules.fold(0, (sum, m) => sum + m.totalTopics);

  int get completedTopics =>
      modules.fold(0, (sum, m) => sum + m.completedTopics);

  double get progress =>
      totalTopics == 0 ? 0.0 : (completedTopics / totalTopics).clamp(0.0, 1.0);

  Subject copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? iconCodePoint,
    String? iconFontFamily,
    int? colorValue,
    List<Module>? modules,
  }) {
    return Subject(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      colorValue: colorValue ?? this.colorValue,
      modules: modules ?? this.modules,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': colorValue,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String?,
      colorValue: json['colorValue'] as int,
      modules: (json['modules'] as List<dynamic>?)
              ?.map((m) => Module.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Subject withAddedModule(Module newModule) {
    return copyWith(modules: [...modules, newModule]);
  }

  Subject withUpdatedModule(Module updatedModule) {
    final updatedModules = modules.map((m) {
      return m.id == updatedModule.id ? updatedModule : m;
    }).toList();
    return copyWith(modules: updatedModules);
  }

  Subject withDeletedModule(String moduleId) {
    return copyWith(
      modules: modules.where((m) => m.id != moduleId).toList(),
    );
  }

  Subject withUpdatedTopic({
    required String moduleId,
    required Topic updatedTopic,
  }) {
    final updatedModules = modules.map((m) {
      if (m.id != moduleId) return m;
      final updatedTopics = m.topics.map((t) {
        return t.id == updatedTopic.id ? updatedTopic : t;
      }).toList();
      return m.copyWith(topics: updatedTopics);
    }).toList();
    return copyWith(modules: updatedModules);
  }

  Subject withAddedTopic({
    required String moduleId,
    required Topic newTopic,
  }) {
    final updatedModules = modules.map((m) {
      if (m.id != moduleId) return m;
      return m.copyWith(topics: [...m.topics, newTopic]);
    }).toList();
    return copyWith(modules: updatedModules);
  }

  Subject withDeletedTopic({
    required String moduleId,
    required String topicId,
  }) {
    final updatedModules = modules.map((m) {
      if (m.id != moduleId) return m;
      return m.copyWith(
        topics: m.topics.where((t) => t.id != topicId).toList(),
      );
    }).toList();
    return copyWith(modules: updatedModules);
  }
}
