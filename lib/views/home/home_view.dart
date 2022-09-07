import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:look_out/models/accident.dart';
import 'package:look_out/models/ambulance_request.dart';
import 'package:look_out/models/incident.dart';
import 'package:look_out/models/tip.dart';
import 'package:look_out/views/home/report_accident.dart';
import 'package:look_out/views/home/report_incident.dart';
import 'package:look_out/views/home/request_ambulance.dart';

import '../app_viewmodel.dart';
import 'report_incident.dart';
import 'request_ambulance.dart';

class HomeView extends StatefulWidget {
  static const String routeName = "/home";
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final appViewModel = GetIt.instance<AppViewModel>();
  List records = [];
  @override
  void initState() {
    records = appViewModel.repository.records;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: appViewModel.repository.getTip(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      Map<String, dynamic>? map = snapshot.data?.data();
                      if (map != null) {
                        Tip sentTip = Tip.fromMap(map);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding:
                                const EdgeInsets.all(8.0).copyWith(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      child: Text(
                                        "Tip !",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                    Tooltip(
                                      message: "Close tip",
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  indent: 8,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline_rounded,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                    ),
                                    Expanded(
                                      child: Text(sentTip.tipText),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      }
                    }
                  }
                  return const SizedBox();
                }),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0).copyWith(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Actions",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 12),
                    GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(1),
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        quickActionTile(
                          label: "Report accident",
                          icon: const Icon(
                            Icons.taxi_alert,
                            size: 30,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(ReportAccident.routeName,
                                    arguments: ReportAccident(
                              resetSuccess: (String result) {
                                result = result;
                                resultDialog(result);
                              },
                            ));
                          },
                        ),
                        quickActionTile(
                          label: "Request ambulance",
                          icon: Stack(
                            children: [
                              const Icon(
                                Icons.taxi_alert,
                                size: 34,
                                color: Colors.black,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.local_hospital_outlined,
                                    size: 21,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(RequestAmbulance.routeName,
                                    arguments: RequestAmbulance(
                              resetSuccess: (String result) {
                                result = result;
                                resultDialog(result);
                              },
                            ));
                          },
                        ),
                        quickActionTile(
                          label: "Report Incident",
                          icon: const Icon(
                            //Icons.add_reaction_rounded,
                            Icons.warning_amber_rounded,
                            size: 34,
                            color: Colors.black,
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(ReportIncident.routeName,
                                    arguments: ReportIncident(
                              resetSuccess: (String result) {
                                result = result;
                                resultDialog(result);
                              },
                            ));
                          },
                        ),
                        // quickActionTile(
                        //     label: "Record Video",
                        //     icon: Stack(
                        //       children: [
                        //         const Icon(
                        //           Icons.videocam_rounded,
                        //           size: 30,
                        //           color: Colors.grey,
                        //         ),
                        //         Positioned(
                        //           top: 0,
                        //           left: 0,
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               color:
                        //                   Colors.grey.shade300.withOpacity(0.7),
                        //               borderRadius: BorderRadius.circular(20),
                        //             ),
                        //             child: const Icon(
                        //               Icons.visibility_rounded,
                        //               size: 16,
                        //               color: Colors.grey,
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     )),
                        // quickActionTile(
                        //     label: "Take pictures",
                        //     icon: const Icon(
                        //       Icons.photo_camera,
                        //       size: 30,
                        //       color: Colors.grey,
                        //     )),
                        // quickActionTile(
                        //     label: "Record Audio",
                        //     icon: Stack(
                        //       children: [
                        //         const Icon(
                        //           Icons.record_voice_over_rounded,
                        //           size: 30,
                        //           color: Colors.grey,
                        //         ),
                        //         Positioned(
                        //           bottom: 0,
                        //           right: 0,
                        //           child: Container(
                        //             decoration: BoxDecoration(
                        //               color:
                        //                   Colors.grey.shade300.withOpacity(0.7),
                        //               borderRadius: BorderRadius.circular(20),
                        //             ),
                        //             child: const Icon(
                        //               Icons.mic,
                        //               size: 16,
                        //               color: Colors.grey,
                        //             ),
                        //           ),
                        //         ),
                        //       ],
                        //     )),
                        // quickActionTile(
                        //     label: "Another action",
                        //     icon: const Icon(
                        //       Icons.circle_outlined,
                        //       size: 40,
                        //       color: Colors.grey,
                        //     )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0).copyWith(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Records",
                      style: Theme.of(context).textTheme.headline6!.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(),
                    const SizedBox(height: 12),
                    if (records.isEmpty)
                      const Center(
                        child: Text(
                          "No history available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            return records[index].type == "accident"
                                ? AccidentTile(accident: records[index])
                                : records[index].type == "incident"
                                    ? IncidentTile(incident: records[index])
                                    : records[index].type == "ambulance"
                                        ? AmbulanceTile(
                                            ambulance: records[index])
                                        : const SizedBox();
                          }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget quickActionTile(
      {required String label, required Widget icon, void Function()? onTap}) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16))),
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              height: 45,
              width: 45,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(50),
              ),
              child: icon,
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.fade,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Future resultDialog(String type) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(type == "report"
                ? "Successfully Reported"
                : type == "ambulance"
                    ? "Request recieved"
                    : "Success"),
            content: SizedBox(
              //height: result ? 70 : 40,
              height: 90,
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 40,
                  ),
                  const VerticalDivider(),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      type == "report"
                          ? const Text("Authorities with be alerted shortly")
                          : type == "ambulance"
                              ? const Text(
                                  "An ambulance is being contacted and we shall confirm shortly")
                              : const SizedBox(),
                    ],
                  )),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  showStatusBottomSheet() {
    // showBottomSheet(context: context, builder: (cont) {});
  }
}

class AccidentTile extends StatelessWidget {
  final Accident accident;
  const AccidentTile({Key? key, required this.accident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = TimeOfDay.fromDateTime(accident.dateTime);
    final String date = DateFormat("EEE, MMM d y").format(accident.dateTime);
    return Card(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                Text(" - ${time.format(context)}"),
              ],
            ),
            const Divider(
              indent: 20,
            ),
            const Text("Reported Accident"),
          ],
        ),
      ),
    );
  }
}

class IncidentTile extends StatelessWidget {
  final Incident incident;
  const IncidentTile({Key? key, required this.incident}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = TimeOfDay.fromDateTime(incident.dateTime!);
    final String date = DateFormat("EEE, MMM d y").format(incident.dateTime!);
    return Card(
      color: Colors.grey,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                Text(" - ${time.format(context)}"),
              ],
            ),
            const Divider(
              indent: 20,
            ),
            Text("Reported ${incident.name}"),
          ],
        ),
      ),
    );
  }
}

class AmbulanceTile extends StatelessWidget {
  final AmbulanceRequest ambulance;
  const AmbulanceTile({Key? key, required this.ambulance}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TimeOfDay time = TimeOfDay.fromDateTime(ambulance.dateTime!);
    final String date = DateFormat("EEE, MMM d y").format(ambulance.dateTime!);
    return Card(
      color: ambulance.status == "3"
          ? Colors.green
          : ambulance.status == "2"
              ? Colors.green.withOpacity(0.5)
              : Colors.grey,
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.only(right: 10),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.black.withOpacity(0.6)),
                ),
                Text(" - ${time.format(context)}"),
              ],
            ),
            const Divider(
              indent: 20,
            ),
            const Text("Requested for ambulance"),
            Text(
              "status: ${ambulance.status}",
              style: const TextStyle(color: Colors.black38),
            ),
          ],
        ),
      ),
    );
  }
}
