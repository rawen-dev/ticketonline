import 'package:collection/collection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ticketonline/models/BoxGroupModel.dart';
import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/EmailMetadataModel.dart';
import 'package:ticketonline/models/OccasionModel.dart';
import 'package:ticketonline/models/OptionGroupModel.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/RoomModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/models/UserInfoModel.dart';

class DataService{
  static bool isEditor = false;
  static final _supabase = Supabase.instance.client;
  static const _secureStorage =  FlutterSecureStorage();
  static const REFRESH_TOKEN_KEY = 'refresh';

  static Future<bool> tryAuthUser() async {
    if (!await _secureStorage.containsKey(key: REFRESH_TOKEN_KEY)) {
      return false;
    }
    var refresh = await _secureStorage.read(key: REFRESH_TOKEN_KEY);
    try{
      var result = await _supabase.auth.setSession(refresh.toString());
      if (result.user != null) {
        await _secureStorage.write(
            key: REFRESH_TOKEN_KEY,
            value: _supabase.auth.currentSession!.refreshToken.toString());
        return true;
      }
    }
    catch(e)
    {
      //invalid refresh token
    }
    return false;
  }

  static Future<void> login(String email, String password) async {
    var data = await _supabase.auth
        .signInWithPassword(email: email, password: password);
    await _secureStorage.write(
        key: REFRESH_TOKEN_KEY, value: data.session!.refreshToken.toString());
  }

  static isLoggedIn() {
    return _supabase.auth.currentSession != null;
  }

  static Future<void> logout() async {
    _secureStorage.delete(key: REFRESH_TOKEN_KEY);
    _currentUser = null;
    await _supabase.auth.signOut();
  }

  static ensureUserIsLoggedIn(){
    if(!DataService.isLoggedIn())
    {
      throw Exception("User must be logged in.");
    }
  }

  static UserInfoModel? _currentUser;
  static Future<UserInfoModel> loadCurrentUserData() async {
    ensureUserIsLoggedIn();
    var jsonUser = await _supabase
        .from(UserInfoModel.userInfoTable)
        .select()
        .eq(UserInfoModel.idColumn, _supabase.auth.currentUser!.id)
        .single();
    _currentUser = UserInfoModel.fromJson(jsonUser);
    return _currentUser!;
  }

  static Future<String> getEmailTemplate(String emailType, int occasion)
  async {
    var data = await _supabase.from("email_type").select().match({"type": emailType, "occasion": occasion}).limit(1).single();
    return data["template"];
  }

  static Future<void> emailWithAttachmentMailerSend(EmailMetadataModel metadata, List<Map<String, String>> variables, Map<String, String>? attachment)
  async {
    var data = {
      "to":[
        {
          "email":metadata.recipient
        }
      ],
      "template_id":metadata.template,
      "reply_to": [
        {
          "email": metadata.recipient,
          "name": "vstupenka.online"
        }
      ],
      "variables": [
        {
          "email": metadata.recipient,
          "substitutions": variables
        }
      ],
      "attachments": [
        attachment
      ]
    };
    var response = await _supabase.rpc(
        "send_email_via_mailersend",
        params: {
          "data": data,
          "metadata": {
            "template": metadata.template,
            "subject": metadata.subject,
            "recipient": metadata.recipient,
            "occasion": metadata.occasion
          }
        });

    if(response!=202)
    {
      throw Exception("Sending e-mail has failed.");
    }
  }

  static Future<CustomerModel> updateCustomer(CustomerModel customer)
  async {
    var userData = await _supabase.from(CustomerModel.customerTable).upsert(customer.toJson()).select().single();
    return CustomerModel.fromJson(userData);
  }

  static String? currentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  static Future<List<TicketModel>> getAllTickets()
  async {
    var occasionId = await getCurrentUserOccasion();

    var data = await _supabase
        .from(TicketModel.ticketTable)
        .select(
        "${TicketModel.idColumn},"
            "${TicketModel.priceColumn},"
            "${TicketModel.createdAtColumn},"
            "${TicketModel.stateColumn},"
            "${TicketModel.noteColumn},"
            "${TicketModel.hiddenNoteColumn},"
            "${BoxModel.boxTable}"
              "("
                "${BoxModel.idColumn},"
                "${BoxModel.nameColumn},"
                "${BoxGroupModel.boxGroupsTable}"
                  "("
                    "${BoxGroupModel.idColumn},"
                    "${BoxGroupModel.nameColumn}"
                  ")"
              "),"
            "${CustomerModel.customerTable}"
              "("
                "${CustomerModel.idColumn},"
                "${CustomerModel.nameColumn},"
                "${CustomerModel.surnameColumn},"
                "${CustomerModel.emailColumn}"
              "),"
            "${TicketModel.ticketOptionsTable}"
              "("
                "${TicketModel.ticketOptionsTableOption}"
              ")"
        )
        .eq(TicketModel.occasionColumn, occasionId);
    var tickets = List<TicketModel>.from(
        data.map((x) => TicketModel.fromJson(x)));
    var optionGroups = await getAllOptionGroups(occasionId);
    var options = optionGroups.expand((element) => element.options!);
    //add full option
    for(var t in tickets)
    {
      t.occasion = occasionId;
      List<OptionModel> fullOptions = [];
      for(var o in t.options!)
      {
        var fullOption = options.firstWhereOrNull((element) => element.id == o.id);
        if(fullOption!=null){
          fullOptions.add(fullOption);
        }
      }
      t.options!.clear();
      t.options!.addAll(fullOptions);
    }
    tickets.sort((a,b) => a.createdAt!.compareTo(b.createdAt!));
    return tickets;
  }

  static Future<int> getCurrentUserOccasion() async {
    var occasion = await _supabase
        .from(UserInfoModel.userOccasionTable)
        .select()
        .eq(UserInfoModel.userOccasionUserColumn, currentUserId())
        .limit(1);
    var occasionId = occasion[0][UserInfoModel.userOccasionOccasionColumn];
    return occasionId;
  }
  
  static Future<void> deleteTicket(TicketModel ticket)
  async {
    await _supabase.from(BoxModel.boxTable).update({BoxModel.stateColumn:BoxModel.availableType}).eq(BoxModel.idColumn, ticket.box!.id!);
    await _supabase.from(TicketModel.ticketOptionsTable).delete().eq(TicketModel.ticketOptionsTableTicket, ticket.id);
    await _supabase.from(TicketModel.ticketTable).delete().eq(TicketModel.idColumn, ticket.id);
  }

  static Future<void> updateTicketState(TicketModel ticket, String state)
  async {
    if(state==TicketModel.stornoState)
    {
      await _supabase.from(TicketModel.ticketOptionsTable).delete().eq(TicketModel.ticketOptionsTableTicket, ticket.id);
      await _supabase.from(BoxModel.boxTable).update({BoxModel.stateColumn: BoxModel.availableType}).eq(BoxModel.idColumn, ticket.box!.id!);
    }
    await _supabase.from(TicketModel.ticketTable).update(
    {
      TicketModel.boxColumn: null,
      TicketModel.stateColumn: state
    })
    .eq(TicketModel.idColumn, ticket.id);
  }

  static Future<TicketModel> updateTicket(TicketModel ticket)
  async {
    dynamic data;
    if(ticket.id!=null)
    {
      data = await _supabase.from(TicketModel.ticketTable).update(ticket.toJson()).eq(TicketModel.idColumn, ticket.id).select().single();
    }
    else
    {
      data = await _supabase.from(TicketModel.ticketTable).upsert(ticket.toJson()).select().single();
    }
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
        await _supabase.from(TicketModel.ticketOptionsTable).upsert({"ticket":ticket.id, "option":e.id});
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
        "${BoxModel.stateColumn},"
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

  static Future<BoxGroupModel> updateBoxGroup(BoxGroupModel boxGroupModel)
  async {
    var json = boxGroupModel.toJson();
    var updated = await _supabase
        .from(BoxGroupModel.boxGroupsTable)
        .upsert(json)
        .select()
        .single();
    return BoxGroupModel.fromJson(updated);
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