import '../../domain/entities/connection.dart';

class ConnectionModel extends Connection {
  const ConnectionModel({
    required super.departure,
    required super.destination,
    required super.price,
  });

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    final coordinates = _firstMap(json, ['coordinates']);
    final from = _firstMap(json, ['departure', 'from', 'origin', 'source']);
    final to = _firstMap(json, ['destination', 'arrival', 'to', 'target']);
    final departureName = _firstString(json, ['departure_city', 'departureCity', 'from_city', 'origin_city'])
        ?? _firstString(json, ['from'])
        ?? _firstString(from, ['city', 'name', 'city_name', 'label']);
    final destinationName = _firstString(json, ['destination_city', 'destinationCity', 'to_city', 'arrival_city'])
        ?? _firstString(json, ['to'])
        ?? _firstString(to, ['city', 'name', 'city_name', 'label']);
    if (departureName == null || destinationName == null) {
      throw const FormatException('Connection is missing departure or destination city.');
    }
    final price = _firstNumber(json, ['price', 'cost', 'fare', 'ticket_price']);
    if (price == null) throw const FormatException('Connection is missing a numeric price.');

    final departureCoordinates = _firstMap(coordinates, ['from']);
    final destinationCoordinates = _firstMap(coordinates, ['to']);
    final depLat = _coordinate(json, from, ['departure_latitude', 'departure_lat', 'from_lat', 'origin_lat', 'departureLatitude'], ['latitude', 'lat'])
        ?? _firstNumber(departureCoordinates, ['latitude', 'lat']);
    final depLon = _coordinate(json, from, ['departure_longitude', 'departure_lon', 'from_lon', 'origin_lon', 'departureLongitude'], ['longitude', 'long', 'lon', 'lng'])
        ?? _firstNumber(departureCoordinates, ['longitude', 'long', 'lon', 'lng']);
    final destLat = _coordinate(json, to, ['destination_latitude', 'destination_lat', 'to_lat', 'arrival_lat', 'destinationLatitude'], ['latitude', 'lat'])
        ?? _firstNumber(destinationCoordinates, ['latitude', 'lat']);
    final destLon = _coordinate(json, to, ['destination_longitude', 'destination_lon', 'to_lon', 'arrival_lon', 'destinationLongitude'], ['longitude', 'long', 'lon', 'lng'])
        ?? _firstNumber(destinationCoordinates, ['longitude', 'long', 'lon', 'lng']);

    return ConnectionModel(
      departure: CityPoint(name: departureName, latitude: depLat ?? 0, longitude: depLon ?? 0),
      destination: CityPoint(name: destinationName, latitude: destLat ?? 0, longitude: destLon ?? 0),
      price: price,
    );
  }
}

Map<String, dynamic> _firstMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map) return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

double? _firstNumber(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
  }
  return null;
}

double? _coordinate(
  Map<String, dynamic> root,
  Map<String, dynamic> nested,
  List<String> rootKeys,
  List<String> nestedKeys,
) =>
    _firstNumber(root, rootKeys) ?? _firstNumber(nested, nestedKeys);
