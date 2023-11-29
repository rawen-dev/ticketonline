import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/OptionGroup.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/TicketModel.dart';

class DataService{
  static final _supabase = Supabase.instance.client;
  static Future<void> emailMailerSend(String recipient, String templateId, List<Map<String, String>> variables)
  async {
    await _supabase.rpc("send_email_mailersend",
        params: {"message": {
          "sender": "info@ff23.cz",
          "recipient": recipient,
          "template_id": templateId
        }, "subs": variables});
  }

  static Future<CustomerModel> updateCustomer(CustomerModel customer)
  async {
    var userData = await _supabase.from(CustomerModel.customerTable).upsert(customer.toJson()).select().single();
    return CustomerModel.fromJson(userData);
  }

  static Future<TicketModel> updateTicket(TicketModel ticket)
  async {
    var data = await _supabase.from(TicketModel.ticketTable).upsert(ticket.toJson()).select().single();
    var updatedTicket = TicketModel.fromJson(data);
    ticket.id = updatedTicket.id;
    if(ticket.seat != null)
    {
      await _supabase.from(TicketModel.ticketSeatTable).upsert({"ticket":ticket.id, "seat":ticket.seat!.id});
    }
    if(ticket.options != null)
    {
      for(var e in ticket.options!)
      {
        await _supabase.from(TicketModel.ticketExtraTable).upsert({"ticket":ticket.id, "option":e.id});
      }
    }
    return ticket;
  }

  static Future<List<OptionGroupModel>> getAllOptionGroups()
  async {
    var data = await _supabase
        .from(OptionGroupModel.optionGroupTable)
        .select(
        "${OptionGroupModel.idColumn},"
        "${OptionGroupModel.nameColumn},"
        "${OptionGroupModel.codeColumn},"
        "${OptionModel.optionTable}"
        "("
        "${OptionModel.idColumn},"
        "${OptionModel.nameColumn},"
        "${OptionModel.priceColumn}"
        ")");
    var d = List<OptionGroupModel>.from(
        data.map((x) => OptionGroupModel.fromJson(x)));
    return d;
  }

  static Future<CustomerModel?> getCustomerByEmail(String email)
  async {
    var data = await _supabase
        .from(CustomerModel.customerTable)
        .select()
        .eq(CustomerModel.emailColumn, email)
        .maybeSingle();
    if(data!=null)
    {
      return CustomerModel.fromJson(data);
    }
    return null;
  }
}