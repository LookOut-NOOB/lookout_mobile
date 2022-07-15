import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/service_locator.dart';
import 'views/app_viewmodel.dart';
import 'views/home/home_view.dart';
import 'views/home/report_accident.dart';
import 'views/home/report_incident.dart';
import 'views/home/request_ambulance.dart';
import 'views/loading_view.dart';
import 'views/login.dart';
import 'views/profile_view.dart';
import 'views/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setup();
  runApp(const MainApp());
  configureLoading();
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final appViewModel = GetIt.instance<AppViewModel>();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        primaryColor: const Color(0xffED1F44),
        primaryColorLight: Colors.red,
        colorScheme: Theme.of(context).colorScheme.copyWith(
              secondary: const Color(0xffED1F44),
            ),
        appBarTheme: const AppBarTheme(
          elevation: 0.5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            primary: const Color(0xffED1F44),
          ),
        ),
      ),
      home: FutureBuilder(
          future: appViewModel.repository.initAppData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return const App();
            } else {
              return const LoadingView();
            }
          }),
      routes: {
        HomeView.routeName: (context) => const HomeView(),
        SettingsView.routeName: (context) => const SettingsView(),
        ProfileView.routeName: (context) => const ProfileView(),
        LoginView.routeName: (context) => const LoginView(),
        ReportAccident.routeName: (context) => const ReportAccident(),
        RequestAmbulance.routeName: (context) => const RequestAmbulance(),
        ReportIncident.routeName: (context) => const ReportIncident(),
      },
    );
  }
}

void configureLoading() {
  EasyLoading.instance.userInteractions = false;
}

void printDebug(Object message) {
  if (kDebugMode) {
    print("\n$message\n\n");
  }
}
