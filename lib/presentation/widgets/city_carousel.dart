import 'package:flutter/material.dart';
import '../../domain/entities/connection.dart';

class CityCarousel extends StatelessWidget {
  const CityCarousel({super.key, required this.cities, required this.selectedCity, required this.onSelected});
  final List<City> cities;
  final String? selectedCity;
  final ValueChanged<City> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 170,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: cities.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final city = cities[index];
        final selected = city.name == selectedCity;
        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelected(city),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2),
              image: city.imageUrl != null
                ? DecorationImage(image: NetworkImage(city.imageUrl!), fit: BoxFit.cover, onError: (_, __) {})
                : null,
              gradient: city.imageUrl == null ? const LinearGradient(colors: [Color(0xFF0E7490), Color(0xFF164E63)], begin: Alignment.topLeft, end: Alignment.bottomRight) : null,
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC001018)]),
              ),
              alignment: Alignment.bottomLeft,
              child: Row(children: [
                const Icon(Icons.location_city_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(city.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
                if (selected) const Icon(Icons.check_circle, color: Colors.white),
              ]),
            ),
          ),
        );
      },
    ),
  );
}
