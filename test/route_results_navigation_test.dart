import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/domain/entities/connection.dart';
import 'package:tui_mobility_hub/domain/repositories/connection_repository.dart';
import 'package:tui_mobility_hub/domain/usecases/find_cheapest_route.dart';
import 'package:tui_mobility_hub/domain/usecases/get_cities.dart';
import 'package:tui_mobility_hub/domain/usecases/get_connections.dart';
import 'package:tui_mobility_hub/presentation/bloc/trip_bloc.dart';
import 'package:tui_mobility_hub/presentation/pages/home_page.dart';
import 'package:tui_mobility_hub/presentation/pages/route_results_page.dart';

void main() {
  testWidgets('route results page shares the trip bloc', (tester) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repository = _FakeConnectionRepository();
    final bloc = TripBloc(
      getConnections: GetConnections(repository),
      getCities: GetCities(repository),
      findCheapestRoute: const FindCheapestRoute(),
    )..add(const TripStarted());
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Find cheapest route'));
    await tester.pumpAndSettle();

    expect(find.text('Your cheapest route'), findsOneWidget);
  });

  testWidgets('shows an explanation when no route exists', (tester) async {
    final repository = _FakeConnectionRepository();
    final bloc = TripBloc(
      getConnections: GetConnections(repository),
      getCities: GetCities(repository),
      findCheapestRoute: const FindCheapestRoute(),
    );
    addTearDown(bloc.close);

    final loaded =
        bloc.stream.firstWhere((state) => state.status == TripStatus.loaded);
    bloc.add(const TripStarted());
    await loaded;

    final noRoute = bloc.stream.firstWhere((state) => state.routeNotFound);
    bloc.add(const RouteRequested('B', 'A'));
    await noRoute;

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: const RouteResultsPage(),
        ),
      ),
    );

    expect(find.text('No route found'), findsOneWidget);
    expect(
      find.text('There is no available connection from B to A.'),
      findsOneWidget,
    );
    expect(find.text('Change cities'), findsOneWidget);
  });
}

class _FakeConnectionRepository implements ConnectionRepository {
  static const _cities = [City(name: 'A'), City(name: 'B')];
  static const _connections = [
    Connection(
      departure: CityPoint(name: 'A', latitude: 10, longitude: 10),
      destination: CityPoint(name: 'B', latitude: 20, longitude: 20),
      price: 25,
    ),
  ];

  @override
  Future<List<City>> getCities() async => _cities;

  @override
  Future<List<Connection>> getConnections() async => _connections;
}
