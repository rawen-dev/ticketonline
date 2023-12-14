import 'package:ticketonline/dataGrids/SingleTableDataGrid.dart';

class DataGridAction{
  String name;
  void Function(SingleTableDataGrid) action;

  DataGridAction(this.name, this.action);
}