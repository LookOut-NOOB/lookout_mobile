import 'package:location/location.dart';

class LocationService {
  // static const googleApiKey = "AIzaSyCq9i3A9R-aPaoASB_e5lzj5DTr3iYlMxs";
  static const MapsApiKey = "AIzaSyAQewpNI1z6v6zCoYRyPs8Ay4yGO3FinRI";
  static const GooglePlacesApiKey = "AIzaSyB4SKRvN65F6khbqGi7n6GrQ8KdnSQSN7U";

  //final String detailsUrl = "https://maps.googleapis.com/maps/api/place/details/output?parameters";

  // Future<String> getPlaceId(String input) async {
  //   final String url =
  //       "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$input&inputtype=textquery&key=$key";
  // }

  Future<LocationData?> getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    location.enableBackgroundMode(enable: true);
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    locationData = await location.getLocation();
    return locationData;
  }
}
