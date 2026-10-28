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

## Important API schema note
The challenge document does not show example JSON bodies. The parsers support common flat and nested field names. If your API uses different property names, adjust `connection_model.dart` and `city_model.dart` to match the actual payload. Coordinates are needed for the map.
