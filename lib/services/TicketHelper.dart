import 'package:ticketonline/models/OrderModel.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/MailerSendHelper.dart';

class TicketHelper {
  static Future<void> sendTicketOrder(OrderModel order)
  async {
    var ticketId = await DataService.orderTicket(order);
    var ticket = (await DataService.getAllTickets(order.occasion!, [ticketId])).first;
    await MailerSendHelper.sendTicketOrder(ticket);
  }
}