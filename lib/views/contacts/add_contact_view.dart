import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/emergency_contact.dart';
import '../../widgets/dialogs.dart';
import '../app_viewmodel.dart';

class AddContactView extends StatefulWidget {
  final EmergencyContact? oldContact;
  final Function onComplete;
  const AddContactView({Key? key, this.oldContact, required this.onComplete})
      : super(key: key);

  @override
  _AddContactViewState createState() => _AddContactViewState();
}

class _AddContactViewState extends State<AddContactView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  void initState() {
    nameCtrl.text = widget.oldContact?.name ?? "";
    phoneCtrl.text = widget.oldContact?.phoneNumber ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
              child: Text(
                "Add a contact",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: nameCtrl,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Enter the contact's name";
                }
                return null;
              },
              decoration: _inputDeco(label: " Contact Name"),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 13,
              textInputAction: TextInputAction.done,
              decoration: _inputDeco(
                label: "Phone number",
                hint: 'Enter phone number (+2567...)',
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter the phone number';
                } else if (value.length != 13) {
                  return 'Invalid phone number';
                }
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // loadingDialog(context, message: "Adding contact");

                    // if (widget.oldContact != null) {
                    //   EmergencyContact contact = EmergencyContact(
                    //     id: widget.oldContact!.id,
                    //     name: nameCtrl.text,
                    //     phoneNumber: phoneCtrl.text,
                    //   );
                    //   appViewModel.repository
                    //       .editEmergencyContact(contact)
                    //       .then((value) {
                    //     popDialog(context);
                    //     //pop bottom sheet
                    //     Navigator.of(context).pop();
                    //     appViewModel.repository.notify();
                    //   });
                    //   appViewModel.repository.notify();
                    //   setState(() {});
                    //   widget.onComplete();
                    // } else {
                    //   EmergencyContact contact = EmergencyContact(
                    //     id: uuid.v4(),
                    //     name: nameCtrl.text,
                    //     phoneNumber: phoneCtrl.text,
                    //   );
                    //   appViewModel.repository
                    //       .registerEmergencyContact(contact)
                    //       .then((value) {
                    //     popDialog(context);
                    //     widget.onComplete();
                    //     //pop bottom sheet
                    //     Navigator.of(context).pop();
                    //   });
                    // }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(widget.oldContact != null
                      ? "Edit Contact"
                      : "Add Contact"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void editEmergencyContact(EmergencyContact contact) {
    appViewModel.repository.editEmergencyContact(contact).then((value) {
      popDialog(context);
      //pop bottom sheet
      Navigator.of(context).pop();
      appViewModel.repository.notify();
    });
    appViewModel.repository.notify();
    setState(() {});
    widget.onComplete();
  }

  InputDecoration _inputDeco({label, hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      // hintText: 'Enter your first name'
    );
  }
}
