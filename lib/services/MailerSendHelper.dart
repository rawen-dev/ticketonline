import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';

import 'ToastHelper.dart';

class MailerSendHelper{
  static Future<void> sendTicketPurchased(CustomerModel customer, TicketModel ticket) async {
    List<Map<String, String>> allVars = [
      {"var":"name", "value": customer.name!},
      {"var":"surname", "value": customer.surname!},
      {"var":"sex", "value": customer.sex??"male"},
      {"var":"email", "value": customer.email!},
      //{"var":"food", "value": ticket.extras[]},
      //{"var":"taxi", "value": email},
      //{"var":"table", "value": ticket.seat!.table!},
      //{"var":"seat", "value": ticket.seat!.name!},
      {"var":"price", "value": ticket.price.toString()},
    ];

    for(var e in ticket.options!)
    {
      allVars.add({"var":e.optionGroup!.code!, "value": e.name!});
    }

    await DataService.emailMailerSend(customer.email!, "o65qngk0emw4wr12", allVars);
    ToastHelper.Show("Email byl odeslán uživateli: ${customer.email!}");
    await Future.delayed(const Duration(milliseconds: 6000));
  }

}