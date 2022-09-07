import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:look_out/main.dart';
import 'package:look_out/models/accident.dart';
import 'package:look_out/models/alarm.dart';
import 'package:look_out/models/ambulance_request.dart';
import 'package:look_out/models/app_location.dart';
import 'package:look_out/models/emergency_contact.dart';
import 'package:look_out/models/incident.dart';
import 'package:look_out/models/police_contact.dart';
import 'package:look_out/models/profile.dart';
import 'package:look_out/services/user_preferences.dart';
import 'package:video_compress/video_compress.dart';

import '../models/recorded_video.dart';

class Repository {
  final Function notify;
  List<PoliceContact> allPoliceContacts = [];
  List<PoliceContact> policeContacts = [];
  List<EmergencyContact> emergencyContacts = [];
  Profile? profile;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> records = [];
  bool isPanicking = false;
  List<AppLocation> locations = [];
  String currentLocation = "Unknown";

  Repository(this.notify);

  signIn(PhoneAuthCredential credential) {
    auth.signInWithCredential(credential).then((value) {
      return value.user;
    });
  }

  Future<Profile?> getUserProfile(String? uid) async {
    Profile? thisProfile;
    try {
      await db.collection("users").doc(uid).get().then((value) {
        if (value.exists) {
          profile = Profile.fromMap(value.data()!);
          thisProfile = profile;
          notify();
          return thisProfile;
        }
      });
    } catch (e) {
      printDebug("Failed to getUser profile");
      return Future.value(thisProfile);
    }
    return null;
  }

  getPoliceContacts() {
    try {
      db.collection("policeContacts").get().then((value) {
        if (value.docs.isNotEmpty) {
          allPoliceContacts = value.docs
              .map((pContactQs) => PoliceContact.fromMap(pContactQs.data()))
              .toList();
          notify();
        }
      });
    } catch (e) {
      printDebug("Failed to get police contacts");
    }

    // policeContacts = [
    //   PoliceContact(
    //       id: "stx890",
    //       name: "Afande Sebagabo look_out",
    //       phoneNumber: "+256 704436444"),
    //   PoliceContact(
    //       id: "9gmh90", name: "Nakendo Ibra", phoneNumber: "+256 726890000"),
    // ];
  }

  getPoliceContactsForLocation(String locn) {
    try {
      db
          .collection("policeContacts")
          .where(
            "location",
            isEqualTo: locn,
          )
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          policeContacts = value.docs
              .map((pContactQs) => PoliceContact.fromMap(pContactQs.data()))
              .toList();
          notify();
        }
      });
    } catch (e) {
      printDebug("Failed to get police contacts");
    }

    // policeContacts = [
    //   PoliceContact(
    //       id: "stx890",
    //       name: "Afande Sebagabo look_out",
    //       phoneNumber: "+256 704436444"),
    //   PoliceContact(
    //       id: "9gmh90", name: "Nakendo Ibra", phoneNumber: "+256 726890000"),
    // ];
  }

  getEmergencyContacts() {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    try {
      db
          .collection("users")
          .doc(userId)
          .collection("emergencyContact")
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          emergencyContacts = value.docs
              .map((eContactQs) => EmergencyContact.fromMap(eContactQs.data()))
              .toList();
          notify();
        }
      });
    } catch (e) {
      printDebug("Failed to get emergency contacts");
    }

    // emergencyContacts = [
    //   EmergencyContact(
    //       id: "67890", name: "Tonny Baw", phoneNumber: "+256 781521555")
    // ];
  }

  Future? initAppData() async {
    return await getUserProfile(FirebaseAuth.instance.currentUser?.uid)
        .then((value) async {
      await getCurrentLocation().then((value) async {
        await getPoliceContactsForLocation(value);
      });
      //await getPoliceContacts();

      await getEmergencyContacts();
      await getAllRecords();
      await getRegisteredLocations();
    });
  }

  Future<bool> registerEmergencyContact(EmergencyContact contact) async {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    bool result = false;
    try {
      await db
          .collection("users")
          .doc(userId)
          .collection("emergencyContact")
          .add(contact.toMap())
          .then((value) {
        result = true;
        getEmergencyContacts();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> editEmergencyContact(EmergencyContact contact) async {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    bool result = false;
    try {
      await db
          .collection("users")
          .doc(userId)
          .collection("emergencyContact")
          .doc(contact.id)
          .set(contact.toMap())
          .then((value) {
        result = true;
        getEmergencyContacts();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> deleteEmergencyContact(EmergencyContact contact) async {
    emergencyContacts.removeWhere((element) => (element.id == contact.id));
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    bool result = false;
    try {
      await db
          .collection("users")
          .doc(userId)
          .collection("emergencyContact")
          .doc(contact.id)
          .delete()
          .then((value) {
        result = true;
        getEmergencyContacts();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> reportAccident(Accident accident) async {
    bool result = false;
    try {
      await db
          .collection("accidents")
          .doc(accident.id)
          .set(accident.toMap())
          .then((value) {
        result = true;
        getAllRecords();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> reportIncident(Incident incident) async {
    bool result = false;
    try {
      await db
          .collection("incidents")
          .doc(incident.id)
          .set(incident.toMap())
          .then((value) {
        result = true;
        getAllRecords();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> requestAmbulance(AmbulanceRequest ambulanceRequest) async {
    bool result = false;
    try {
      await db
          .collection("ambulance_requests")
          .doc(ambulanceRequest.id)
          .set(ambulanceRequest.toMap())
          .then((value) {
        result = true;
        getAllRecords();
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> cancelAmbulance(AmbulanceRequest ambulanceRequest) async {
    bool result = false;
    try {
      await db
          .collection("ambulance_requests")
          .doc(ambulanceRequest.id)
          .update({'status': "0"}).then((value) {
        result = true;
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> soundAlarm(Alarm alarm) async {
    bool result = false;
    try {
      await db
          .collection("alarms")
          .doc(alarm.id)
          .set(alarm.toMap())
          .then((value) {
        result = true;
        isPanicking = true;
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<bool> cancelAlarm(String alarmId) async {
    bool result = false;
    try {
      await db
          .collection("alarms")
          .doc(alarmId)
          .update({'status': "0"}).then((value) {
        result = true;
        isPanicking = false;
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  UploadTask? createImageUploadTask(String incidentId, File file) {
    try {
      String fileName = file.uri.pathSegments.last;
      final ref = FirebaseStorage.instance
          .ref('incidents/$incidentId')
          .child('img/$fileName');
      UploadTask uploadTask = ref.putFile(file);
      return uploadTask;
    } catch (e) {
      printDebug('Failed to upload file!');
      return null;
    }
  }

  Future<MediaInfo?> compressRecordedVideo(RecordedVideo? recordedVideo) {
    if (recordedVideo != null) {
      return recordedVideo.justCompressVideo();
    }
    return Future.value(null);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllIncidents() {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    return db.collection("incidents").where("userId", isEqualTo: userId).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllAmbulanceRequests() {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    return db
        .collection("ambulance_requests")
        .where("userId", isEqualTo: userId)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTip() {
    return db.collection("info").doc("tip").get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? activeAmbulanceRequest() {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";
    try {
      return db
          .collection("ambulance_requests")
          .where("userId", isEqualTo: userId)
          .where("status", whereIn: ["1", "2"])
          .orderBy("dateTime", descending: true)
          .limit(1)
          .snapshots();
    } catch (e) {
      printDebug("Failed to get ambulance requests");
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getActiveAlarm() {
    String userId =
        profile?.uid ?? FirebaseAuth.instance.currentUser?.uid ?? "none";

    try {
      return db
          .collection("alarms")
          .where("userId", isEqualTo: userId)
          .where("status", isEqualTo: "1")
          .orderBy("dateTime", descending: true)
          .limit(1)
          .snapshots();
    } catch (e) {
      printDebug("Failed to get active alarm");
      return null;
    }
  }

  Future<List<dynamic>> getAllRecords() async {
    records = [];
    try {
      await getAllIncidents().then((incidentsValue) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> incidentQsList =
            incidentsValue.docs;
        for (var element in incidentQsList) {
          Map<String, dynamic> incMap = element.data();
          Incident incId = Incident.fromMap(incMap);
          records.add(incId);
        }
      });
    } catch (e) {
      printDebug("couldn't get incident records:$e");
    }
    try {
      await getAllAmbulanceRequests().then((aRequestsValue) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> aRequestsQsList =
            aRequestsValue.docs;
        for (var element in aRequestsQsList) {
          Map<String, dynamic> aReqMap = element.data();
          AmbulanceRequest aReqId = AmbulanceRequest.fromMap(aReqMap);
          records.add(aReqId);
        }
      });
    } catch (e) {
      printDebug("couldn't get ambulance records:$e");
    }

    return records;
  }

  Future<List<AppLocation>?> getRegisteredLocations() async {
    List<AppLocation> regLocatns = [];
    try {
      await db.collection("locations").get().then((value) {
        if (value.docs.isNotEmpty) {
          locations = value.docs
              .map((locanQs) => AppLocation.fromMap(locanQs.data()))
              .toList();
          notify();
          regLocatns = locations;
          return regLocatns;
        }
      });
    } catch (e) {
      printDebug("Failed to get registered locations");
      return Future.value(regLocatns);
    }
    return null;
  }

  Future<String> getCurrentLocation() async {
    try {
      String loc = UserPreferences().location;
      currentLocation = loc;
      notify();
      return loc;
    } catch (e) {
      printDebug("Failed to get location");
      return "Unkown";
    }
  }

  Future<bool> setCurrentLocation(String location) async {
    bool result = false;
    try {
      await UserPreferences().setLocation(location).then((res) {
        result = res;
        getCurrentLocation();
      });
      return result;
    } catch (e) {
      printDebug("===FAIL: $e");
      printDebug("Failed to set location");
      return Future.value(result);
    }
  }

  // Future<List<String>> getLocationSuggestions(String input) async {
  //   loc.Location currentLocation = loc.Location();
  //   loc.LocationData? locationData;
  //   List<String> resultList = [];
  //   try {
  //     locationData = await currentLocation.getLocation();
  //     LatLon location = LatLon(locationData.latitude!, locationData.longitude!);
  //     var googlePlace = GooglePlace(kGoogleApiKey);
  //     var result = await googlePlace.autocomplete.get(
  //       input,
  //       // location: location,
  //       // radius: 500,
  //     );
  //     var googlePlace2 = GooglePlace(kGoogleApiKey);
  //     var result2 =
  //         await googlePlace.queryAutocomplete.get(input).then((value) {
  //       print("ddddddddddd");
  //       printDebug(value?.predictions.toString() ?? "nothing");
  //     });

  //     List<AutocompletePrediction> predictions = result?.predictions ?? [];
  //     print("**************");
  //     printDebug(predictions);
  //     num resultCount = result?.predictions?.length ?? 0;
  //     for (var i = 0; i < resultCount; i++) {
  //       String? locationName = predictions[i].description;
  //       print(">>>>>>>>>>>>>>>>>>>");
  //       printDebug(locationName.toString());
  //       if (locationName != null) {
  //         resultList.add(locationName);
  //       }
  //     }
  //   } catch (e) {
  //     print(e.toString());
  //   }

  //   return resultList;
  // }

  Future logOut() {
    return FirebaseAuth.instance.signOut();
  }
}
