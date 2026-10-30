import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection.dart';
import '../bloc/trip_bloc.dart';
import '../widgets/journey_route_map.dart';

class RouteResultsPage extends StatelessWidget {
  const RouteResultsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Your cheapest route')),
        body: BlocBuilder<TripBloc, TripState>(
          builder: (context, state) {
            if (state.status == TripStatus.searching) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.routeNotFound || state.route == null) {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.route_outlined,
                      size: 64, color: Colors.blueGrey),
                  const SizedBox(height: 16),
                  const Text('No route found',
                      style:
                          TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      'There is no available connection from ${state.departure ?? 'the selected city'} to ${state.destination ?? 'your destination'}.',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 18),
                  FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Change cities')),
                ]),
              ));
            }
            final route = state.route!;
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                      color: const Color(0xFF075985),
                      borderRadius: BorderRadius.circular(22)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHEAPEST TOTAL PRICE',
                            style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(_money(route.totalPrice),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(height: 8),
                        Text('${state.departure}  →  ${state.destination}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        const SizedBox(height: 10),
                        Text(
                            '${route.legs.length} ${route.legs.length == 1 ? 'leg' : 'legs'} · Lowest total fare found',
                            style: const TextStyle(color: Colors.white70)),
                      ]),
                ),
                const SizedBox(height: 22),
                Text('Journey map',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                JourneyRouteMap(legs: route.legs),
                const SizedBox(height: 22),
                Text('Journey details',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...route.legs.asMap().entries.map((entry) => _LegCard(
                    index: entry.key + 1,
                    connection: entry.value,
                    isLast: entry.key == route.legs.length - 1)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: const Text('Change journey')),
              ],
            );
          },
        ),
      );
}

class _LegCard extends StatelessWidget {
  const _LegCard(
      {required this.index, required this.connection, required this.isLast});
  final int index;
  final Connection connection;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Card(
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                backgroundColor: const Color(0xFFD9F1F2),
                child: Text('$index',
                    style: const TextStyle(
                        color: Color(0xFF075985),
                        fontWeight: FontWeight.bold))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(connection.departure.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Icon(Icons.south_rounded,
                          size: 18, color: Color(0xFF087E8B))),
                  Text(connection.destination.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Text(isLast ? 'Final leg' : 'Connection / transfer',
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 12)),
                ])),
            const SizedBox(width: 8),
            Text(_money(connection.price),
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ]),
        )),
      );
}

String _money(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(2);
