class Folder {
  final String id;
  final String name;
  final List<Set> sets;
  final DateTime createdAt;

  Folder({
    required this.id,
    required this.name,
    required this.sets,
    required this.createdAt,
  });

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as String,
      name: map['name'] as String,
      sets: (map['sets'] as List?)?.map((e) => Set.fromMap(e)).toList() ?? [],
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sets': sets.map((e) => e.toMap()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Set {
  final String id;
  final String title;
  final List<String> cardIds; // ID карточек из learning_cards
  final int colorIndex;
  final DateTime createdAt;

  Set({
    required this.id,
    required this.title,
    required this.cardIds,
    required this.colorIndex,
    required this.createdAt,
  });

  factory Set.fromMap(Map<String, dynamic> map) {
    return Set(
      id: map['id'] as String,
      title: map['title'] as String,
      cardIds: List<String>.from(map['card_ids'] as List),
      colorIndex: map['color_index'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'card_ids': cardIds,
      'color_index': colorIndex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get termCount => cardIds.length;
}