import 'dart:collection';
import '../entities/connection.dart';

class RouteResult {
  const RouteResult({required this.legs, required this.totalPrice});
  final List<Connection> legs;
  final double totalPrice;
}

class FindCheapestRoute {
  const FindCheapestRoute();

  RouteResult? call({
    required List<Connection> connections,
    required String departure,
    required String destination,
  }) {
    if (departure == destination) return null;

    final graph = <String, List<Connection>>{};
    for (final connection in connections) {
      if (connection.price < 0) {
        throw ArgumentError('Connection prices must be non-negative.');
      }
      graph.putIfAbsent(connection.departure.name, () => []).add(connection);
    }

    final distances = <String, double>{departure: 0};
    final previous = <String, Connection>{};
    final queue = PriorityQueue<_QueueEntry>((a, b) => a.cost.compareTo(b.cost));
    queue.add(_QueueEntry(departure, 0));

    while (queue.isNotEmpty) {
      final current = queue.remove();
      if (current.cost != distances[current.city]) continue;
      if (current.city == destination) break;

      for (final edge in graph[current.city] ?? const <Connection>[]) {
        final nextCost = current.cost + edge.price;
        final oldCost = distances[edge.destination.name];
        if (oldCost == null || nextCost < oldCost) {
          distances[edge.destination.name] = nextCost;
          previous[edge.destination.name] = edge;
          queue.add(_QueueEntry(edge.destination.name, nextCost));
        }
      }
    }

    final total = distances[destination];
    if (total == null) return null;

    final legs = <Connection>[];
    var cursor = destination;
    while (cursor != departure) {
      final edge = previous[cursor];
      if (edge == null) return null;
      legs.add(edge);
      cursor = edge.departure.name;
    }
    return RouteResult(legs: legs.reversed.toList(), totalPrice: total);
  }
}

class _QueueEntry {
  const _QueueEntry(this.city, this.cost);
  final String city;
  final double cost;
}

class PriorityQueue<T> {
  PriorityQueue(this.compare);
  final int Function(T, T) compare;
  final List<T> _items = [];
  bool get isNotEmpty => _items.isNotEmpty;

  void add(T value) {
    _items.add(value);
    var i = _items.length - 1;
    while (i > 0) {
      final parent = (i - 1) ~/ 2;
      if (compare(_items[parent], value) <= 0) break;
      _items[i] = _items[parent];
      i = parent;
    }
    _items[i] = value;
  }

  T remove() {
    final result = _items.first;
    final last = _items.removeLast();
    if (_items.isNotEmpty) {
      var i = 0;
      while (true) {
        final left = i * 2 + 1;
        if (left >= _items.length) break;
        final right = left + 1;
        var smallest = left;
        if (right < _items.length && compare(_items[right], _items[left]) < 0) {
          smallest = right;
        }
        if (compare(last, _items[smallest]) <= 0) break;
        _items[i] = _items[smallest];
        i = smallest;
      }
      _items[i] = last;
    }
    return result;
  }
}
