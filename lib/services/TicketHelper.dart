import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/MailerSendHelper.dart';

class TicketHelper {
  static Future<void> sendTicketOrder(CustomerModel newCustomer, TicketModel newTicket)
  async {
    var customer = await DataService.getCustomerByEmail(newCustomer.email!);
    customer ??= await DataService.updateCustomer(newCustomer);
    newTicket.customer = customer;
    var ticket = await DataService.updateTicket(newTicket);
    await MailerSendHelper.sendTicketPurchased(customer, ticket);
  }
}