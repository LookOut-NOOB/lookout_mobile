import 'package:location/location.dart';

class LocationService {
  static const googleApiKey = "AIzaSyCq9i3A9R-aPaoASB_e5lzj5DTr3iYlMxs";

  //final String detailsUrl = "https://maps.googleapis.com/maps/api/place/details/output?parameters";

  // Future<String> getPlaceId(String input) async {
  //   final String url =
  //       "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";
  // }

  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return null;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }
}
