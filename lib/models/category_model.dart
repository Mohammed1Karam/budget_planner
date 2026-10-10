/// Which side of the ledger a category or an operation sits on.
enum OperationType { expense, income }

/// A spending or earning category. The Figma board draws each one as an emoji
/// in a tinted square next to its name, so the emoji is the icon.
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.type,
  });

  final String id;
  final String name;
  final String emoji;
  final OperationType type;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '💳',
      type: json['type'] == 'income'
          ? OperationType.income
          : OperationType.expense,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'emoji': emoji,
        'type': type.name,
      };

  CategoryModel copyWith({String? name, String? emoji, OperationType? type}) {
    return CategoryModel(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      type: type ?? this.type,
    );
  }
}
