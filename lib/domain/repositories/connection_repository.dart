import '../entities/connection.dart';

abstract interface class ConnectionRepository {
  Future<List<Connection>> getConnections();
  Future<List<City>> getCities();
}
