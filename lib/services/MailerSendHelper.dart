import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';

import 'ToastHelper.dart';

class MailerSendHelper{
  static Future<void> sendTicketPurchased(CustomerModel customer, TicketModel ticket) async {
    List<Map<String, String>> allVars = [
      {"var":"varSymbol", "value": ticket.id.toString()},
      {"var":"name", "value": customer.name!},
      {"var":"surname", "value": customer.surname!},
      {"var":"sex", "value": customer.sex??"male"},
      {"var":"email", "value": customer.email!},
      {"var":"table", "value": ticket.box!.boxGroup!.name!},
      {"var":"seat", "value": ticket.box!.name!},
      {"var":"price", "value": ticket.price.toString()},
      {"var":"note", "value": ticket.note??"" },
    ];

    for(var e in ticket.options!)
    {
      allVars.add({"var":e.optionGroup!.code!, "value": e.name!});
    }

    await DataService.emailMailerSend(customer.email!, "pxkjn415990lz781", allVars);
    ToastHelper.Show("Email byl odeslán uživateli: ${customer.email!}");
    await Future.delayed(const Duration(milliseconds: 6000));
  }

}