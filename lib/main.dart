import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/app.dart';
import 'package:look_out/services/service_locator.dart';
import 'package:look_out/splash.dart';
import 'package:look_out/views/auth/user_form.dart';
import 'package:look_out/views/home/home_view.dart';
import 'package:look_out/views/home/report_accident.dart';
import 'package:look_out/views/home/report_incident.dart';
import 'package:look_out/views/home/request_ambulance.dart';
import 'package:look_out/views/profile_view.dart';
import 'package:look_out/views/settings_view.dart';
import 'package:url_launcher/url_launcher.dart';

import 'firebase_options.dart';
import 'services/user_preferences.dart';
import 'views/app_viewmodel.dart';
import 'views/auth/login.dart';

const appName = "Look Out";
const appSlogan = "Quick, secure and reliable help at your fingertips";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  setup();
  await UserPreferences().init();
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
      // home: FutureBuilder(
      //     future: appViewModel.repository.initAppData(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         return const App();
      //       } else {
      //         return const LoadingView();
      //       }
      //     }),
      home: const SplashScreen(),
      routes: {
        App.routeName: (context) => const App(),
        HomeView.routeName: (context) => const HomeView(),
        LoginView.routeName: (context) => LoginView(),
        UserForm.routeName: (context) => const UserForm(),
        SettingsView.routeName: (context) => const SettingsView(),
        ProfileView.routeName: (context) => const ProfileView(),
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

void launchCaller(String phoneNo) async {
  String url = "tel:$phoneNo";
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not call $phoneNo';
  }
}
