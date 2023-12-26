import 'package:flutter/material.dart';
import 'package:ticketonline/models/OrderModel.dart';
import 'dart:html' as html;


class ResultWidget extends StatefulWidget {
  final OrderModel ticketModel;
  ResultWidget({Key? key, required this.ticketModel}) : super(key: key);
  @override
  State<ResultWidget> createState() => _ResultWidgetState(ticketModel);
}

class _ResultWidgetState extends State<ResultWidget> {
  final OrderModel orderModel;

  _ResultWidgetState(this.orderModel);


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
                  Text("Rezervace Tvé vstupenky proběhla úspěšně.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  SizedBox(width: 6,),
                  Icon(Icons.check_circle)
                ],
              ),
              Text("Další informace nalezneš na svém mailu (${orderModel.email}). Těšíme se na setkání!"),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  html.window.location.reload();
                },
                child: const Text("Rezervovat další vstupenku"),
              ),
            ],
          )
        ),
      ),
    );
  }
}
