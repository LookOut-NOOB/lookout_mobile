import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app.dart';
import '../main.dart';
import '../models/accident.dart';
import '../models/alarm.dart';
import '../models/ambulance_request.dart';
import '../models/emergency_contact.dart';
import '../models/incident.dart';
import '../models/police_contact.dart';
import '../models/profile.dart';

class Repository {
  final Function notify;
  List<PoliceContact> policeContacts = [];
  List<EmergencyContact> emergencyContacts = [];
  Profile? profile;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  List<dynamic> records = [];
  bool isPanicking = false;

  Repository(this.notify);

  signIn(PhoneAuthCredential credential) {
    auth.signInWithCredential(credential).then((value) {
      return value.user;
    });
  }

  Future getUserProfile(String? uid) async {
    try {
      return await db.collection("users").doc(uid).get().then((value) {
        if (value.exists) {
          profile = Profile.fromMap(value.data()!);
          notify();
        }
      });
    } catch (e) {
      printDebug("Failed to getUser profile");
      return null;
    }
  }

  getPoliceContacts() {
    try {
      db.collection("policeContacts").get().then((value) {
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
    //       name: "Afande Sebagabo Silva",
    //       phoneNumber: "+256 704436444"),
    //   PoliceContact(
    //       id: "9gmh90", name: "Nakendo Ibra", phoneNumber: "+256 726890000"),
    // ];
  }

  getEmergencyContacts() {
    try {
      db
          .collection("users")
          .doc(profile?.uid)
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
    return await getUserProfile(profile?.uid).then((value) async {
      await getPoliceContacts();
      await getEmergencyContacts();
      await getAllRecords();
    });
  }

  Future<bool> registerEmergencyContact(EmergencyContact contact) async {
    bool result = false;
    try {
      await db
          .collection("users")
          .doc(profile?.uid)
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
    bool result = false;
    try {
      await db
          .collection("users")
          .doc(profile?.uid)
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

  Future deleteEmergencyContact(EmergencyContact contact) {
    emergencyContacts.removeWhere((element) => (element.id == contact.id));
    return Future.delayed(const Duration(seconds: 1));
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
    String id = uuid.v1();
    try {
      await db
          .collection("ambulance_request")
          .doc(id)
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
          .update({'status': "cancelled"}).then((value) {
        result = true;
        isPanicking = false;
      });
    } catch (e) {
      result = false;
    }
    return result;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllAccidents() {
    return db.collection("accidents").get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllIncidents() {
    return db.collection("incidents").get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllAmbulanceRequests() {
    return db
        .collection("ambulance_request")
        .where("userId", isEqualTo: profile?.uid)
        .get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTip() {
    return db.collection("info").doc("tip").get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? activeAmbulanceRequest() {
    try {
      return db
          .collection("ambulance_request")
          .where("userId", isEqualTo: profile?.uid)
          .where("status", whereIn: ["pending", "accepted"])
          .orderBy("dateTime", descending: true)
          .limit(1)
          .snapshots();
    } catch (e) {
      printDebug("Failed to get ambulance requests");
      return null;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? getActiveAlarm() {
    try {
      return db
          .collection("alarms")
          .where("userId", isEqualTo: profile?.uid)
          .where("status", isEqualTo: "on")
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
      await getAllAccidents().then((accidentsValue) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> accidentQsList =
            accidentsValue.docs;
        for (var element in accidentQsList) {
          Map<String, dynamic> accMap = element.data();
          Accident accId = Accident.fromMap(accMap);
          records.add(accId);
        }
      });
      await getAllIncidents().then((incidentsValue) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> incidentQsList =
            incidentsValue.docs;
        for (var element in incidentQsList) {
          Map<String, dynamic> incMap = element.data();
          Incident incId = Incident.fromMap(incMap);
          records.add(incId);
        }
      });
      await getAllAmbulanceRequests().then((aRequestsValue) {
        List<QueryDocumentSnapshot<Map<String, dynamic>>> aRequestsQsList =
            aRequestsValue.docs;
        for (var element in aRequestsQsList) {
          Map<String, dynamic> aReqMap = element.data();
          Incident aReqId = Incident.fromMap(aReqMap);
          records.add(aReqId);
        }
      });
    } catch (e) {
      printDebug("Coudn't get records");
    }

    return records;
  }

  Future logOut() {
    return Future.delayed(const Duration(seconds: 1));
  }
}
