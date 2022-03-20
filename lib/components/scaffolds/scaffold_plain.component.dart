import 'package:flutter/material.dart';

class ScaffoldPlain extends StatelessWidget {
  final Widget body;

  const ScaffoldPlain({
    Key key,
    @required this.body,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        child: body,
        padding: EdgeInsets.only(
          top: 122.0,
          bottom: 76.0,
          left: 20.0,
          right: 20.0,
        ),
      ),
    );
  }
}
