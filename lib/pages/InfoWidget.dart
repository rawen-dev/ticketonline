import 'package:flutter/material.dart';


class InfoWidget extends StatefulWidget {
  final String text;
  InfoWidget({Key? key, required this.text}) : super(key: key);
  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  _InfoWidgetState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            color: Colors.white12,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    SizedBox(width: 6,),
                  ],
                ),
              ],
            )
        ),
      ),
    );
  }
}
