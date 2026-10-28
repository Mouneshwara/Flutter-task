import '../entities/connection.dart';
import '../repositories/connection_repository.dart';

class GetConnections {
  const GetConnections(this.repository);
  final ConnectionRepository repository;
  Future<List<Connection>> call() => repository.getConnections();
}
