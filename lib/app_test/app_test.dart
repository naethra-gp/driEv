import 'package:flutter/material.dart';

class AppTest extends StatefulWidget {
  const AppTest({super.key});

  @override
  State<AppTest> createState() => _AppTestState();
}

class _AppTestState extends State<AppTest> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.1,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Do a Thing',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Text(
                      'This is some text ${(constraints.maxHeight / 55).roundToDouble()}',
                      style: TextStyle(
                          fontSize:
                              (constraints.maxHeight / 55).roundToDouble()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
