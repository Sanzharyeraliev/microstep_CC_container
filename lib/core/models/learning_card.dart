class LearningCardModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final int colorIndex;
  final String cardType;        // 'regular' or 'srs'
  final int srsInterval;        // дни до следующего повторения
  final double srsEaseFactor;   // фактор лёгкости (SM-2)
  final DateTime? srsReviewDate; // дата следующего повторения
  final int srsStreak;          // серия правильных ответов
  final DateTime createdAt;
  final DateTime updatedAt;

  LearningCardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.colorIndex,
    this.cardType = 'regular',
    this.srsInterval = 0,
    this.srsEaseFactor = 2.5,
    this.srsReviewDate,
    this.srsStreak = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LearningCardModel.fromMap(Map<String, dynamic> map) {
    return LearningCardModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      category: map['category'] as String,
      colorIndex: map['color_index'] as int,
      cardType: map['card_type'] as String? ?? 'regular',
      srsInterval: map['srs_interval'] as int? ?? 0,
      srsEaseFactor: (map['srs_ease_factor'] as num?)?.toDouble() ?? 2.5,
      srsReviewDate: map['srs_review_date'] != null 
          ? DateTime.parse(map['srs_review_date'] as String) 
          : null,
      srsStreak: map['srs_streak'] as int? ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'color_index': colorIndex,
      'card_type': cardType,
      'srs_interval': srsInterval,
      'srs_ease_factor': srsEaseFactor,
      'srs_review_date': srsReviewDate?.toIso8601String(),
      'srs_streak': srsStreak,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}