import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:route_log/bustimes/models/operator.dart';
import 'package:route_log/bustimes/models/vehicle_type.dart';
import 'package:route_log/models/favourite_list.dart';
import 'package:route_log/models/favourite_operator.dart';
import 'package:route_log/models/favourite_service.dart';
import 'package:route_log/models/favourite_vehicles.dart';
import 'package:route_log/models/route_checklist.dart';
import 'package:route_log/models/route_checklist_item.dart';
import 'package:route_log/widgets/pages/favourites_page.dart';
import 'package:route_log/widgets/pages/home_page.dart';
import 'package:route_log/widgets/pages/lists/lists.dart';
import 'package:route_log/widgets/pages/map_page.dart';
import 'package:route_log/widgets/pages/search_page.dart';
import 'package:route_log/widgets/prompts/input_prompt.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Route Logger',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
      ),

      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      themeMode: ThemeMode.system,

      home: MainApp(),
    );
  }
}

enum PageType { home, list, favourites, search, settings, map }

final List<PageType> order = [
  PageType.home,
  PageType.list,
  PageType.favourites,
  PageType.search,
  PageType.map,
  // PageType.settings,
];

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  PageType currentPage = PageType.home;
  late final Future<void> _loadFuture;
  final ValueNotifier<String> loadingText = ValueNotifier("Starting up…");
  final GlobalKey<ListsPageState> listsPageKey = GlobalKey<ListsPageState>();

  @override
  void initState() {
    super.initState();
    _loadFuture = loadAll();
  }

  Widget _buildPage() {
    return switch (currentPage) {
      PageType.home => HomePage(),
      PageType.list => ListsPage(key: listsPageKey),
      PageType.favourites => FavouritesPage(),
      PageType.search => SearchPage(),
      PageType.settings => const Text("Im autistic"),
      PageType.map => BustimesMapPage(),
    };
  }

  Future<void> loadAll() async {
    Map<String, Future<void> Function()> futures = {
      "liveries": () => Livery.getAllApi(),
      "vehicle types": () => VehicleType.getAllApi(),
      "operators": () => Operator.getAllApi(),
      "favourite operators": () => FavouriteOperator.updateCache(),
      "favourite service": () => FavouriteService.updateCache(),
      "favourite vehicles": () => FavouriteVehicles.updateCache(),
      "favourite lists": () => FavouriteList.updateCache(),
      "route checklists": () => RouteChecklist.updateCache(),
      "route checklist items": () => RouteChecklistItem.updateCache(),
    };

    for (final pair in futures.entries) {
      loadingText.value = "Loading ${pair.key}...";
      await pair.value();
    }

    loadingText.value = "Done";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: FutureBuilder(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: loadingText,
                    builder: (context, text, _) {
                      return Text(text);
                    },
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return _buildPage();
        },
      ),

      floatingActionButton:
          currentPage == PageType.list
              ? FloatingActionButton(
                onPressed: () async {
                  String? name = await showInputPrompt(
                    context,
                    const Text("Name of list"),
                    const Text("You will be able to add routes later."),
                  );

                  if (name == null || name.isEmpty) return;

                  await RouteChecklist.makeNew(name);
                  listsPageKey.currentState?.refresh();
                },
                child: const Icon(Icons.add),
              )
              : null,

      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPage = order[index];
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: order.indexOf(currentPage),
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.list), label: "Lists"),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          // NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
