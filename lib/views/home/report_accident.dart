import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_viewmodel.dart';

class ReportAccident extends StatefulWidget {
  static const String routeName = "/report_accident";
  final Function(String type)? resetSuccess;
  const ReportAccident({Key? key, this.resetSuccess}) : super(key: key);

  @override
  _ReportAccidentState createState() => _ReportAccidentState();
}

class _ReportAccidentState extends State<ReportAccident> {
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _statementCtrl = TextEditingController();
  bool shareContact = false;
  List<String> myList = ["Tonny", "Baw"];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ReportAccident;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Report Accident"),
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
                const Divider(),
                CheckboxListTile(
                    value: shareContact,
                    title: const Text("Share my contact information"),
                    subtitle: const Text(
                        "This will be used by authorities to get in touch for more inquiries"),
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
                    decoration: _inputDecoOutline(),
                    minLines: 5,
                    maxLines: 10,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // loadingDialog(context, message: "Reporting Accident");
                          // Accident accident = Accident(
                          //   id: uuid.v1(),
                          //   dateTime: DateTime.now(),
                          //   location: _locationCtrl.text,
                          //   statement: _statementCtrl.text,
                          //   userId: shareContact
                          //       ? appViewModel.repository.profile?.uid
                          //       : null,
                          // );
                          // appViewModel.repository
                          //     .reportAccident(accident)
                          //     .then((value) {
                          //   popDialog(context);
                          //   if (value) {
                          //     //pop route
                          //     Navigator.of(context).pop();
                          //     args.resetSuccess!("report");
                          //   }
                          // });
                        }
                      },
                      child: const Text("Report")),
                ]),
              ),
              // SliverList(
              //     delegate: SliverChildListDelegate([
              //   Card(
              //     child: Padding(
              //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //       child: Row(
              //         children: [
              //           Expanded(
              //             child: Text("Attach photos (Optional)",
              //                 style: Theme.of(context).textTheme.subtitle1),
              //           ),
              //           IconButton(
              //             onPressed: () {
              //               setState(() {});
              //             },
              //             tooltip: "Add photos",
              //             icon: const Icon(Icons.add_a_photo_outlined),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ])),
              // SliverGrid(
              //     delegate: SliverChildBuilderDelegate((context, index) {
              //       return Text(myList[index]);
              //     }, childCount: myList.length),
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 3)),
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

  InputDecoration _inputDecoOutline({label}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: 'Provide a brief statement (optional)',
    );
  }
}
