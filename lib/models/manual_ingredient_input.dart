class ManualIngredientInput {
  final String id;
  final String namaProduk;
  final List<String> ingredientIds;
  final DateTime createdAt;

  const ManualIngredientInput({
    required this.id,
    required this.namaProduk,
    required this.ingredientIds,
    required this.createdAt,
  });
}