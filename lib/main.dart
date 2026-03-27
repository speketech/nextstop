import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_sdk_config.dart';
import 'core/app_theme.dart';
import 'features/auth/data/repositories/real_auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/nin_verification_screen.dart';
import 'features/trips/data/repositories/real_trip_repository.dart';
import 'features/trips/presentation/bloc/trip_bloc.dart';
import 'core/api/api_client.dart';
import 'core/api/socket_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  if (!kIsWeb) {
    // Interswitch SDK Configuration from .env
    var config = IswSdkConfig(
      merchantId: dotenv.env['ISW_MERCHANT_ID'] ?? 'MX276440',
      payItemId: dotenv.env['ISW_PAY_ITEM_ID'] ?? 'Default_Payable_MX276440',
      clientId: dotenv.env['ISW_CLIENT_ID'] ?? '',
      secretKey: dotenv.env['ISW_SECRET_KEY'] ?? '',
      env: Environment.TEST,
    );
    await IswMobileSdk.initialize(config);
  }

  // API and Real-Time Services
  final apiClient = ApiClient();
  final socketService = SocketService();
  final authRepository = RealAuthRepository(apiClient: apiClient);
  final tripRepository = RealTripRepository(apiClient: apiClient, socketService: socketService);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc(
            authRepository: authRepository,
            socketService: socketService,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => TripBloc(tripRepository: tripRepository),
        ),
      ],
      child: const NextStopApp(),
    ),
  );
}

class NextStopApp extends StatelessWidget {
  const NextStopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NextStop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/nin_verification': (context) => const NinVerificationScreen(),
        '/driver_dashboard': (context) => const Scaffold(body: Center(child: Text('Driver Dashboard'))),
        '/dashboard': (context) => const Scaffold(body: Center(child: Text('Passenger Dashboard'))),
      },
    );
  }
}
