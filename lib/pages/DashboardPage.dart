
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:ticketonline/dataGrids/DataGridAction.dart';
import 'package:ticketonline/dataGrids/DataGridHelper.dart';
import 'package:ticketonline/dataGrids/SingleTableDataGrid.dart';
import 'package:ticketonline/models/OptionGroupModel.dart';
import 'package:ticketonline/models/OptionModel.dart';
import 'package:ticketonline/models/TicketModel.dart';
import 'package:ticketonline/pages/CheckPage.dart';
import 'package:ticketonline/pages/LoginPage.dart';
import 'package:ticketonline/services/DataService.dart';
import 'package:ticketonline/services/DialogHelper.dart';
import 'package:ticketonline/services/MailerSendHelper.dart';
import 'package:ticketonline/services/ToastHelper.dart';


class DashboardPage extends StatefulWidget {
  static const ROUTE = "/dashboard";
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<OptionModel> taxiOptions = [];
  List<OptionModel> foodOptions = [];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    if(DataService.currentUserId()==null)
    {
      context.go(LoginPage.ROUTE);
      return;
    }
    taxiOptions.clear();
    foodOptions.clear();
    var currentOccasion = await DataService.getCurrentUserOccasion();
    var optionGroups  = await DataService.getAllOptionGroups(currentOccasion);
    var fOptions = optionGroups.firstWhereOrNull((element) => element.code == OptionGroupModel.foodOption);
    if(fOptions!=null)
    {
      foodOptions.addAll(fOptions.options!);
    }

    var tOptions = optionGroups.firstWhereOrNull((element) => element.code == OptionGroupModel.taxiOption);
    if(tOptions!=null)
    {
      taxiOptions.addAll(tOptions.options!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
          appBar: AppBar(
          title: const Text("Dashboard"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: ElevatedButton.icon(
                  onPressed: () async {
                context.go(CheckPage.ROUTE);},
                icon: const Icon(Icons.qr_code_scanner), label: const Text("Skenovat"),
              ),
            )
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(40),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                  isScrollable: true,
                tabs: [
                  Row(
                  children: [
                    Icon(Icons.local_activity),
                    Padding(padding: EdgeInsets.all(12), child: Text("Vstupenky"))
                  ]
                ),
                ]
              ),
            ),
          )),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SingleTableDataGrid<TicketModel>(
                DataService.getAllTickets,
                TicketModel.fromPlutoJson,
                DataGridFirstColumn.deleteAndCheck,
                TicketModel.idColumn,
                headerChildren: [
                  DataGridAction("Změnit na zaplaceno", (d) {
                    _changeToPaid(d);
                  }),
                  DataGridAction("Změnit na storno", (d) {
                    _changeToStorno(d);
                  })
                ],
                columns: [
                  PlutoColumn(
                      title: "Id",
                      field: TicketModel.idColumn,
                      type: PlutoColumnType.text(),
                      enableEditingMode: false,
                      width: 50),
                  PlutoColumn(
                      width: 150,
                      title: "Vstupenka",
                      enableFilterMenuItem: false,
                      enableContextMenu: false,
                      enableSorting: false,
                      field: TicketModel.ticketImageColumn,
                      type: PlutoColumnType.text(defaultValue: null),
                      renderer: (rendererContext) {
                        return ElevatedButton(
                            onPressed: (){
                              var ticket = rendererContext.row.cells[TicketModel.ticketImageColumn]?.value as TicketModel;
                              DialogHelper.showTicketDialog(context, ticket.toBasicString(), ticket);
                            },
                            child: Row(children: [const Icon(Icons.local_activity), Padding(padding: const EdgeInsets.all(6), child: const Text("Vstupenka")) ])
                        );
                      }),
                  PlutoColumn(
                    title: "Datum",
                    enableEditingMode: false,
                    field: TicketModel.createdAtColumn,
                    type: PlutoColumnType.date(defaultValue: DateTime.now()),
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "Objednal",
                    enableEditingMode: false,
                    field: TicketModel.customerColumn,
                    type: PlutoColumnType.text(),
                    width: 350,
                  ),
                  PlutoColumn(
                    title: "Cena",
                    field: TicketModel.priceColumn,
                    type: PlutoColumnType.number(negative: false, defaultValue: null),
                    width: 70,
                  ),
                  PlutoColumn(
                    title: "Stav",
                    readOnly: true,
                    enableEditingMode: false,
                    field: TicketModel.stateColumn,
                    type: PlutoColumnType.select(TicketModel.states),
                    formatter: (value) => DataGridHelper.returnQuestionMarkOnInvalid(value, TicketModel.states),
                    applyFormatterInEditing: true,
                    width: 100,
                  ),
                  PlutoColumn(
                    title: "Sedadlo",
                    enableEditingMode: false,
                    field: TicketModel.boxColumn,
                    type: PlutoColumnType.text(),
                    width: 150,
                  ),
                  PlutoColumn(
                    title: "Jídlo",
                    enableEditingMode: false,
                    field: TicketModel.foodOptionsColumn,
                    type: PlutoColumnType.select(foodOptions),
                    renderer: (rendererContext) => DataGridHelper.ticketOptionRenderer(rendererContext),
                    width: 250,
                  ),
                  PlutoColumn(
                    title: "Odvoz",
                    enableEditingMode: false,
                    field: TicketModel.taxiOptionsColumn,
                    type: PlutoColumnType.select(taxiOptions),
                    renderer: (rendererContext) => DataGridHelper.ticketOptionRenderer(rendererContext),
                  ),
                  PlutoColumn(
                    title: "Poznámka",
                    enableEditingMode: false,
                    field: TicketModel.noteColumn,
                    type: PlutoColumnType.text(),
                    width: 300,
                  ),
                  PlutoColumn(
                    title: "Skrytá poznámka",
                    field: TicketModel.hiddenNoteColumn,
                    type: PlutoColumnType.text(),
                    width: 300,
                  ),
                ])
                .DataGrid(),
          ]
        ),
      ),
    );
  }

  Future<void> _changeToStorno(SingleTableDataGrid dataGrid) async {
    var tickets = List<TicketModel>.from(dataGrid.stateManager.refRows.originalList.where((element) => element.checked == true).map((x) => x.cells[TicketModel.ticketImageColumn]?.value as TicketModel));

    var paid = tickets.where((element) => element.state == TicketModel.reservedState || element.state == TicketModel.paidState);

    if(paid.isEmpty)
    {
      ToastHelper.Show("Nejsou označeny žádné vstupenky k změně na storno.");
      return;
    }

    var really = await DialogHelper.showConfirmationDialogAsync(context,
        "Odeslat storno e-mail a změnit stav na storno",
        "Místo rezervované vstupenkou bude uvolněno, vstupenka bude označena jako storno a odešle se e-mail na toho, kdo si je objednal." +
            "\n" +
            "Vstupenky (${paid.length}):\n${paid.map((value) => value.toBasicString()).toList().join(",\n")}",
        confirmButtonMessage: "Potvrdit");

    if(!really)
    {
      return;
    }

    var allTickets = await DataService.getAllTickets();

    for(var ticket in paid)
    {
      var ticketMatch = allTickets.firstWhere((t)=>t.id==ticket.id);
      await MailerSendHelper.waitForApiLimit();
      await MailerSendHelper.sendTicketStorno(ticketMatch);
      await DataService.updateTicketState(ticketMatch, TicketModel.stornoState);
    }
    dataGrid.reloadData();
  }

  Future<void> _changeToPaid(SingleTableDataGrid dataGrid) async {
    var tickets = List<TicketModel>.from(dataGrid.stateManager.refRows.originalList.where((element) => element.checked == true).map((x) => x.cells[TicketModel.ticketImageColumn]?.value as TicketModel));

    var nonPaid = tickets.where((element) => element.state == TicketModel.reservedState);

    if(nonPaid.isEmpty)
    {
      ToastHelper.Show("Nejsou označeny žádné vstupenky k změně na zaplaceno.");
      return;
    }

    var really = await DialogHelper.showConfirmationDialogAsync(context,
        "Odeslat vstupenky a změnit stav na zaplaceno",
        "Tyto vstupenky budou označeny jako zaplacené a odeslané na e-mail toho, kdo si je objednal." +
            "\n" +
            "Vstupenky (${nonPaid.length}):\n${nonPaid.map((value) => value.toBasicString()).toList().join(",\n")}",
        confirmButtonMessage: "Potvrdit");

    if(!really)
    {
      return;
    }
    var allTickets = await DataService.getAllTickets();

    for(var ticket in nonPaid)
    {
      var ticketMatch = allTickets.firstWhere((t)=>t.id==ticket.id);
      await MailerSendHelper.waitForApiLimit();
      await MailerSendHelper.sendTicketPaid(ticketMatch);
      await DataService.updateTicketState(ticketMatch, TicketModel.paidState);
    }
    dataGrid.reloadData();
  }
}