import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:isw_mobile_sdk/isw_mobile_sdk.dart';
// Explicitly import the config model to prevent "Unresolved reference"
import 'package:isw_mobile_sdk/models/isw_mobile_sdk_sdk_config.dart'; 

import 'core/app_theme.dart';
import 'features/auth/data/repositories/real_auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/nin_verification_screen.dart';
import 'features/auth/presentation/pages/add_bank_account_page.dart';
import 'features/trips/data/repositories/real_trip_repository.dart';
import 'features/trips/presentation/bloc/trip_bloc.dart';
import 'core/api/api_client.dart';
import 'core/api/socket_service.dart';
import 'screens/driver_wallet_screen.dart';
import 'features/home/presentation/pages/passenger_home_screen.dart';
import 'features/home/presentation/pages/driver_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  
  if (!kIsWeb) {
    var config = IswSdkConfig(
      dotenv.env['ISW_MERCHANT_ID'] ?? 'MX276440',
      dotenv.env['ISW_PAY_ITEM_ID'] ?? 'Default_Payable_MX276440',
      dotenv.env['ISW_CLIENT_ID'] ?? '',
      dotenv.env['ISW_SECRET_KEY'] ?? '',
    );
    await IswMobileSdk.initialize(config);
  }

  final apiClient = ApiClient();
  final socketService = SocketService();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => RealAuthRepository(apiClient: apiClient)),
        RepositoryProvider(
          create: (context) => RealTripRepository(
            apiClient: apiClient, 
            socketService: socketService,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<RealAuthRepository>(),
              socketService: socketService,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => TripBloc(
              tripRepository: context.read<RealTripRepository>(),
            ),
          ),
        ],
        child: const NextStopApp(),
      ),
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
        '/driver_dashboard': (context) => const DriverHomeScreen(),
        '/dashboard': (context) => const PassengerHomeScreen(),
        '/add_bank': (context) => AddBankAccountPage(
              authRepository: context.read<RealAuthRepository>(),
            ),
        '/wallet': (context) => const DriverWalletScreen(),
      },
    );
  }
}