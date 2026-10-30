import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/domain/entities/connection.dart';
import 'package:tui_mobility_hub/domain/repositories/connection_repository.dart';
import 'package:tui_mobility_hub/domain/usecases/find_cheapest_route.dart';
import 'package:tui_mobility_hub/domain/usecases/get_cities.dart';
import 'package:tui_mobility_hub/domain/usecases/get_connections.dart';
import 'package:tui_mobility_hub/main.dart';

void main() {
  testWidgets('shows the app and destinations', (tester) async {
    final repository = _FakeConnectionRepository();

    await tester.pumpWidget(
      TuiMobilityApp(
        getConnections: GetConnections(repository),
        getCities: GetCities(repository),
        findCheapestRoute: const FindCheapestRoute(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TUI Mobility Hub'), findsOneWidget);
    expect(find.text('Explore destinations'), findsOneWidget);
    expect(find.text('London'), findsWidgets);
    expect(find.text('Paris'), findsWidgets);
  });

  testWidgets('retry loads destinations after an API error', (tester) async {
    final repository = _RetryConnectionRepository();

    await tester.pumpWidget(
      TuiMobilityApp(
        getConnections: GetConnections(repository),
        getCities: GetCities(repository),
        findCheapestRoute: const FindCheapestRoute(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not connect to the local API'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Explore destinations'), findsOneWidget);
    expect(find.text('London'), findsWidgets);
  });
}

class _FakeConnectionRepository implements ConnectionRepository {
  static const _cities = [
    City(name: 'London'),
    City(name: 'Paris'),
  ];
  static const _connections = [
    Connection(
      departure: CityPoint(name: 'London', latitude: 51.5, longitude: -0.1),
      destination: CityPoint(name: 'Paris', latitude: 48.8, longitude: 2.3),
      price: 42,
    ),
  ];

  @override
  Future<List<City>> getCities() async => _cities;

  @override
  Future<List<Connection>> getConnections() async => _connections;
}

class _RetryConnectionRepository extends _FakeConnectionRepository {
  var _hasFailed = false;

  @override
  Future<List<City>> getCities() async {
    _throwFirstRequestError();
    return super.getCities();
  }

  @override
  Future<List<Connection>> getConnections() async {
    _throwFirstRequestError();
    return super.getConnections();
  }

  void _throwFirstRequestError() {
    if (_hasFailed) return;
    _hasFailed = true;
    throw Exception('API unavailable');
  }
}
