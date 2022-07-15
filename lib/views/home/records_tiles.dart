import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/accident.dart';
import '../../models/ambulance_request.dart';
import '../../models/incident.dart';

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
      color: ambulance.status == "complete"
          ? Colors.green
          : ambulance.status == "accepted"
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
