import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../app_viewmodel.dart';

class RequestAmbulance extends StatefulWidget {
  static const String routeName = "/request_ambulance";
  final Function(String type)? resetSuccess;
  const RequestAmbulance({Key? key, this.resetSuccess}) : super(key: key);

  @override
  _RequestAmbulanceState createState() => _RequestAmbulanceState();
}

class _RequestAmbulanceState extends State<RequestAmbulance> {
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _commentCtrl = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final appViewModel = GetIt.instance<AppViewModel>();

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as RequestAmbulance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Ambulance"),
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
                              return "Choose a location";
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
                const SizedBox(
                  height: 20,
                ),
              ])),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(
                    height: 1,
                  ),
                  const Text(
                      "Incase of any additional details, you may want the emergency team to know, or another contact phone. Please provide the details below."),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _commentCtrl,
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
                          // loadingDialog(context, message: "Submitting request");
                          // AmbulanceRequest ambRequest = AmbulanceRequest(
                          //     id: uuid.v1(),
                          //     location: _locationCtrl.text,
                          //     status: "pending",
                          //     comment: _commentCtrl.text,
                          //     userId: appViewModel.repository.profile?.uid,
                          //     dateTime: DateTime.now());
                          // appViewModel.repository
                          //     .requestAmbulance(ambRequest)
                          //     .then((value) {
                          //   popDialog(context);
                          //   if (value) {
                          //     //pop route
                          //     Navigator.of(context).pop();
                          //     args.resetSuccess!("ambulance");
                          //   }
                          // });
                        }
                      },
                      child: const Text("Request")),
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

  InputDecoration _inputDecoOutline({label}) {
    return InputDecoration(
      contentPadding: const EdgeInsets.all(8),
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      hintText: 'Provide additional details',
    );
  }
}


///Ambulance request status
///=>pending
///=>accepted
///=>complete
///=>cancelled