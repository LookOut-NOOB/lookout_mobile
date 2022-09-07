import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/main.dart';
import 'package:look_out/models/alarm.dart';
import 'package:look_out/models/ambulance_request.dart';
import 'package:look_out/views/alarm/panic_view.dart';
import 'package:look_out/views/app_viewmodel.dart';
import 'package:look_out/views/contacts/contacts_view.dart';
import 'package:look_out/views/home/home_view.dart';
import 'package:look_out/views/settings_view.dart';
import 'package:look_out/widgets/dialogs.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();
final appScaffold = GlobalKey<ScaffoldState>();

class App extends StatefulWidget {
  static const String routeName = "app";
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  final appViewModel = GetIt.instance<AppViewModel>();
  TabController? _tabController;
  int currentIndex = 1;
  bool showTips = true;
  VoidCallback? showBottomSheet;
  bool isPanicking = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    showBottomSheet = _showBottomSheet;
    try {
      appViewModel.repository.initAppData();
      // appViewModel.repository
      //     .getUserProfile(FirebaseAuth.instance.currentUser?.uid);
      // appViewModel.repository.getEmergencyContacts();
      // appViewModel.repository.getPoliceContacts();
      // appViewModel.repository.getCurrentLocation();
      // appViewModel.repository.getPoliceContactsForLocation(
      //     appViewModel.repository.currentLocation);
      // appViewModel.repository.getRegisteredLocations();
    } catch (e) {
      printDebug(e.toString());
      infoDialog(context, message: "Failed to initialise app data");
    }
  }

  void _showBottomSheet() {
    setState(() {
      showBottomSheet = null;
    });

    appScaffold.currentState
        ?.showBottomSheet((context) {
          return Card(
            color: Theme.of(context).primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Text(
                    "Contacting Ambulance",
                    style: TextStyle(color: Colors.white),
                  )),
                ],
              ),
            ),
          );
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              showBottomSheet = _showBottomSheet;
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    _tabController!.index = currentIndex;
    _tabController!.addListener(() {
      setState(() {
        currentIndex = _tabController!.index;
      });
    });
    isPanicking = appViewModel.repository.isPanicking;

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Image.asset(
            "assets/images/background_puzzle.jpg",
            fit: BoxFit.cover,
            repeat: ImageRepeat.noRepeat,
            alignment: const Alignment(0.2, 4),
          ),
        ),
        Container(
          color: Colors.grey.withOpacity(0.6),
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: appViewModel.repository.getActiveAlarm(),
              builder: (context, snapshot) {
                List<QueryDocumentSnapshot<Map<String, dynamic>>>
                    activeAlarmDocsQs = snapshot.data?.docs ?? [];
                bool hasActiveAlarm =
                    (snapshot.hasData && activeAlarmDocsQs.isNotEmpty);
                Alarm? activeAlarm;
                if (hasActiveAlarm) {
                  activeAlarm = Alarm.fromMap(activeAlarmDocsQs[0].data());
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: appViewModel.repository.activeAmbulanceRequest(),
                    builder: (context, snapshot) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          activeAmbulanceDocsQs = snapshot.data?.docs ?? [];
                      bool hasActiveAmbulanceReq = (snapshot.hasData &&
                          activeAmbulanceDocsQs.isNotEmpty);
                      AmbulanceRequest? activeAmbReq;
                      if (hasActiveAmbulanceReq) {
                        activeAmbReq = AmbulanceRequest.fromMap(
                            activeAmbulanceDocsQs[0].data());
                        FirebaseFirestore.instance
                            .collection('ambulances')
                            .where("is", isEqualTo: activeAmbReq.ambulanceId)
                            .get();
                      }
                      return Scaffold(
                        key: appScaffold,
                        backgroundColor: Colors.transparent,
                        appBar: AppBar(
                          title: const Text(appName),
                          // toolbarHeight: 80,
                          backgroundColor: Colors.white.withOpacity(0.6),
                          elevation: 0.5,
                          actions: <Widget>[
                            IconButton(
                              icon: Icon(
                                FlutterIcons.settings_fea,
                                color: Theme.of(context).primaryColor,
                                size: 23,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, SettingsView.routeName);
                              },
                            )
                          ],
                        ),
                        extendBody: true,
                        persistentFooterButtons: hasActiveAmbulanceReq
                            ? [
                                Card(
                                  color: Theme.of(context).primaryColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: activeAmbReq?.status == "1"
                                        ? contactingAmbulance(activeAmbReq!)
                                        : ambReqaccepted(activeAmbReq!),
                                  ),
                                ),
                              ]
                            : hasActiveAlarm
                                ? [
                                    RingingPopUp(alarm: activeAlarm!),
                                  ]
                                : null,
                        body: TabBarView(
                          controller: _tabController,
                          children: const [
                            PanicView(),
                            HomeView(),
                            ContactsView(),
                          ],
                        ),
                        bottomNavigationBar: BottomNavigationBar(
                            onTap: (position) {
                              setState(() {
                                currentIndex = position;
                              });
                            },
                            showUnselectedLabels: true,
                            currentIndex: currentIndex,
                            selectedItemColor:
                                Theme.of(context).colorScheme.secondary,
                            unselectedItemColor: Colors.black45,
                            items: const [
                              BottomNavigationBarItem(
                                  backgroundColor: Colors.transparent,
                                  icon:
                                      Icon(Icons.notifications_active_outlined),
                                  label: "Alarm",
                                  tooltip: "Sound an alarm in case of Panic"),
                              BottomNavigationBarItem(
                                  backgroundColor: Colors.transparent,
                                  icon: Icon(FlutterIcons.shield_fea),
                                  label: "Home",
                                  tooltip: "Landing informative page"),
                              BottomNavigationBarItem(
                                  backgroundColor: Colors.transparent,
                                  icon: Icon(Icons.contact_page_outlined),
                                  label: "Contacts",
                                  tooltip: "Get helpful contacts"),
                            ]),
                      );
                    });
              }),
        ),
      ],
    );
  }

  Widget contactingAmbulance(AmbulanceRequest activeAmbReq) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: const [
            SpinKitThreeBounce(
              color: Colors.white,
              size: 20,
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
                child: Text(
              "Contacting Ambulance",
              style: TextStyle(color: Colors.white),
            )),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        const Divider(
          color: Colors.white60,
        ),
        ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.white),
            onPressed: () {
              loadingDialog(context, message: "Cancelling request");
              appViewModel.repository
                  .cancelAmbulance(activeAmbReq)
                  .then((value) {
                popDialog(context);
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Cancel Request",
                  style: TextStyle(color: Colors.black),
                ),
              ],
            )),
      ],
    );
  }

  Widget ambReqaccepted(AmbulanceRequest req) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('ambulances')
            .where("id", isEqualTo: req.ambulanceId)
            .get(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                snap.data?.docs ?? [];
            if (docs.isNotEmpty) {
              String ambulanceName = docs[0]["name"] ?? "Ambulance";
              String ambulancePhone = docs[0]["phone"] ?? "0";
              req.ambulanceName = ambulanceName;
              req.ambulancePhoneNo = ambulancePhone;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Request Accepted",
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(color: Colors.white60),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  req.ambulanceName ?? "Ambulance",
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Colors.white),
                ),
                const Divider(
                  color: Colors.white60,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.white),
                          onPressed: () {
                            try {
                              launchCaller(req.ambulancePhoneNo ?? "none");
                            } catch (e) {
                              printDebug("Failed to call: $e");
                            }
                          },
                          icon: const Icon(
                            Feather.phone_call,
                            color: Colors.black,
                          ),
                          label: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              "Call Ambulance",
                              style: TextStyle(color: Colors.black),
                            ),
                          )),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                        onPressed: () {
                          loadingDialog(context, message: "Cancelling request");
                          appViewModel.repository
                              .cancelAmbulance(req)
                              .then((value) {
                            popDialog(context);
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            "Cancel request",
                            style: TextStyle(color: Colors.black),
                          ),
                        )),
                  ],
                ),
              ],
            );
          }
        });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }
}

class RingingPopUp extends StatefulWidget {
  final Alarm alarm;
  const RingingPopUp({Key? key, required this.alarm}) : super(key: key);

  @override
  _RingingPopUpState createState() => _RingingPopUpState();
}

class _RingingPopUpState extends State<RingingPopUp> {
  final appViewModel = GetIt.instance<AppViewModel>();
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                  ),
                  child: Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.redAccent.shade700,
                    size: 30,
                  ),
                ),
                const Expanded(
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Panic Mode Active",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ))),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () {
                      _stopPanic(widget.alarm.id);
                    },
                    child: const Text(
                      "Turn off",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _stopPanic(String alarmId) {
    printDebug("Stopped Panic");
    appViewModel.repository.cancelAlarm(alarmId);
    setState(() {});
  }
}
