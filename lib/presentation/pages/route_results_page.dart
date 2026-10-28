import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/connection.dart';
import '../bloc/trip_bloc.dart';

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
            final points = <CityPoint>[];
            if (route.legs.isNotEmpty) {
              points.add(route.legs.first.departure);
              points.addAll(route.legs.map((leg) => leg.destination));
            }
            final validPoints = points.where(_hasCoordinates).toList();
            final coordinates = validPoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList();
            final routeSegments = buildFlightRouteSegments(coordinates);
            final flightPath = <LatLng>[];
            for (final segment in routeSegments) {
              flightPath.addAll(
                flightPath.isEmpty ? segment : segment.skip(1),
              );
            }
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
                SizedBox(
                  height: 270,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: validPoints.length < 2
                        ? const ColoredBox(
                            color: Color(0xFFE8F1F5),
                            child: Center(
                                child: Text(
                                    'Map coordinates are not available in the API response.')))
                        : FlutterMap(
                            options: MapOptions(
                              initialCameraFit: CameraFit.coordinates(
                                coordinates: flightPath,
                                padding: const EdgeInsets.all(48),
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.tui_mobility_hub',
                              ),
                              PolylineLayer(polylines: [
                                Polyline(
                                  points: flightPath,
                                  strokeWidth: 12,
                                  color: const Color(0xB3001D42),
                                  strokeCap: StrokeCap.round,
                                  strokeJoin: StrokeJoin.round,
                                ),
                                Polyline(
                                  points: flightPath,
                                  strokeWidth: 8,
                                  color: Colors.white,
                                  strokeCap: StrokeCap.round,
                                  strokeJoin: StrokeJoin.round,
                                ),
                                Polyline(
                                  points: flightPath,
                                  strokeWidth: 5,
                                  gradientColors: const [
                                    Color(0xFF38BDF8),
                                    Color(0xFF2563EB),
                                    Color(0xFF7C3AED),
                                  ],
                                  strokeCap: StrokeCap.round,
                                  strokeJoin: StrokeJoin.round,
                                ),
                              ]),
                              MarkerLayer(
                                markers: [
                                  for (final segment in routeSegments)
                                    _directionMarker(segment),
                                ],
                              ),
                              MarkerLayer(
                                markers:
                                    validPoints.asMap().entries.map((entry) {
                                  final isStart = entry.key == 0;
                                  final isDestination =
                                      entry.key == validPoints.length - 1;
                                  final point = entry.value;
                                  return Marker(
                                    point:
                                        LatLng(point.latitude, point.longitude),
                                    width: isStart || isDestination ? 150 : 44,
                                    height: 72,
                                    alignment: Alignment.bottomCenter,
                                    child: _RouteMapMarker(
                                      label: isStart
                                          ? 'Start · ${point.name}'
                                          : isDestination
                                              ? 'End · ${point.name}'
                                              : 'Stop ${entry.key}',
                                      color: isStart
                                          ? const Color(0xFF16834A)
                                          : isDestination
                                              ? const Color(0xFFD43F45)
                                              : const Color(0xFF1769FF),
                                      icon: isStart
                                          ? Icons.flight_takeoff_rounded
                                          : isDestination
                                              ? Icons.flag_rounded
                                              : Icons.sync_alt_rounded,
                                      compact: !isStart && !isDestination,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                  ),
                ),
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

List<List<LatLng>> buildFlightRouteSegments(
  List<LatLng> waypoints, {
  int samplesPerLeg = 32,
}) {
  if (samplesPerLeg < 2) {
    throw ArgumentError.value(
      samplesPerLeg,
      'samplesPerLeg',
      'Must be at least 2.',
    );
  }
  if (waypoints.length < 2) return const [];

  const distance = Distance(roundResult: false);
  return [
    for (var index = 0; index < waypoints.length - 1; index++)
      _greatCircleSegment(
        waypoints[index],
        waypoints[index + 1],
        distance,
        samplesPerLeg,
      ),
  ];
}

List<LatLng> _greatCircleSegment(
  LatLng start,
  LatLng end,
  Distance distance,
  int samplesPerLeg,
) {
  final length = distance.distance(start, end);
  final bearing = distance.bearing(start, end);
  return [
    for (var index = 0; index <= samplesPerLeg; index++)
      index == 0
          ? start
          : index == samplesPerLeg
              ? end
              : distance.offset(
                  start,
                  length * index / samplesPerLeg,
                  bearing,
                ),
  ];
}

Marker _directionMarker(List<LatLng> segment) {
  final midpointIndex = segment.length ~/ 2;
  final midpoint = segment[midpointIndex];
  final nextPoint = segment[midpointIndex + 1];
  final bearing =
      const Distance(roundResult: false).bearing(midpoint, nextPoint);

  return Marker(
    point: midpoint,
    width: 34,
    height: 34,
    child: Transform.rotate(
      angle: bearing * math.pi / 180,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF2563EB), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40001D42),
              blurRadius: 7,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.navigation_rounded,
          size: 19,
          color: Color(0xFF2563EB),
        ),
      ),
    ),
  );
}

bool _hasCoordinates(CityPoint point) =>
    point.latitude.isFinite &&
    point.longitude.isFinite &&
    point.latitude >= -90 &&
    point.latitude <= 90 &&
    point.longitude >= -180 &&
    point.longitude <= 180 &&
    (point.latitude != 0 || point.longitude != 0);

class _RouteMapMarker extends StatelessWidget {
  const _RouteMapMarker({
    required this.label,
    required this.color,
    required this.icon,
    required this.compact,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 146),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Icon(icon, color: color, size: 34, shadows: const [
          Shadow(color: Colors.white, blurRadius: 5),
        ]),
      ],
    );
  }
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
