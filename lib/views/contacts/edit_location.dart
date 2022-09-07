import 'package:drop_down_list/drop_down_list.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:look_out/models/app_location.dart';

import '../app_viewmodel.dart';

class EditLocation extends StatefulWidget {
  final Function(String location) onComplete;
  const EditLocation({Key? key, required this.onComplete}) : super(key: key);

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController inputCtrl = TextEditingController();
  final appViewModel = GetIt.instance<AppViewModel>();
  String selectedCity = "";
  bool isCitySelected = true;
  List<String> locationNames = [];
  String currentLocation = "";

  @override
  void initState() {
    super.initState();
    currentLocation = appViewModel.repository.currentLocation;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      appViewModel.repository.getRegisteredLocations().then((value) {
        locationNames = appViewModel.repository.locations
            .map((AppLocation appLocation) => appLocation.name)
            .toList();
      });
    });
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
                "Pick a Location",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: inputCtrl,
              cursorColor: Colors.black,
              onTap: isCitySelected
                  ? () {
                      FocusScope.of(context).unfocus();
                      onTextFieldTap();
                    }
                  : null,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.black12,
                contentPadding:
                    EdgeInsets.only(left: 8, bottom: 0, top: 0, right: 15),
                hintText: "e.g Wandegeya",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please choose a location";
                } else if (!locationNames.contains(value)) {
                  return "Unregistered location, please choose a location nearest to you";
                }
                return null;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onComplete(inputCtrl.text);
                    Navigator.of(context).pop();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("Use as Location"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// This is on text changed method which will display on city text field on changed.
  void onTextFieldTap() {
    TextEditingController searchTextEditingController = TextEditingController();
    DropDownState(
      DropDown(
        enableMultipleSelection: false,
        submitButtonText: "Done",
        submitButtonColor: const Color.fromRGBO(70, 76, 222, 1),
        searchHintText: "Search for location",
        bottomSheetTitle: "Locations",
        searchBackgroundColor: Colors.black12,
        dataList: locationNames.map((String location) {
          return SelectedListItem(false, location);
        }).toList(),
        selectedItem: (String selected) {
          inputCtrl.text = selected;
        },
        searchController: searchTextEditingController,
      ),
    ).showModal(context);
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
