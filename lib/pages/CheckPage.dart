import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/pages/DashboardPage.dart';
import 'package:ticketonline/pages/LoginPage.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/ToastHelper.dart';



class CheckPage extends StatefulWidget {
  static const ROUTE = "/check";
  const CheckPage({Key? key}) : super(key: key);

  @override
  _CheckPageState createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {

  int? ticketId;
  TicketModel? ticket;
  int? currentOccasion;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    if(DataService.currentUserId()==null)
    {
      context.go(LoginPage.ROUTE);
      return;
    }
    currentOccasion = await DataService.getCurrentUserOccasion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(padding: const EdgeInsets.all(12.0),
              decoration: ticket == null ? null : ticket!.state != TicketModel.paidState ? BoxDecoration(color: Colors.redAccent) : BoxDecoration(color: Colors.greenAccent),
              child:
                Stack(
                  children:[
                    Positioned(
                      top: 0,
                      right: 0,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.go(DashboardPage.ROUTE);
                        },
                        icon: const Icon(
                          Icons.list_outlined,
                          size: 24.0,
                        ),
                        label: const Text("Dashboard"),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Text("ID: ${ticketId??""}"),
                        Text("JMÉNO: ${ticket?.customer.toString()??""}"),
                        Text("STAV: ${ticket?.state.toString()??""}"),
                        Text("SEDADLO: ${ticket?.box.toString()??""}"),
                        Text("JÍDLO: ${ticket?.foodOption()??""}"),
                        Text("CENA: ${ticket?.price.toString()??""}"),
                        Text("ODVOZ: ${ticket?.taxiOption().toString()??""}"),
                        Text("POZNÁMKA: ${ticket?.note.toString()??""}"),
                        Text("SKRYTÁ POZNÁMKA: ${ticket?.hiddenNote.toString()??""}"),

                        const SizedBox(height: 12),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: ticket == null || ticket!.state != TicketModel.paidState ? null : () async {
                                  await DataService.updateTicketState(ticket!, TicketModel.usedState);
                                  var ticketList = await DataService.getAllTickets(currentOccasion!, [ticket!.id!]);
                                  setState(() {
                                    ticket = ticketList.firstOrNull;
                                  });
                                  ToastHelper.Show("Vstup byl potvrzen.");
                                },
                                child: Text("Potvrdit vstup"),
                              ),
                            ]
                        )
                      ],)
                  ],
                ),),
            Expanded(
              child: MobileScanner(
                fit: BoxFit.fitWidth,
                controller: MobileScannerController(
                    formats: [BarcodeFormat.qrCode],
                    detectionSpeed: DetectionSpeed.noDuplicates),
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  var id = barcodes.firstOrNull;
                  if(id!=null)
                  {
                    debugPrint(id.rawValue);
                    var newTicketId = int.tryParse(id.rawValue!);
                    if(ticketId==newTicketId)
                    {
                      return;
                    }

                    setState(() {
                      ticketId=newTicketId;
                    });

                    if(ticketId==null || currentOccasion==null)
                    {
                      return;
                    }

                    var ticketList = await DataService.getAllTickets(currentOccasion!, [ticketId!]);
                    setState(() {
                      ticket = ticketList.firstOrNull;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}