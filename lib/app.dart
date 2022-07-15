import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import 'main.dart';
import 'models/alarm.dart';
import 'models/ambulance_request.dart';
import 'views/alarm/panic_view.dart';
import 'views/app_viewmodel.dart';
import 'views/contacts/contacts_view.dart';
import 'views/home/home_view.dart';
import 'views/settings_view.dart';
import 'widgets/dialogs.dart';

const uuid = Uuid();
const appName = "Look Out";
final appScaffold = GlobalKey<ScaffoldState>();

class App extends StatefulWidget {
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
      appViewModel.repository
          .getUserProfile(FirebaseAuth.instance.currentUser?.uid);
      appViewModel.repository.getEmergencyContacts();
      appViewModel.repository.getPoliceContacts();
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
            // "assets/images/dark.jpg",
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
                    ((snapshot.connectionState == ConnectionState.done) &&
                        snapshot.hasData &&
                        activeAlarmDocsQs.isNotEmpty);
                Alarm? activeAlarm;
                if (hasActiveAlarm) {
                  activeAlarm = Alarm.fromMap(activeAlarmDocsQs[0].data());
                }

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: appViewModel.repository.activeAmbulanceRequest(),
                    builder: (context, snapshot) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>>
                          activeAmbulanceDocsQs = snapshot.data?.docs ?? [];
                      bool hasActiveAmbulanceReq =
                          ((snapshot.connectionState == ConnectionState.done) &&
                              snapshot.hasData &&
                              activeAmbulanceDocsQs.isNotEmpty);
                      AmbulanceRequest? activeAmbReq;
                      if (hasActiveAmbulanceReq) {
                        activeAmbReq = AmbulanceRequest.fromMap(
                            activeAmbulanceDocsQs[0].data());
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
                                    child: activeAmbReq?.status == "pending"
                                        ? contactingAmbulance()
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

  Widget contactingAmbulance() {
    return Row(
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
    );
  }

  Widget ambReqaccepted(AmbulanceRequest req) {
    return Row(
      children: [
        IconButton(
            onPressed: () {},
            icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.call_sharp))),
        const SizedBox(
          width: 20,
        ),
        Expanded(
            child: Column(
          children: [
            const Text(
              "Request Accepted",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              req.ambulanceName!,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        )),
      ],
    );
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
                      "Cancel",
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
