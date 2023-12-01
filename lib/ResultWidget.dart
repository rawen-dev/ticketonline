import 'package:flutter/material.dart';
import 'package:ticketonline/models/TicketModel.dart';



class ResultWidget extends StatefulWidget {
  final TicketModel ticketModel;
  ResultWidget({Key? key, required this.ticketModel}) : super(key: key);
  @override
  State<ResultWidget> createState() => _ResultWidgetState(ticketModel);
}

class _ResultWidgetState extends State<ResultWidget> {
  final TicketModel ticketModel;

  _ResultWidgetState(this.ticketModel);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.green,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vstupenka byla zarezervována!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(width: 6,),
                  Icon(Icons.check_circle)
                ],
              ),
              Text("Informace k platbě najdete na e-mailu: ${ticketModel.customer?.email}")
            ],
          )
        ),
      ),
    );
  }
}
