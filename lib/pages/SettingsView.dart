import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool isNotificationEnabled = true;
  String selectedTheme = 'Light';

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    // Placeholder method for loading settings (you can implement actual logic later)
    // For now, it simulates loading settings with some default values.
    setState(() {
      isNotificationEnabled = true; // Example: Notification setting loaded as enabled
      selectedTheme = 'Light';      // Example: Default theme is Light
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800), // Limit width to 800px
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nastavení aplikace',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Notification toggle
              SwitchListTile(
                title: const Text('Povolit oznámení'),
                value: isNotificationEnabled,
                onChanged: (bool value) {
                  setState(() {
                    isNotificationEnabled = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              // Theme selection dropdown
              const Text(
                'Výběr motivu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: selectedTheme,
                items: const [
                  DropdownMenuItem(
                    value: 'Light',
                    child: Text('Světlý motiv'),
                  ),
                  DropdownMenuItem(
                    value: 'Dark',
                    child: Text('Tmavý motiv'),
                  ),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTheme = newValue!;
                  });
                },
              ),

              const SizedBox(height: 40),

              // Save button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Placeholder action for saving settings
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nastavení uloženo')),
                    );
                  },
                  child: const Text('Uložit nastavení'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
