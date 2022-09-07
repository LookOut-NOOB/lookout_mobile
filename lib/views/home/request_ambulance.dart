import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:location/location.dart';
import 'package:look_out/main.dart';
import 'package:look_out/models/ambulance_request.dart';
import 'package:look_out/services/location_service.dart';
import 'package:look_out/widgets/dialogs.dart';

import '../../app.dart';
import '../app_viewmodel.dart';

class RequestAmbulance extends StatefulWidget {
  static const String routeName = "/request_ambulance";
  final Function(String type)? resetSuccess;
  final String label;
  const RequestAmbulance(
      {Key? key, this.resetSuccess, this.label = "Request Ambulance"})
      : super(key: key);

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
        title: Text(widget.label),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              SliverList(
                  delegate: SliverChildListDelegate([
                Container(
                  padding: const EdgeInsets.all(2),
                  height: MediaQuery.of(context).size.width / 4,
                  width: MediaQuery.of(context).size.width / 4,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // color: Colors.black12,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Hero(
                    tag: widget.label,
                    child: Image.asset(
                      "assets/images/ambulance.png",
                      color: Colors.red,
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: const [
                        Icon(Icons.location_pin),
                        SizedBox(
                          width: 2,
                        ),
                        Expanded(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Your location is being captured and submitted automatically!",
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        )),
                      ],
                    ),
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
                      "Incase of any additional details, or another contact phone number. Please provide the details below."),
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
                          loadingDialog(context, message: "Submitting request");
                          LocationService()
                              .getCurrentLocation()
                              .then((LocationData? locationData) {
                            GeoPoint? geoPoint;
                            if (locationData != null) {
                              geoPoint = GeoPoint(locationData.latitude!,
                                  locationData.longitude!);
                              AmbulanceRequest ambRequest = AmbulanceRequest(
                                  id: uuid.v1(),
                                  location: geoPoint,
                                  status: "1",
                                  comment: _commentCtrl.text,
                                  userId: appViewModel.repository.profile?.uid,
                                  dateTime: DateTime.now());
                              appViewModel.repository
                                  .requestAmbulance(ambRequest)
                                  .then((value) {
                                popDialog(context);
                                if (value) {
                                  //pop route
                                  Navigator.of(context).pop();
                                  args.resetSuccess!("ambulance");
                                }
                              });
                            } else {
                              popDialog(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Failed to get current location')));
                            }
                          }).catchError((error) {
                            popDialog(context);
                            printDebug("Error getting location: $error");
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error getting current location')));
                          });
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
///1=>pending
///2=>accepted
///3=>complete
///0=>cancelled