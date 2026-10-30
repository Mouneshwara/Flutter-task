import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/domain/entities/connection.dart';
import 'package:tui_mobility_hub/domain/repositories/connection_repository.dart';
import 'package:tui_mobility_hub/domain/usecases/find_cheapest_route.dart';
import 'package:tui_mobility_hub/domain/usecases/get_cities.dart';
import 'package:tui_mobility_hub/domain/usecases/get_connections.dart';
import 'package:tui_mobility_hub/presentation/bloc/trip_bloc.dart';

void main() {
  test('loads data and finds a route through multiple states', () async {
    final bloc = _createBloc(_FakeConnectionRepository());
    addTearDown(bloc.close);

    final loading = _nextState(bloc, TripStatus.loading);
    final loaded = _nextState(bloc, TripStatus.loaded);
    bloc.add(const TripStarted());

    expect((await loading).status, TripStatus.loading);
    final loadedState = await loaded;
    expect(loadedState.cities.map((city) => city.name), ['A', 'B', 'C']);
    expect(loadedState.connections, hasLength(2));

    final searching = _nextState(bloc, TripStatus.searching);
    final routeLoaded = _nextState(
      bloc,
      TripStatus.loaded,
      where: (state) => state.route != null,
    );
    bloc.add(const RouteRequested('A', 'C'));

    expect((await searching).status, TripStatus.searching);
    final result = await routeLoaded;
    expect(result.route?.totalPrice, 30);
    expect(result.route?.legs.map((leg) => leg.departure.name), ['A', 'B']);
  });

  test('reports when no route exists', () async {
    final bloc = _createBloc(_FakeConnectionRepository());
    addTearDown(bloc.close);
    await _load(bloc);

    final result = _nextState(
      bloc,
      TripStatus.loaded,
      where: (state) => state.routeNotFound,
    );
    bloc.add(const RouteRequested('C', 'A'));

    final state = await result;
    expect(state.route, isNull);
    expect(state.routeNotFound, isTrue);
    expect(state.departure, 'C');
    expect(state.destination, 'A');
  });

  test('emits a failure state when the API repository throws', () async {
    final bloc = _createBloc(
      _FakeConnectionRepository(error: Exception('API unavailable')),
    );
    addTearDown(bloc.close);
    final loading = _nextState(bloc, TripStatus.loading);
    final failure = _nextState(bloc, TripStatus.failure);
    bloc.add(const TripStarted());

    expect((await loading).status, TripStatus.loading);
    final state = await failure;
    expect(state.errorMessage, contains('API unavailable'));
  });
}

TripBloc _createBloc(ConnectionRepository repository) => TripBloc(
      getConnections: GetConnections(repository),
      getCities: GetCities(repository),
      findCheapestRoute: const FindCheapestRoute(),
    );

Future<TripState> _nextState(
  TripBloc bloc,
  TripStatus status, {
  bool Function(TripState state)? where,
}) =>
    bloc.stream
        .firstWhere(
            (state) => state.status == status && (where?.call(state) ?? true))
        .timeout(const Duration(seconds: 2));

Future<void> _load(TripBloc bloc) async {
  final loaded = _nextState(bloc, TripStatus.loaded);
  bloc.add(const TripStarted());
  await loaded;
}

class _FakeConnectionRepository implements ConnectionRepository {
  _FakeConnectionRepository({this.error});

  final Object? error;

  static const _cities = [
    City(name: 'A'),
    City(name: 'B'),
    City(name: 'C'),
  ];
  static const _connections = [
    Connection(
      departure: CityPoint(name: 'A', latitude: 10, longitude: 10),
      destination: CityPoint(name: 'B', latitude: 20, longitude: 20),
      price: 10,
    ),
    Connection(
      departure: CityPoint(name: 'B', latitude: 20, longitude: 20),
      destination: CityPoint(name: 'C', latitude: 30, longitude: 30),
      price: 20,
    ),
  ];

  @override
  Future<List<City>> getCities() async {
    if (error case final Object exception) throw exception;
    return _cities;
  }

  @override
  Future<List<Connection>> getConnections() async {
    if (error case final Object exception) throw exception;
    return _connections;
  }
}
