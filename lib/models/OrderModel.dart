import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/TicketModel.dart';

class OrderModel {
  static const String orderModelTable = "orders";
  static const String customerPart = "customer";
  static const String occasionPart = "occasion";
  static const String optionsPart = "options";
  
 String? name;
 String? surname;
 String? email;
 Map<String, String>? options;
 String? note;
 Map<String, String>? box;

  int? occasion;

  Map<String, dynamic> toJson() {
    var map = {
      occasionPart: occasion,
      customerPart: {
        CustomerModel.nameColumn: name,
        CustomerModel.surnameColumn: surname,
        CustomerModel.emailColumn: email
      },
      optionsPart: {
        TicketModel.optionsColumn: options,
        TicketModel.boxColumn: box,
        TicketModel.noteColumn: note
      }
    };
    return map;
  }
}