import 'package:equatable/equatable.dart';

class CityPoint extends Equatable {
  const CityPoint({required this.name, required this.latitude, required this.longitude});

  final String name;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [name, latitude, longitude];
}

class Connection extends Equatable {
  const Connection({
    required this.departure,
    required this.destination,
    required this.price,
  });

  final CityPoint departure;
  final CityPoint destination;
  final double price;

  @override
  List<Object?> get props => [departure, destination, price];
}

class City extends Equatable {
  const City({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  List<Object?> get props => [name, imageUrl];
}
