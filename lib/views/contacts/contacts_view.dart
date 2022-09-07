import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons_null_safety/flutter_icons_null_safety.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/models/emergency_contact.dart';
import 'package:look_out/views/add_contact_view.dart';
import 'package:look_out/views/app_viewmodel.dart';
import 'package:look_out/views/contacts/police_card.dart';

import '../../main.dart';

class ContactsView extends StatefulWidget {
  const ContactsView({Key? key}) : super(key: key);

  @override
  _ContactsViewState createState() => _ContactsViewState();
}

class _ContactsViewState extends State<ContactsView> {
  List<EmergencyContact> emergencyContacts = [];
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  void initState() {
    emergencyContacts = appViewModel.repository.emergencyContacts;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white70,
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(4),
            child: const Text(
              "Below is a list of usefull contacts you might need in case of an emergency",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const PoliceCard(),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2)
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
                              child: const Icon(FlutterIcons.alert_circle_fea),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            const Text(
                              "Emergency Contacts",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: "Add a new emergency contact",
                        color: Theme.of(context).colorScheme.secondary,
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => Padding(
                                    padding: MediaQuery.of(context).viewInsets,
                                    child: AddContactView(
                                      onComplete: () {
                                        emergencyContacts = appViewModel
                                            .repository.emergencyContacts;
                                        setState(() {});
                                      },
                                    ),
                                  ));
                        },
                        icon: const Icon(Icons.person_add),
                      ),
                    ],
                  ),
                  const Divider(),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser?.uid)
                          .collection("emergencyContact")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              docs = snapshot.data?.docs ?? [];
                          return ListView.builder(
                              itemCount: docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                EmergencyContact emContact =
                                    EmergencyContact.fromMap(
                                        docs[index].data());
                                return EmergencyContactTile(
                                  contact: emContact,
                                  deleteEmergencyContact:
                                      deleteEmergencyContact,
                                  editEmergencyContact: (contact) {
                                    showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => Padding(
                                              padding: MediaQuery.of(context)
                                                  .viewInsets,
                                              child: AddContactView(
                                                oldContact: contact,
                                                onComplete: () {
                                                  emergencyContacts =
                                                      appViewModel.repository
                                                          .emergencyContacts;
                                                  setState(() {});
                                                },
                                              ),
                                            ));
                                  },
                                );
                              });
                        } else {
                          return const SizedBox();
                        }
                      }),
                  // ...emergencyContacts
                  //     .map((contact) => EmergencyContactTile(
                  //         contact: contact,
                  //         deleteEmergencyContact: deleteEmergencyContact))
                  //     .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget contactTile(BuildContext context,
  //     {required Contact contact, required String type}) {
  //   return Container(
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(8),
  //       color: Colors.grey.shade100,
  //       // boxShadow: const <BoxShadow>[
  //       //   BoxShadow(
  //       //     color: Colors.black54,
  //       //     blurRadius: 0,
  //       //     spreadRadius: 1,
  //       //     offset: Offset(0.5, 0.8),
  //       //   )
  //       // ]
  //     ),
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     margin: const EdgeInsets.symmetric(vertical: 2),
  //     child: Row(
  //       children: [
  //         const SizedBox(
  //           width: 20,
  //         ),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 contact.name ?? "No name",
  //                 style: const TextStyle(
  //                   fontSize: 18,
  //                 ),
  //               ),
  //               Divider(
  //                 endIndent: (type == "police") ? 80 : null,
  //               ),
  //               Text(
  //                 contact.phoneNumber ?? "_",
  //                 style: const TextStyle(color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //         ),
  //         if (type == "emergency")
  //           IconButton(
  //             tooltip: "Edit contact",
  //             color: Colors.white,
  //             onPressed: () {
  //               showModalBottomSheet(
  //                   context: context,
  //                   isScrollControlled: true,
  //                   builder: (context) => Padding(
  //                         padding: MediaQuery.of(context).viewInsets,
  //                         child: AddContactView(
  //                           oldContact: contact,
  //                           onComplete: () {
  //                             emergencyContacts =
  //                                 appViewModel.repository.emergencyContacts;
  //                             setState(() {});
  //                           },
  //                         ),
  //                       ));
  //             },
  //             icon: Container(
  //                 padding: const EdgeInsets.all(4),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: Theme.of(context).colorScheme.secondary,
  //                 ),
  //                 child: const Icon(Icons.edit)),
  //           ),
  //         if (type == "emergency")
  //           IconButton(
  //             tooltip: "Delete contact",
  //             color: Colors.white,
  //             onPressed: () {
  //               deleteEmergencyContact(contact);
  //             },
  //             icon: Container(
  //                 padding: const EdgeInsets.all(4),
  //                 decoration: BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   color: Theme.of(context).colorScheme.secondary,
  //                 ),
  //                 child: const Icon(Icons.delete)),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  void deleteEmergencyContact(EmergencyContact contact) {
    appViewModel.repository.deleteEmergencyContact(contact);
    setState(() {});
  }
}

class EmergencyContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final Function(EmergencyContact) deleteEmergencyContact;
  final Function(EmergencyContact) editEmergencyContact;
  const EmergencyContactTile(
      {Key? key,
      required this.contact,
      required this.deleteEmergencyContact,
      required this.editEmergencyContact})
      : super(key: key);

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
                  const Divider(),
                  Text(
                    contact.phoneNumber ?? "_",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: "Edit contact",
              color: Colors.white,
              onPressed: () {
                editEmergencyContact(contact);
              },
              icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Icon(Icons.edit)),
            ),
            IconButton(
              tooltip: "Delete contact",
              color: Colors.white,
              onPressed: () {
                deleteEmergencyContact(contact);
              },
              icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Icon(Icons.delete)),
            ),
          ],
        ),
      ),
    );
  }
}
