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
  static const String hiddenNoteColumn = "hidden_note";

  static const String boxColumn = "box";
  static const String optionsColumn = "options";
  static const String foodOptionsColumn = "foodOptions";
  static const String taxiOptionsColumn = "taxiOptions";

  static const String ticketImageColumn = "ticketImage";

  static const String reservedState = "reserved";
  static const String paidState = "paid";
  static const String usedState = "used";
  static const String stornoState = "storno";


  static const states = [reservedState, paidState, stornoState, usedState];

  int? id;
  DateTime? createdAt;
  int? occasion;
  CustomerModel? customer;
  String? note;
  String? hiddenNote;
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
    this.hiddenNote,
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
      hiddenNote: json[hiddenNoteColumn]??"",
      boxId: json[boxColumn],
      price: json[priceColumn],
      box: json[BoxModel.boxTable] != null ? BoxModel.fromJson(json[BoxModel.boxTable]) : null,
      options: json[TicketModel.ticketOptionsTable] != null ? List<OptionModel>.from(json[TicketModel.ticketOptionsTable].map((x)=>OptionModel(id: x[ticketOptionsTableOption]))) : null
    );
  }

  Map<String, dynamic> toJson() {

    Map<String, dynamic> map = {};
    if(price!=null)
    {
      map[priceColumn] = price;
    }

    if(state!=null)
    {
      map[stateColumn] = state;
    }

    var boxIdValue = boxId??box?.id;
    if(boxIdValue != null)
    {
      map[boxColumn] = boxIdValue;
    }
    if(occasion != null)
    {
      map[occasionColumn] = occasion;
    }
    if(hiddenNote != null)
    {
      map[hiddenNoteColumn] = hiddenNote;
    }
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
      hiddenNote: json[hiddenNoteColumn],
      price: json[priceColumn],
    );
  }

  OptionModel? foodOption() => options?.firstWhereOrNull((o)=>o.optionGroup!.code == OptionGroupModel.foodOption);
  OptionModel? taxiOption() => options?.firstWhereOrNull((o)=>o.optionGroup!.code == OptionGroupModel.taxiOption);

  @override
  PlutoRow toPlutoRow() {

    return PlutoRow(cells: {
      idColumn: PlutoCell(value: id),
      ticketImageColumn: PlutoCell(value: this),
      createdAtColumn: PlutoCell(value: DateFormat('yyyy-MM-dd').format(createdAt??DateTime.fromMicrosecondsSinceEpoch(0))),
      customerColumn: PlutoCell(value: customer.toString()),
      stateColumn: PlutoCell(value: state),
      noteColumn: PlutoCell(value: note),
      hiddenNoteColumn: PlutoCell(value: hiddenNote),
      boxColumn: PlutoCell(value: box??""),
      priceColumn: PlutoCell(value: price),
      foodOptionsColumn: PlutoCell(value: foodOption()),
      taxiOptionsColumn: PlutoCell(value: taxiOption()),
    });
  }

  @override
  Future<void> deleteMethod() async {
    await DataService.deleteTicket(this);
  }

  @override
  Future<void> updateMethod() async {
    await DataService.updateTicket(this);
  }

  @override
  String toBasicString() => "Vstupenka ${id}";
}
