import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:look_out/app.dart';
import 'package:look_out/main.dart';
import 'package:look_out/models/alarm.dart';
import 'package:look_out/services/location_service.dart';
import 'package:look_out/widgets/dialogs.dart';
import 'package:look_out/widgets/ring.dart';

import '../app_viewmodel.dart';

class PanicView extends StatefulWidget {
  static const String routeName = "panic";
  const PanicView({Key? key}) : super(key: key);

  @override
  _PanicViewState createState() => _PanicViewState();
}

class _PanicViewState extends State<PanicView> {
  bool isPanicking = false;
  Map<String, dynamic>? alarm;
  Alarm? activeAlarm;
  final appViewModel = GetIt.instance<AppViewModel>();
  // var db = FirebaseFirestore.instance.collection("alarms");
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isPanicking = appViewModel.repository.isPanicking;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: appViewModel.repository.getActiveAlarm(),
        builder: (context, snapshot) {
          List<QueryDocumentSnapshot<Map<String, dynamic>>> activeAlarmDocsQs =
              snapshot.data?.docs ?? [];
          bool hasActiveAlarm =
              (snapshot.hasData && activeAlarmDocsQs.isNotEmpty);

          if (hasActiveAlarm) {
            activeAlarm = Alarm.fromMap(activeAlarmDocsQs[0].data());
          }

          return hasActiveAlarm && activeAlarm != null
              ? Ring(
                  icon: Icons.security_outlined,
                  action: () {
                    _stopPanic(activeAlarm!.id);
                  },
                )
              : Container(
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                        Color(0xddefefef),
                        Color(0xddefefef),
                        Color(0x99ffffff),
                        Color(0x99ffffff),
                      ])),
                  alignment: AlignmentDirectional.center,
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onLongPress: () {
                              if (!isPanicking) {
                                _startPanic();
                              }
                              // else {
                              //   _stopPanic(activeAlarm.id);
                              // }
                            },
                            child: Image.asset(
                              isPanicking
                                  ? "assets/icons/panic_button_on.png"
                                  : "assets/icons/panic_button_off.png",
                              height: 270,
                              width: 270,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(16),
                          ),
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(8),
                            alignment: AlignmentDirectional.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: const Color(0x22cd0000),
                                borderRadius: BorderRadius.circular(16)),
                            child: const Text(
                              "Press and hold for 2 seconds to sound an alarm and activate panic mode.",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        });
  }

  void _startPanic() {
    printDebug("Starting Panic");
    loadingDialog(context, message: "Starting Panic");
    LocationService().getCurrentLocation().then((LocationData? locationData) {
      GeoPoint? geoPoint;
      if (locationData != null) {
        geoPoint = GeoPoint(locationData.latitude!, locationData.longitude!);
        Alarm panicAlarm = Alarm(
          id: uuid.v1(),
          status: "1",
          userId: appViewModel.repository.profile?.uid,
          dateTime: DateTime.now(),
          location: geoPoint,
        );
        appViewModel.repository.soundAlarm(panicAlarm).then((value) {
          popDialog(context);
        });
      } else {
        popDialog(context);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to get current location')));
      }
    }).catchError((error) {
      popDialog(context);
      printDebug("Error getting location: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error getting current location')));
    });
  }

  void _stopPanic(alarmId) {
    printDebug("Stopped Panic");
    appViewModel.repository.cancelAlarm(alarmId);
    setState(() {
      // isPanicking = false;
    });
  }
}
