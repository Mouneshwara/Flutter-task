import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/data/models/connection_model.dart';

void main() {
  test('parses flat connection response', () {
    final connection = ConnectionModel.fromJson({
      'departure_city': 'London',
      'destination_city': 'Paris',
      'price': 75,
      'departure_latitude': 51.5,
      'departure_longitude': -0.1,
      'destination_latitude': 48.8,
      'destination_longitude': 2.3,
    });
    expect(connection.departure.name, 'London');
    expect(connection.destination.name, 'Paris');
    expect(connection.price, 75);
    expect(connection.departure.latitude, 51.5);
  });

  test('parses nested endpoint objects', () {
    final connection = ConnectionModel.fromJson({
      'departure': {'city': 'London', 'latitude': 51.5, 'longitude': -0.1},
      'destination': {'city': 'Paris', 'latitude': 48.8, 'longitude': 2.3},
      'price': '42.50',
    });
    expect(connection.price, 42.5);
    expect(connection.destination.longitude, 2.3);
  });

  test('parses local API endpoint and coordinate fields', () {
    final connection = ConnectionModel.fromJson({
      'from': 'London',
      'to': 'Tokyo',
      'price': 220,
      'coordinates': {
        'from': {'lat': 51.5285582, 'long': -0.241681},
        'to': {'lat': 35.652832, 'long': 139.839478},
      },
    });

    expect(connection.departure.name, 'London');
    expect(connection.destination.name, 'Tokyo');
    expect(connection.price, 220);
    expect(connection.departure.latitude, 51.5285582);
    expect(connection.departure.longitude, -0.241681);
    expect(connection.destination.latitude, 35.652832);
    expect(connection.destination.longitude, 139.839478);
  });
}
