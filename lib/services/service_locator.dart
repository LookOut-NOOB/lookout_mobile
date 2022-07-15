import 'package:get_it/get_it.dart';

import '../views/app_viewmodel.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<AppViewModel>(AppViewModel());
}
