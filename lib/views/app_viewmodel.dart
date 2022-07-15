import 'package:stacked/stacked.dart';

import '../services/repository.dart';

class AppViewModel extends BaseViewModel {
  late Repository repository;

  AppViewModel() {
    repository = Repository(() {
      notifyListeners();
    });
  }
}
