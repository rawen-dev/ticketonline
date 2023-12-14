import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:ticketonline/models/OptionGroupModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/MailerSendHelper.dart';

class DialogHelper{

  static Future<void> showInformationDialogAsync(
      BuildContext context,
      String titleMessage,
      String textMessage,
      [String buttonMessage = "Ok"]) async{
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleMessage),
            content: Text(textMessage),
            actions: [
              ElevatedButton(
                child: Text(buttonMessage),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


  static Future<void> showTicketDialog(
      BuildContext context,
      String titleMessage,
      TicketModel ticket) async{
    ScreenshotController screenshotController = ScreenshotController();

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleMessage),
            content: Screenshot(
              controller: screenshotController,
              child: ticketImageContainer(ticket)),
            actions: [
              ElevatedButton(
                child: const Text("Odeslat vstupenku (bez dalších akcí)"),
                onPressed: () async {
                  await MailerSendHelper.sendTicket(ticket);
                },
              ),
              ElevatedButton(
                child: const Text("Stáhnout"),
                onPressed: () async {
                  var captured = await screenshotController.capture();
                  if(captured==null)
                  {
                    return;
                  }
                  await WebImageDownloader.downloadImageFromUInt8List(uInt8List: captured, name: ticket.toBasicString());
                },
              ),
              ElevatedButton(
                child: const Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                  return;
                },
              ),
            ],
          );
        });
  }

  static Container ticketImageContainer(TicketModel ticket) {
    var placeTextStyle = TextStyle(color: Color(0xFFF6EBD8), fontWeight: FontWeight.w700, fontSize: 26);
    var foodTextStyle = TextStyle(color: Color(0xFFF6EBD8), fontWeight: FontWeight.w700, fontSize: 16);
    return Container(
              width: 1024,
              child: Stack(
                  children: [
                Image(image: AssetImage("assets/vstupenky.png"),),
                Padding(
                  padding: EdgeInsets.fromLTRB(205, 290, 0,  0),
                  child: Text(ticket.box!.boxGroup!.name!, style: placeTextStyle)),
                Padding(
                    padding: EdgeInsets.fromLTRB(205, 324, 0,  0),
                    child: Text(ticket.box!.name!, style: placeTextStyle)),
                Padding(
                    padding: EdgeInsets.fromLTRB(205, 365, 0,  0),
                    child: Text(ticket.options?.firstWhereOrNull((element) => element.optionGroup!.code==OptionGroupModel.foodOption)?.name??"", style: foodTextStyle)),
                Padding(
                  padding: EdgeInsets.fromLTRB(810, 260, 0,  0),
                  child: QrImageView(
                    data: ticket.id.toString(),
                    version: QrVersions.auto,
                    size: 120,
                    gapless: false,
                    dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFFFD3BFA0)),
                    eyeStyle: QrEyeStyle(color: Color(0xFFD3BFA0), eyeShape: QrEyeShape.square),),)
                  ],),
            );
  }

  static Future<bool> showConfirmationDialogAsync(
      BuildContext context,
      String titleMessage,
      String textMessage,
  {
    String confirmButtonMessage = "Ok",
    String cancelButtonMessage = "Storno"
}
      ) async {
    bool result = false;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(titleMessage),
            content: SingleChildScrollView(child: Text(textMessage)),
            actions: [
              ElevatedButton(
                child: Text(cancelButtonMessage),
                onPressed: () {
                  result = false;
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text(confirmButtonMessage),
                onPressed: () {
                  result = true;
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    return result;
  }

  static Future<String?> showTextInputDialog(
      BuildContext context,
      String titleMessage,
      String hint,
      String confirmButtonMessage,
      String cancelButtonMessage,
      ) async {
    final TextEditingController _messageController = TextEditingController();
    String? result;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleMessage),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(hintText: hint),
                  onChanged: (str){ result = str;},
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(cancelButtonMessage),
            ),
            TextButton(
              onPressed: () async {
                result = _messageController.text;
                _messageController.clear();
                Navigator.pop(context);
              },
              child: Text(confirmButtonMessage),
            ),
          ],
        );
      },
    );
    return result;
  }
}