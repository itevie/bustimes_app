import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/util/query.dart';
import "package:dawn_ui_flutter/prompts/prompts.dart";

typedef ItemBuilderDetails = ({bool isGrid});

typedef ViewWiedgetQuery =
    ({bool refresh, Map<String, dynamic> query, int offset});

class ViewList<T extends BaseModel> extends StatefulWidget {
  final Future<List<T>> Function(ViewWiedgetQuery options) loadData;
  final Widget Function(T item, ItemBuilderDetails options) itemBuilder;
  final String? queryGroup;
  final Widget? note;
  final String? preSearch;
  final Map<String, dynamic>? fullSearch;
  final String name;
  final bool allowGrid;
  final bool noConfirmReload;

  const ViewList({
    super.key,
    required this.name,
    required this.loadData,
    required this.itemBuilder,
    this.queryGroup,
    this.note,
    this.fullSearch,
    this.preSearch,
    this.allowGrid = false,
    this.noConfirmReload = false,
  });

  @override
  State<ViewList<T>> createState() => _ViewListState<T>();
}

class _ViewListState<T extends BaseModel> extends State<ViewList<T>> {
  late Future<List<T>> _future;
  late TextEditingController _controller;

  Map<String, dynamic> query = {};
  bool isGrid = false;

  List<String>? itemKeys = [];

  int page = 0;
  static const int pageSize = 50;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.preSearch ?? '');
    query["search"] = widget.preSearch;

    if (widget.fullSearch != null) {
      query = {...query, ...widget.fullSearch!};
    }

    _future = widget.loadData((
      refresh: false,
      query: query,
      offset: page * 100,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refresh({bool fullRefresh = true, bool noPageChange = false}) {
    setState(() {
      if (!noPageChange) page = 0;
      _future = widget.loadData((
        refresh: fullRefresh,
        query: query,
        offset: page * 100,
      ));
    });
  }

  void reloadData() async {
    final result =
        widget.noConfirmReload
            ? true
            : await showConfirmPrompt(
              context,
              const Text("Reload All Data?"),
              const Text(
                "Are you sure you want to fetch all data from the bustimes website?",
              ),
            );

    if (result) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search ${widget.name}',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    query["search"] = value;
                    page = 0;
                    _refresh(fullRefresh: false);
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (widget.queryGroup != null) ...[
                    OutlinedButton(
                      onPressed: () async {
                        final result = await showObjectQueryPrompt(
                          context,
                          objectQuries[widget.queryGroup]!,
                          prefill: query,
                        );

                        if (result == null) return;

                        setState(() {
                          query = {'search': query["search"], ...result};
                          page = 0;
                          _refresh(fullRefresh: false);
                        });
                      },
                      child: const Icon(Icons.filter_list),
                      // label: const Text('Filter'),
                    ),
                    OutlinedButton(
                      onPressed:
                          itemKeys == null
                              ? null
                              : () async {
                                final result = await showSelectPrompt(
                                  context,
                                  const Text("Choose Order"),
                                  {
                                    ...itemKeys!.asMap().map(
                                      (x, v) => MapEntry(x, "$v (Ascending)"),
                                    ),
                                    ...itemKeys!.asMap().map(
                                      (x, v) => MapEntry(
                                        itemKeys!.length + x,
                                        "$v (Descending)",
                                      ),
                                    ),
                                  },
                                );

                                if (result == null) return;

                                final descending = result >= itemKeys!.length;
                                final t =
                                    itemKeys![descending
                                        ? result - itemKeys!.length
                                        : result];
                                showMessagePrompt(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  Text("$descending"),
                                  Text(t),
                                );
                              },
                      child: const Icon(Icons.swap_vert),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton(
                    onPressed: reloadData,
                    child: const Icon(Icons.refresh),
                  ),

                  const SizedBox(width: 8),
                  FutureBuilder<List<T>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("0 results");
                      final count = queryViaObjectQuery(snapshot.data!, query);
                      return Text("${count.length} results");
                    },
                  ),
                  if (widget.allowGrid) ...[
                    const Expanded(child: SizedBox()),
                    Switch(
                      value: isGrid,
                      onChanged: (v) => setState(() => isGrid = v),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (widget.note != null) ...[widget.note!, const SizedBox(height: 8)],
        const Divider(height: 1),
        Expanded(
          child: FutureBuilder<List<T>>(
            future: _future.then(
              (values) => queryViaObjectQuery(values, query),
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No items found.'),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: reloadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Load Data'),
                      ),
                    ],
                  ),
                );
              }

              final allItems = snapshot.data!;

              if (allItems.isNotEmpty) {
                itemKeys =
                    allItems[0].toMap().entries.map((x) => x.key).toList();
              }

              final totalPages = (allItems.length / pageSize).ceil().clamp(
                1,
                9999,
              );

              final start = page * pageSize;
              final end = (start + pageSize).clamp(0, allItems.length);
              final items = allItems.sublist(start, end);

              return Column(
                children: [
                  Expanded(
                    child:
                        isGrid
                            ? GridView.builder(
                              padding: const EdgeInsets.all(8),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 4,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return widget.itemBuilder(items[index], (
                                  isGrid: true,
                                ));
                              },
                            )
                            : ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                return widget.itemBuilder(items[index], (
                                  isGrid: false,
                                ));
                              },
                            ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.first_page),
                          onPressed:
                              page != 0 ? () => setState(() => page = 0) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed:
                              page > 0 ? () => setState(() => page--) : null,
                        ),
                        Text("Page ${page + 1} / $totalPages"),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed:
                              page < totalPages - 1
                                  ? () => setState(() {
                                    page++;
                                    _refresh(
                                      noPageChange: true,
                                      fullRefresh: false,
                                    );
                                  })
                                  : null,
                        ),

                        IconButton(
                          icon: const Icon(Icons.last_page),
                          onPressed:
                              page == totalPages - 1
                                  ? null
                                  : () => setState(() => page = totalPages - 1),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
