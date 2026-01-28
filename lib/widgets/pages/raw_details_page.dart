import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:route_log/widgets/util/page.dart';

class RawDetailsPage extends StatelessWidget {
  final Map<String, dynamic> map;
  const RawDetailsPage({super.key, required this.map});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Raw Details")),
      body: BasePage(
        widget: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(64),
                      1: FixedColumnWidth(160),
                      2: FlexColumnWidth(),
                    },
                    border: TableBorder.all(color: Colors.grey),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: const Text("Copy"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: const Text("Key"),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: const Text("Value"),
                          ),
                        ],
                      ),
                      ...map.entries.map((entry) {
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: IconButton(
                                tooltip: "Copy value",
                                iconSize: 18,
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(text: entry.value.toString()),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Copied to clipboard"),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(entry.value.toString()),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
