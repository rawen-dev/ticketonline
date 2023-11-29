import 'package:ticketonline/models/CustomerModel.dart';
import 'package:ticketonline/models/SeatModel.dart';

import 'OptionModel.dart';

class TicketModel{
  static const String ticketTable = "tickets";
  static const String ticketSeatTable = "ticket_seat";
  static const String ticketExtraTable = "ticket_option";

  static const String idColumn = "id";
  static const String createdAtColumn = "created_at";
  static const String customerColumn = "customer";
  static const String stateColumn = "state";
  static const String occasionColumn = "occasion";
  static const String priceColumn = "price";


  static const String unpaidState = "unpaid";

  int? id;
  DateTime? createdAt;
  int? occasion;
  CustomerModel? customer;
  String? state;
  SeatModel? seat;
  int? price;
  List<OptionModel>? options;

  TicketModel({
    this.id,
    this.createdAt,
    this.occasion,
    this.customer,
    this.state,
    this.price,
    this.options
  });

  static TicketModel fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      createdAt: DateTime.parse(json[createdAtColumn]),
      customer: json[customerColumn] != null ? CustomerModel(id: json[customerColumn]):null,
      state: json[stateColumn],
      price: json[priceColumn],
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      customerColumn: customer?.id,
      stateColumn: state??unpaidState,
      occasionColumn: occasion,
      priceColumn: price
    };
    if(id != null)
    {
      map[idColumn] = id;
    }
    return map;
  }
}
