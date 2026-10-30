# TUI Mobility Hub — Flutter Code Challenge

Flutter trip planner implemented with BLoC, Clean Architecture, SOLID principles, and Dijkstra's cheapest-route algorithm.

## Requirements
- Flutter stable / Dart 3
- Python API supplied with the challenge running on port 8000
- Internet access for OpenStreetMap tiles in the map view

## Start the API
From the challenge directory, use the API setup instructions in the challenge document. For FastAPI, from the `api` directory:

```bash
python -m uvicorn main:app --reload --port 8000
```

Verify `http://localhost:8000/health`, `http://localhost:8000/connections`, and `http://localhost:8000/cities`.

## Run Flutter
```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

The default API URL is `http://10.0.2.2:8000`, which is correct for the Android emulator. Override it for desktop, iOS simulator, web, or a physical device:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

For a physical Android device, use the computer's LAN IP, for example:
```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```
Use the actual IP of your development computer.

## Android local HTTP
Debug builds allow cleartext HTTP for the local API. Release builds should use an HTTPS API; cleartext traffic is not enabled for release.

## Architecture
- `domain/entities`: city and connection entities
- `domain/repositories`: repository contract
- `domain/usecases`: fetch data and find cheapest route
- `data/datasources`: API endpoints
- `data/models`: JSON parsing
- `data/repositories`: repository implementation
- `presentation/bloc`: events, state, and BLoC
- `presentation/pages`: home and route results/map screens
- `presentation/widgets`: reusable city carousel

## Algorithm
Dijkstra's algorithm minimizes total price over non-negative connection prices. The expected complexity with a binary heap is `O((V + E) log V)`. The route is computed locally in Flutter; the API only supplies connections and city metadata.

## API response format
The supplied API returns connections in a `connections` array. Each connection has string `from` and `to` city names, a numeric `price`, and nested `coordinates.from` / `coordinates.to` objects with `lat` and `long` fields. The cities endpoint returns a `cities` array with `name` and a relative SVG `imageUrl`. The Flutter data models parse these fields and the carousel resolves image paths against the configured API base URL.

## Architecture and trade-offs
The app separates API access and JSON parsing in the data layer, repository contracts and route calculation in the domain layer, and BLoC/UI concerns in the presentation layer. The main dependencies are `http` for API requests, `flutter_bloc` for state management, `flutter_map` and `latlong2` for the map, and `flutter_svg` for the API's city illustrations.

The route finder uses a binary heap and assumes all connection prices are non-negative. Map paths are sampled great-circle arcs between the supplied city coordinates; they are illustrative flight paths, not real airline routes. Route calculation is synchronous, which is appropriate for the challenge dataset; for very large graphs it could move to a background isolate. Other possible improvements include city autocomplete and richer handling of API/network errors.

## Tests and checks
Tests cover JSON parsing, cheapest-route calculation, sampled map paths, BLoC state transitions, route navigation, no-route feedback, and retry after an API failure. Run `flutter test` and `flutter analyze` from the project directory.
