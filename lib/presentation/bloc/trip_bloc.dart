import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection.dart';
import '../../domain/usecases/find_cheapest_route.dart';
import '../../domain/usecases/get_cities.dart';
import '../../domain/usecases/get_connections.dart';

sealed class TripEvent extends Equatable {
  const TripEvent();
  @override
  List<Object?> get props => [];
}
class TripStarted extends TripEvent { const TripStarted(); }
class TripRefreshed extends TripEvent { const TripRefreshed(); }
class RouteRequested extends TripEvent {
  const RouteRequested(this.departure, this.destination);
  final String departure;
  final String destination;
  @override
  List<Object?> get props => [departure, destination];
}

enum TripStatus { initial, loading, loaded, searching, failure }

class TripState extends Equatable {
  const TripState({
    this.status = TripStatus.initial,
    this.connections = const [],
    this.cities = const [],
    this.route,
    this.errorMessage,
    this.departure,
    this.destination,
    this.routeNotFound = false,
  });

  final TripStatus status;
  final List<Connection> connections;
  final List<City> cities;
  final RouteResult? route;
  final String? errorMessage;
  final String? departure;
  final String? destination;
  final bool routeNotFound;

  TripState copyWith({
    TripStatus? status,
    List<Connection>? connections,
    List<City>? cities,
    RouteResult? route,
    String? errorMessage,
    String? departure,
    String? destination,
    bool clearRoute = false,
    bool clearError = false,
    bool? routeNotFound,
  }) => TripState(
    status: status ?? this.status,
    connections: connections ?? this.connections,
    cities: cities ?? this.cities,
    route: clearRoute ? null : (route ?? this.route),
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    departure: departure ?? this.departure,
    destination: destination ?? this.destination,
    routeNotFound: routeNotFound ?? this.routeNotFound,
  );

  @override
  List<Object?> get props => [status, connections, cities, route, errorMessage, departure, destination, routeNotFound];
}

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc({
    required GetConnections getConnections,
    required GetCities getCities,
    required FindCheapestRoute findCheapestRoute,
  })  : _getConnections = getConnections,
        _getCities = getCities,
        _findCheapestRoute = findCheapestRoute,
        super(const TripState()) {
    on<TripStarted>(_load);
    on<TripRefreshed>(_load);
    on<RouteRequested>(_search);
  }

  final GetConnections _getConnections;
  final GetCities _getCities;
  final FindCheapestRoute _findCheapestRoute;

  Future<void> _load(TripEvent event, Emitter<TripState> emit) async {
    emit(state.copyWith(status: TripStatus.loading, clearError: true));
    try {
      final results = await Future.wait([_getConnections(), _getCities()]);
      final connections = results[0] as List<Connection>;
      var cities = results[1] as List<City>;
      if (cities.isEmpty) {
        final names = <String>{};
        for (final connection in connections) {
          names.add(connection.departure.name);
          names.add(connection.destination.name);
        }
        cities = names.map((name) => City(name: name)).toList()..sort((a, b) => a.name.compareTo(b.name));
      }
      emit(state.copyWith(status: TripStatus.loaded, connections: connections, cities: cities, clearError: true));
    } catch (error) {
      emit(state.copyWith(status: TripStatus.failure, errorMessage: error.toString()));
    }
  }

  void _search(RouteRequested event, Emitter<TripState> emit) {
    if (event.departure == event.destination) {
      emit(state.copyWith(status: TripStatus.loaded, errorMessage: 'Choose two different cities.', clearRoute: true, clearError: false));
      return;
    }
    emit(state.copyWith(status: TripStatus.searching, departure: event.departure, destination: event.destination, clearRoute: true, clearError: true, routeNotFound: false));
    try {
      final route = _findCheapestRoute(connections: state.connections, departure: event.departure, destination: event.destination);
      emit(state.copyWith(status: TripStatus.loaded, route: route, routeNotFound: route == null));
    } catch (error) {
      emit(state.copyWith(status: TripStatus.failure, errorMessage: error.toString()));
    }
  }
}
