import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tui_mobility_hub/presentation/widgets/journey_route_map.dart';

void main() {
  test('builds a smooth great-circle segment with its endpoints preserved', () {
    const start = LatLng(51.5, -0.1);
    const end = LatLng(35.65, 139.8);

    final segments = buildFlightRouteSegments([start, end]);
    final segment = segments.single;

    expect(segment.length, 33);
    expect(segment.first, start);
    expect(segment.last, end);
    expect(segment.any((point) => point != start && point != end), isTrue);
  });

  test('creates an independent path for every flight leg', () {
    const first = LatLng(51.5, -0.1);
    const transfer = LatLng(35.65, 139.8);
    const destination = LatLng(-33.86, 151.2);

    final segments = buildFlightRouteSegments([first, transfer, destination]);

    expect(segments, hasLength(2));
    expect(segments.first.first, first);
    expect(segments.first.last, transfer);
    expect(segments.last.first, transfer);
    expect(segments.last.last, destination);
  });
}
