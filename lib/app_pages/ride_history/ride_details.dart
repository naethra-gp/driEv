import 'package:flutter/material.dart';

class RideDetails extends StatefulWidget {
  final List rideId;
  const RideDetails({super.key, required this.rideId});

  @override
  State<RideDetails> createState() => _RideDetailsState();
}

class _RideDetailsState extends State<RideDetails> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(widget.rideId.toString()),
      ),
    );
  }
}
