import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'data/datasources/mobility_remote_data_source.dart';
import 'data/repositories/connection_repository_impl.dart';
import 'domain/usecases/get_cities.dart';
import 'domain/usecases/get_connections.dart';
import 'domain/usecases/find_cheapest_route.dart';
import 'presentation/bloc/trip_bloc.dart';
import 'presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl);
  final dataSource = MobilityRemoteDataSource(apiClient);
  final repository = ConnectionRepositoryImpl(dataSource);
  runApp(TuiMobilityApp(
    getConnections: GetConnections(repository),
    getCities: GetCities(repository),
    findCheapestRoute: FindCheapestRoute(),
  ));
}

class TuiMobilityApp extends StatelessWidget {
  const TuiMobilityApp({
    super.key,
    required this.getConnections,
    required this.getCities,
    required this.findCheapestRoute,
  });

  final GetConnections getConnections;
  final GetCities getCities;
  final FindCheapestRoute findCheapestRoute;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TUI Mobility Hub',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF087E8B)),
          scaffoldBackgroundColor: const Color(0xFFF5F8FA),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              side: BorderSide(color: Color(0xFFE2E8ED)),
            ),
          ),
        ),
        home: BlocProvider(
          create: (_) => TripBloc(
            getConnections: getConnections,
            getCities: getCities,
            findCheapestRoute: findCheapestRoute,
          )..add(const TripStarted()),
          child: const HomePage(),
        ),
      );
}
