import 'package:agileplanning/components/scaffolds/scaffold_plain.component.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPlain(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
