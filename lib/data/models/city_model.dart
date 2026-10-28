import '../../domain/entities/connection.dart';

class CityModel extends City {
  const CityModel({required super.name, super.imageUrl});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    final name = _string(json, ['name', 'city', 'city_name', 'label']);
    if (name == null) throw const FormatException('City item has no city name.');
    return CityModel(
      name: name,
      imageUrl: _string(json, ['image_url', 'imageUrl', 'image', 'url']),
    );
  }
}

String? _string(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}
