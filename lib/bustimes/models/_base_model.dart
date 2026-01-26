abstract class BaseModel {
  factory BaseModel.buildFromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap must be implemented in subclasses');
  }

  Map<String, dynamic> toMap();
}
