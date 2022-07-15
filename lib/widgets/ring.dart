import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Ring extends StatefulWidget {
  final IconData? icon;
  final Function? action;

  const Ring({Key? key, this.icon, this.action}) : super(key: key);

  @override
  _RingState createState() => _RingState();
}

class _RingState extends State<Ring> {
  final Map<int, Widget> indicators = {
    1: const SpinKitRipple(
      color: Colors.white,
      size: 300,
    ),
    2: const SpinKitPulse(
      color: Colors.white,
      size: 300,
    ),
    4: const SpinKitPulse(
      color: Colors.white,
      size: 300,
    ),
  };

  final Map<int, String> captions = {
    1: "Connecting...",
    2: "Ringing...",
    4: "Ringing...",
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.redAccent.shade700,
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "Ringing...",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    height: 300, width: double.infinity, child: indicators[2]),
                Icon(
                  widget.icon ?? Icons.warning_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  onPressed: () {
                    if (widget.action != null) widget.action!();
                  },
                  child: Text(
                    "Stop Panic",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

class Success extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.check_circle,
            size: 30,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
