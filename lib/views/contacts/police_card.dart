import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/main.dart';
import 'package:look_out/models/police_contact.dart';
import 'package:look_out/views/contacts/edit_location.dart';

import '../app_viewmodel.dart';

class PoliceCard extends StatefulWidget {
  const PoliceCard({Key? key}) : super(key: key);

  @override
  State<PoliceCard> createState() => _PoliceCardState();
}

class _PoliceCardState extends State<PoliceCard> {
  final appViewModel = GetIt.instance<AppViewModel>();

  List<PoliceContact> policeContacts = [];

  @override
  void initState() {
    policeContacts = appViewModel.repository.policeContacts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16.0).copyWith(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                          .copyWith(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Image.asset(
                          "assets/icons/police_logo.png",
                          height: 22,
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        "Uganda Police",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Text("Your Location: "),
                const Spacer(),
                Tooltip(
                  message: "Edit your current location",
                  child: TextButton.icon(
                    label: Text(
                      "Edit Location",
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                    onPressed: () async {
                      try {
                        showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => Padding(
                                  padding: MediaQuery.of(context).viewInsets,
                                  child: EditLocation(
                                    onComplete: (String newLocation) {
                                      appViewModel.repository
                                          .setCurrentLocation(newLocation);
                                      appViewModel.repository
                                          .getPoliceContactsForLocation(
                                              newLocation);
                                      policeContacts = appViewModel
                                          .repository.policeContacts;
                                      appViewModel.repository.notify();
                                      setState(() {});
                                    },
                                  ),
                                ));
                      } catch (e) {
                        printDebug(e.toString());
                      }
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                  .copyWith(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.location_on),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(appViewModel.repository.currentLocation),
                ],
              ),
            ),
            const Divider(),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("policeContacts")
                    .where(
                      "location",
                      isEqualTo: appViewModel.repository.currentLocation,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    if (snapshot.data?.docs.isNotEmpty ?? false) {
                      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
                          snapshot.data!.docs;
                      List<PoliceContact> policeContactsForLoc = docs
                          .map((doc) => PoliceContact.fromMap(doc.data()))
                          .toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: policeContactsForLoc.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return PoliceContactTile(
                              contact: policeContactsForLoc[index]);
                        },
                      );
                    }
                    return const SizedBox();
                  }
                }),
            // ...policeContacts
            //     .map((contact) => PoliceContactTile(contact: contact))
            //     .toList(),
          ],
        ),
      ),
    );
  }
}

class PoliceContactTile extends StatelessWidget {
  final PoliceContact contact;
  const PoliceContactTile({Key? key, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        launchCaller(contact.phoneNumber ?? "");
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey.shade100,
          // boxShadow: const <BoxShadow>[
          //   BoxShadow(
          //     color: Colors.black54,
          //     blurRadius: 0,
          //     spreadRadius: 1,
          //     offset: Offset(0.5, 0.8),
          //   )
          // ]
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name ?? "No name",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  const Divider(
                    endIndent: 80,
                  ),
                  Text(
                    contact.phoneNumber ?? "_",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
