import '../entities/connection.dart';
import '../repositories/connection_repository.dart';

class GetCities {
  const GetCities(this.repository);
  final ConnectionRepository repository;
  Future<List<City>> call() => repository.getCities();
}
