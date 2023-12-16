import 'package:flutter/material.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'dart:html' as html;


class InfoWidget extends StatefulWidget {
  InfoWidget({Key? key}) : super(key: key);
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
                    Text("Rezervace vstupenek je pro dnešek pozastavena.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
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
