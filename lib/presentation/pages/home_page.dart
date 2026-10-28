import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/connection.dart';
import '../bloc/trip_bloc.dart';
import '../widgets/city_carousel.dart';
import 'route_results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _departure;
  String? _destination;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(children: [
        Icon(Icons.flight_takeoff_rounded),
        SizedBox(width: 10),
        Text('TUI Mobility Hub', style: TextStyle(fontWeight: FontWeight.w800)),
      ]),
      actions: [IconButton(tooltip: 'Refresh data', onPressed: () => context.read<TripBloc>().add(const TripRefreshed()), icon: const Icon(Icons.refresh))],
    ),
    body: BlocBuilder<TripBloc, TripState>(
      builder: (context, state) {
        if (state.status == TripStatus.initial || state.status == TripStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == TripStatus.failure && state.cities.isEmpty) {
          return _ErrorView(message: state.errorMessage ?? 'Unable to load data', onRetry: () => context.read<TripBloc>().add(const TripStarted()));
        }
        final cities = state.cities;
        if (cities.isEmpty) return const Center(child: Text('No destinations are available yet.'));
        _departure ??= cities.first.name;
        _destination ??= cities.length > 1 ? cities[1].name : cities.first.name;
        return RefreshIndicator(
          onRefresh: () async => context.read<TripBloc>().add(const TripRefreshed()),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF075985), Color(0xFF0891B2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('YOUR NEXT ADVENTURE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 11)),
                  SizedBox(height: 10),
                  Text('Find your best way there.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 27)),
                  SizedBox(height: 8),
                  Text('Compare connections and discover the cheapest route.', style: TextStyle(color: Colors.white, height: 1.4)),
                ]),
              ),
              const SizedBox(height: 26),
              const _SectionHeading(title: 'Explore destinations', subtitle: 'Swipe a card to choose your destination'),
              const SizedBox(height: 14),
              CityCarousel(cities: cities, selectedCity: _destination, onSelected: (city) => setState(() => _destination = city.name)),
              const SizedBox(height: 28),
              const _SectionHeading(title: 'Plan your journey', subtitle: 'Choose any two cities in the network'),
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    _CityDropdown(label: 'From', icon: Icons.trip_origin, cities: cities, value: _departure, onChanged: (value) => setState(() => _departure = value)),
                    const SizedBox(height: 12),
                    _CityDropdown(label: 'To', icon: Icons.location_on_outlined, cities: cities, value: _destination, onChanged: (value) => setState(() => _destination = value)),
                    const SizedBox(height: 18),
                    SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(
                      onPressed: _departure == null || _destination == null ? null : () {
                        context.read<TripBloc>().add(RouteRequested(_departure!, _destination!));
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<TripBloc>(),
                            child: const RouteResultsPage(),
                          ),
                        ));
                      },
                      icon: const Icon(Icons.route_rounded),
                      label: const Text('Find cheapest route', style: TextStyle(fontWeight: FontWeight.bold)),
                    )),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(state.errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                  ]),
                ),
              ),
              const SizedBox(height: 18),
              Row(children: [
                const Icon(Icons.swap_horiz_rounded, color: Color(0xFF087E8B)),
                const SizedBox(width: 8),
                Expanded(child: Text('${state.connections.length} connections available', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
              ]),
            ],
          ),
        );
      },
    ),
  );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 4),
    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
  ]);
}

class _CityDropdown extends StatelessWidget {
  const _CityDropdown({required this.label, required this.icon, required this.cities, required this.value, required this.onChanged});
  final String label;
  final IconData icon;
  final List<City> cities;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    value: cities.any((city) => city.name == value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14))),
    items: cities.map((city) => DropdownMenuItem(value: city.name, child: Text(city.name, overflow: TextOverflow.ellipsis))).toList(),
    onChanged: onChanged,
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.cloud_off_rounded, size: 52),
      const SizedBox(height: 14),
      const Text('Could not connect to the local API', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(message, textAlign: TextAlign.center),
      const SizedBox(height: 18),
      FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
    ]),
  ));
}
