import 'package:flutter/material.dart';

class NoInterNet extends StatefulWidget {
  const NoInterNet({super.key});

  @override
  State<NoInterNet> createState() => _NoInterNetState();
}

class _NoInterNetState extends State<NoInterNet> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/img/no-internet.png",
                height: 200,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Oops!',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontFamily: "Poppins"),
            ),
            const SizedBox(height: 20),
            const Text(
              'No internet connection was found. Check your internet connection or try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontFamily: "Poppins"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
