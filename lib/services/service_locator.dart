import 'package:get_it/get_it.dart';
import 'package:look_out/views/app_viewmodel.dart';

import 'repository_service.dart';

final getIt = GetIt.instance;

void setup() {
  getIt.registerSingleton<AppViewModel>(AppViewModel());
  getIt.registerSingleton<RepositoryService>(RepositoryService());
}
