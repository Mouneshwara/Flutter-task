import '../../domain/entities/connection.dart';
import '../../domain/repositories/connection_repository.dart';
import '../datasources/mobility_remote_data_source.dart';

class ConnectionRepositoryImpl implements ConnectionRepository {
  const ConnectionRepositoryImpl(this.remoteDataSource);
  final MobilityRemoteDataSource remoteDataSource;

  @override
  Future<List<City>> getCities() => remoteDataSource.fetchCities();

  @override
  Future<List<Connection>> getConnections() => remoteDataSource.fetchConnections();
}
