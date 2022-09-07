import 'package:look_out/services/repository.dart';
import 'package:stacked/stacked.dart';

class AppViewModel extends BaseViewModel {
  late Repository repository;

  AppViewModel() {
    repository = Repository(() {
      notifyListeners();
    });
  }
}
