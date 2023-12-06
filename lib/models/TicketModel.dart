import 'package:pluto_grid/pluto_grid.dart';
import 'package:ticketonline/dataGrids/PlutoAbstract.dart';
import 'package:ticketonline/models/BoxModel.dart';
import 'package:ticketonline/models/CustomerModel.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:ticketonline/models/OptionGroupModel.dart';
import 'package:ticketonline/services/DataService.dart';

import 'OptionModel.dart';

class TicketModel extends IPlutoRowModel {
  static const String ticketTable = "tickets";
  static const String ticketOptionsTable = "ticket_option";
  static const String ticketOptionsTableOption = "option";
  static const String ticketOptionsTableTicket = "ticket";

  static const String idColumn = "id";
  static const String createdAtColumn = "created_at";
  static const String customerColumn = "customer";
  static const String stateColumn = "state";
  static const String occasionColumn = "occasion";
  static const String priceColumn = "price";
  static const String noteColumn = "note";
  static const String boxColumn = "box";
  static const String optionsColumn = "options";
  static const String foodOptionsColumn = "foodOptions";
  static const String taxiOptionsColumn = "taxiOptions";

  static const String unpaidState = "unpaid";
  static const String paidState = "paid";

  static const states = [unpaidState, paidState];

  int? id;
  DateTime? createdAt;
  int? occasion;
  CustomerModel? customer;
  String? note;
  String? state;
  BoxModel? box;
  int? price;
  int? boxId;
  List<OptionModel>? options;

  TicketModel({
    this.id,
    this.createdAt,
    this.occasion,
    this.customer,
    this.state,
    this.note,
    this.box,
    this.price,
    this.boxId,
    this.options
  });

  static TicketModel fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json[idColumn],
      occasion: json[occasionColumn],
      createdAt: DateTime.parse(json[createdAtColumn]),
      customer: json[CustomerModel.customerTable] != null ? CustomerModel.fromJson(json[CustomerModel.customerTable]):null,
      state: json[stateColumn],
      note: json[noteColumn]??"",
      boxId: json[boxColumn],
      price: json[priceColumn],
      box: json[BoxModel.boxTable] != null ? BoxModel.fromJson(json[BoxModel.boxTable]) : null,
      options: json[TicketModel.ticketOptionsTable] != null ? List<OptionModel>.from(json[TicketModel.ticketOptionsTable].map((x)=>OptionModel(id: x[ticketOptionsTableOption]))) : null
    );
  }

  Map<String, dynamic> toJson() {
    var map = {
      stateColumn: state??unpaidState,
      occasionColumn: occasion,
      priceColumn: price,
      boxColumn: boxId??box?.id
    };
    if(note != null)
    {
      map[noteColumn] = note;
    }
    if(customer != null)
    {
      map[customerColumn] = customer?.id;
    }
    if(id != null)
    {
      map[idColumn] = id;
    }
    return map;
  }

  static TicketModel fromPlutoJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json[idColumn] == -1 ? null : json[idColumn],
      box: json[boxColumn],
      state: json[stateColumn],
      price: json[priceColumn],
    );
  }

  @override
  PlutoRow toPlutoRow() {
    var foodOption = options?.firstWhereOrNull((o)=>o.optionGroup!.code == OptionGroupModel.foodOption);
    var taxiOption = options?.firstWhereOrNull((o)=>o.optionGroup!.code == OptionGroupModel.taxiOption);

    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      createdAtColumn: PlutoCell(value: DateFormat('yyyy-MM-dd').format(createdAt??DateTime.fromMicrosecondsSinceEpoch(0))),
      customerColumn: PlutoCell(value: customer.toString()),
      stateColumn: PlutoCell(value: state),
      noteColumn: PlutoCell(value: note),
      boxColumn: PlutoCell(value: box),
      priceColumn: PlutoCell(value: price),
      foodOptionsColumn: PlutoCell(value: foodOption),
      taxiOptionsColumn: PlutoCell(value: taxiOption),
    });
  }

  @override
  Future<void> deleteMethod() async {
    await DataService.deleteTicket(this);
  }

  @override
  Future<void> updateMethod() async {
  }

  @override
  String toBasicString() => "Ticket ${id}";
}
