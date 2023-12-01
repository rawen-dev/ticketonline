import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticketonline/models/BoxGroupModel.dart';
import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/OccasionModel.dart';
import 'package:ticketonline/models/OptionGroupModel.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/RoomModel.dart';
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
    if(ticket.box != null)
    {
      ticket.box!.type = BoxModel.soldType;
      await updateBoxes([ticket.box!]);
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

  static Future<List<OptionGroupModel>> getAllOptionGroups(int occasionId)
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
        ")")
        .eq(OptionGroupModel.occasionColumn, occasionId);
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

  static Future<OccasionModel?> getOccasionModelByLink(String link)
  async {
    var data = await _supabase
        .from(OccasionModel.occasionTable)
        .select()
        .eq(OccasionModel.linkColumn, link)
        .maybeSingle();
    if(data!=null)
    {
      return OccasionModel.fromJson(data);
    }
    return null;
  }

  static Future<List<OccasionModel>> getAllOccasions()
  async {
    var data = await _supabase
        .from(OccasionModel.occasionTable)
        .select();
    return List<OccasionModel>.from(
        data.map((x) => OccasionModel.fromJson(x)));
  }

  static Future<List<RoomModel>> getRooms(int occasionId)
  async {
    var data = await _supabase
        .from(RoomModel.roomTable)
        .select()
        .eq(RoomModel.occasionColumn, occasionId);

    return List<RoomModel>.from(
        data.map((x) => RoomModel.fromJson(x)));
  }

  static Future<List<BoxModel>> getAllBoxes(int occasionId)
  async {
    var data = await _supabase
        .from(BoxModel.boxTable)
        .select(
        "${BoxModel.idColumn},"
        "${BoxModel.typeColumn},"
        "${BoxModel.occasionColumn},"
        "${BoxModel.roomColumn},"
        "${BoxModel.nameColumn},"
        "${BoxModel.yColumn},"
        "${BoxModel.xColumn},"
        "${BoxGroupModel.boxGroupsTable}("
            "${BoxGroupModel.idColumn},"
            "${BoxGroupModel.nameColumn},"
            "${BoxGroupModel.roomColumn},"
            "${BoxGroupModel.occasionColumn})")
        .eq(BoxModel.occasionColumn, occasionId);

    return List<BoxModel>.from(
        data.map((x) => BoxModel.fromJson(x)));
  }

  static Future<void> updateBoxes(List<BoxModel> boxes)
  async {
    var jsonList = boxes.map((b) => b.toJson()).toList();
    await _supabase
        .from(BoxModel.boxTable)
        .upsert(jsonList);
  }

  static Future<void> loadAllBoxesAndGroups(RoomModel room)
  async {
    var data = await _supabase
        .from(RoomModel.roomTable)
        .select()
        .eq(BoxGroupModel.roomColumn, room.id!);

    var groups =  List<BoxGroupModel>.from(
        data.map((x) => BoxGroupModel.fromJson(x)));
  }
}