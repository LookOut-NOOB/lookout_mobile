import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../app.dart';
import '../../models/incident.dart';
import '../../widgets/dialogs.dart';
import '../app_viewmodel.dart';

class ReportIncident extends StatefulWidget {
  static const String routeName = "/report_incident";
  final Function(String type)? resetSuccess;
  const ReportIncident({Key? key, this.resetSuccess}) : super(key: key);

  @override
  _ReportIncidentState createState() => _ReportIncidentState();
}

class _ReportIncidentState extends State<ReportIncident> {
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _incidentCtrl = TextEditingController();
  final TextEditingController _statementCtrl = TextEditingController();
  bool shareContact = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReportIncident;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Incident"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Card(
                  child: Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          decoration: _inputDeco(),
                          controller: _locationCtrl,
                          validator: (content) {
                            if (content!.isEmpty) {
                              return "Please provide the location";
                            }
                            return null;
                          },
                        ),
                      )),
                      const SizedBox(
                        width: 2,
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.location_pin)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _incidentCtrl,
                  decoration:
                      _inputDecoOutline(hint: 'Name to describe incident'),
                ),
                const Divider(),
                CheckboxListTile(
                    value: shareContact,
                    title: const Text("Share my contact information"),
                    subtitle: const Text(
                        "Your name and phone number will be shared to authorities for more inquiries"),
                    onChanged: (newValue) {
                      setState(() {
                        shareContact = newValue ?? false;
                      });
                    }),
                const SizedBox(
                  height: 20,
                ),
              ])),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _statementCtrl,
                    decoration: _inputDecoOutline(
                        hint:
                            'Provide a brief statement to describe more (optional)'),
                    minLines: 5,
                    maxLines: 10,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          loadingDialog(context, message: "Reporting Incident");
                          Incident incident = Incident(
                            id: uuid.v1(),
                            name: _incidentCtrl.text,
                            location: _locationCtrl.text,
                            dateTime: DateTime.now(),
                            statement: _statementCtrl.text,
                            userId: shareContact
                                ? appViewModel.repository.profile?.uid
                                : null,
                          );
                          appViewModel.repository
                              .reportIncident(incident)
                              .then((value) {
                            popDialog(context);
                            if (value) {
                              //pop route
                              Navigator.of(context).pop();
                              args.resetSuccess!("report");
                            }
                          });
                        }
                      },
                      child: const Text("Report")),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco({label}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(0),
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.black87,
      ),
      hintText: "Enter location or tap icon to get map",
      border: const OutlineInputBorder(borderSide: BorderSide.none),
    );
  }

  InputDecoration _inputDecoOutline({label, hint}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: hint,
    );
  }
}
