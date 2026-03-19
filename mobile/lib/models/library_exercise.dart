class LibraryExercise {
  final String id;
  final String name;
  final String muscleGroup;
  final String category; // Superior, Inferior, Core

  LibraryExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'muscle_group': muscleGroup,
    'category': category,
  };

  factory LibraryExercise.fromMap(Map<String, dynamic> map) => LibraryExercise(
    id: map['id'],
    name: map['name'],
    muscleGroup: map['muscle_group'] ?? '',
    category: map['category'] ?? 'Superior',
  );
}
