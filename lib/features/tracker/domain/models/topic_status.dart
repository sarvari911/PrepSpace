enum TopicStatus {
  notStarted,
  inProgress,
  completed;

  String get displayName {
    switch (this) {
      case TopicStatus.notStarted:
        return 'Not Started';
      case TopicStatus.inProgress:
        return 'In Progress';
      case TopicStatus.completed:
        return 'Completed';
    }
  }

  static TopicStatus fromString(String? value) {
    switch (value) {
      case 'inProgress':
      case 'in_progress':
        return TopicStatus.inProgress;
      case 'completed':
        return TopicStatus.completed;
      default:
        return TopicStatus.notStarted;
    }
  }

  String toJson() => name;
}
