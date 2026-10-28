import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/domain/entities/connection.dart';
import 'package:tui_mobility_hub/domain/usecases/find_cheapest_route.dart';

void main() {
  const finder = FindCheapestRoute();
  const a = CityPoint(name: 'A', latitude: 1, longitude: 1);
  const b = CityPoint(name: 'B', latitude: 2, longitude: 2);
  const c = CityPoint(name: 'C', latitude: 3, longitude: 3);
  const d = CityPoint(name: 'D', latitude: 4, longitude: 4);

  test('chooses cheapest multi-leg route over expensive direct route', () {
    const connections = [
      Connection(departure: a, destination: d, price: 200),
      Connection(departure: a, destination: b, price: 30),
      Connection(departure: b, destination: c, price: 25),
      Connection(departure: c, destination: d, price: 20),
    ];
    final result = finder(connections: connections, departure: 'A', destination: 'D');
    expect(result?.totalPrice, 75);
    expect(result?.legs.map((leg) => leg.departure.name).toList(), ['A', 'B', 'C']);
  });

  test('returns null when no route exists', () {
    final result = finder(connections: const [
      Connection(departure: a, destination: b, price: 10),
    ], departure: 'A', destination: 'D');
    expect(result, isNull);
  });

  test('returns null for same departure and destination', () {
    expect(finder(connections: const [], departure: 'A', destination: 'A'), isNull);
  });
}
