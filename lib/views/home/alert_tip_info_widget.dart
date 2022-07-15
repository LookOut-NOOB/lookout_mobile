import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../models/alert.dart';
import '../app_viewmodel.dart';

class AlertTipInfoWidget extends StatelessWidget {
  AlertTipInfoWidget({Key? key}) : super(key: key);
  final AppViewModel appViewModel = GetIt.instance<AppViewModel>();
  final Alert _alert = Alert(
    type: "alert",
    message:
        "Avoid walking in areas along Northern bypass today, as many robbery incidents have been reported in this area.",
    dateTime: DateTime.now(),
  );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: appViewModel.repository.getTip(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0).copyWith(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _alert.type == "alert"
                                  ? Colors.red
                                  : _alert.type == "info"
                                      ? Colors.grey
                                      : Colors.amber,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Text(
                              _alert.type == "alert"
                                  ? "Alert !"
                                  : _alert.type == "info"
                                      ? "Info"
                                      : "Tip",
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
                                color: Theme.of(context).colorScheme.secondary,
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
                              color: _alert.type == "alert"
                                  ? Colors.red
                                  : _alert.type == "info"
                                      ? Colors.grey
                                      : Colors.amber,
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
                          const Expanded(
                            child: Text(
                                "Avoid walking in areas along Northern bypass today, as many robbery incidents have been reported in this area."),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          } else {
            return const SizedBox();
          }
        });
  }
}
