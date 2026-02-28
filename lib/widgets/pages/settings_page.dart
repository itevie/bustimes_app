import 'package:dawn_ui_flutter/dawn_ui.dart';
import 'package:flutter/material.dart';
import 'package:route_log/widgets/util/page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      name: const Text("Settings"),
      body: BasePage(
        widget: Column(
          children: [
            PageChangeCard(
              icon: Icons.description,
              child: const Text("Page Settings"),
              onTap: () {},
            ),
            PageChangeCard(
              icon: Icons.map,
              child: const Text("Map Settings"),
              onTap: () {},
            ),
            PageChangeCard(
              icon: Icons.dns,
              child: const Text("Manage Data"),
              onTap: () {
                // navigate(context, ManageDataSettingsPage());
              },
            ),
            PageChangeCard(
              icon: Icons.list,
              child: const Text("Logs"),
              onTap: () {},
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => openUrl("https://bustimes.org"),
                      child: const Text(
                        "Bustimes",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  dot(),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap:
                          () =>
                              openUrl("https://github.com/itevie/bustimes_app"),
                      child: const Text(
                        "GitHub",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
