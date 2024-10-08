import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ticketonline/pages/CheckPage.dart';
import 'package:ticketonline/pages/LoginPage.dart';
import 'package:ticketonline/pages/SettingsView.dart';
import 'package:ticketonline/pages/TicketTableView.dart';
import 'package:ticketonline/services/DataService.dart';

class DashboardPage extends StatefulWidget {
  static const ROUTE = "/dashboard";
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // Load data if needed here
    if (DataService.currentUserId() == null) {
      context.go(LoginPage.ROUTE);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Dashboard"),
          actions: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: ElevatedButton.icon(
                onPressed: () async {
                  context.go(CheckPage.ROUTE);
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text("Skenovat"),
              ),
            ),
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
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("Vstupenky"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.settings),
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Text("Nastavení"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            TicketTableView(),
            SettingsView(),
          ],
        ),
      ),
    );
  }
}
