import 'package:flutter_test/flutter_test.dart';
import 'package:tui_mobility_hub/presentation/widgets/city_carousel.dart';

void main() {
  const baseUrl = 'http://10.0.2.2:8000';

  test('resolves a relative API image path against the API base URL', () {
    expect(
      resolveCityImageUrl('/assets/cities/london.svg', baseUrl: baseUrl),
      'http://10.0.2.2:8000/assets/cities/london.svg',
    );
  });

  test('keeps an absolute city image URL unchanged', () {
    const imageUrl = 'https://images.example.com/cities/london.jpg';
    expect(
      resolveCityImageUrl(imageUrl, baseUrl: baseUrl),
      imageUrl,
    );
  });
}
