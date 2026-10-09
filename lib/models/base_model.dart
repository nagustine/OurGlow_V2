abstract class BaseModel {
  const BaseModel();

  Map<String, dynamic> toJson();
  String get identifier;
}