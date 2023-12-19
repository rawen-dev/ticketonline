import 'dart:convert';

import 'package:screenshot/screenshot.dart';
import 'package:ticketonline/models/EmailMetadataModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/DialogHelper.dart';

import 'ToastHelper.dart';

class MailerSendHelper{
  static Future<void> sendTicketPaid(TicketModel ticket) async {

    List<Map<String, String>> allVars = getAllVarsFromTicket(ticket);

    var ticketImage = DialogHelper.ticketImageContainer(ticket);
    ScreenshotController controller = ScreenshotController();
    var imageData = await controller.captureFromWidget(ticketImage);
    var imageEncoded = base64.encode(imageData);

    var attachment = {
      "filename":"${ticket.toBasicString()}.png",
      "content":imageEncoded
    };

    var templateId = await DataService.getEmailTemplate(TicketModel.paidState, ticket.occasion!);
    var metadata = EmailMetadataModel(template: templateId, subject: ticket.id!, recipient: ticket.customer!.email!, occasion: ticket.occasion!);
    await DataService.emailWithAttachmentMailerSend(metadata, allVars, attachment);
    ToastHelper.Show("E-mail byl odeslán na: ${ticket.customer!.email!}");
  }

  static List<Map<String, String>> getAllVarsFromTicket(TicketModel ticket) {
    List<Map<String, String>> allVars = [
      {"var":"varSymbol", "value": ticket.id.toString()},
      {"var":"name", "value": ticket.customer!.name!},
      {"var":"surname", "value": ticket.customer!.surname!},
      {"var":"sex", "value": ticket.customer!.sex??"male"},
      {"var":"email", "value": ticket.customer!.email!},
      {"var":"table", "value": ticket.box!.boxGroup!.name!},
      {"var":"seat", "value": ticket.box!.name!},
      {"var":"price", "value": ticket.price.toString()},
      {"var":"note", "value": ticket.note??"" },
    ];

    for(var e in ticket.options!)
    {
      allVars.add({"var":e.optionGroup!.code!, "value": e.name!});
    }
    return allVars;
  }

  static Future<void> sendTicketPurchased(TicketModel ticket) async {
    var allVars = getAllVarsFromTicket(ticket);

    var templateId = await DataService.getEmailTemplate(TicketModel.reservedState, ticket.occasion!);
    var metadata = EmailMetadataModel(template: templateId, subject: ticket.id!, recipient: ticket.customer!.email!, occasion: ticket.occasion!);
    await DataService.emailWithAttachmentMailerSend(metadata, allVars, null);
    ToastHelper.Show("E-mail byl odeslán na: ${ticket.customer!.email!}");
  }

  static Future<void> sendTicketStorno(TicketModel ticket) async {
    var allVars = getAllVarsFromTicket(ticket);

    var templateId = await DataService.getEmailTemplate(TicketModel.stornoState, ticket.occasion!);
    var metadata = EmailMetadataModel(template: templateId, subject: ticket.id!, recipient: ticket.customer!.email!, occasion: ticket.occasion!);
    await DataService.emailWithAttachmentMailerSend(metadata, allVars, null);
    ToastHelper.Show("E-mail byl odeslán na: ${ticket.customer!.email!}");
  }

  static Future<void> waitForApiLimit()
  async {
    await Future.delayed(const Duration(milliseconds: 6000));
  }

}