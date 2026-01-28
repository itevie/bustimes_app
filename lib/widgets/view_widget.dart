import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/_base_model.dart';
import 'package:route_log/util/other.dart';
import 'package:route_log/widgets/pages/raw_details_page.dart';
import 'package:route_log/widgets/util/my_card.dart';
import 'package:route_log/widgets/util/popup_menu.dart';

typedef ViewWidgetAction =
    ({IconData icon, String name, VoidCallback callback});
typedef ViewWidgetGridOptions = ({Widget widget, VoidCallback? onTap});
typedef ViewWidgetFavouriteOptions =
    ({bool Function() fetch, Future<void> Function() update});
typedef ViewWidgetSideButton =
    ({
      IconData icon,
      VoidCallback? onTap,
      List<ViewWidgetAction>? popupActions,
    });

class ViewWidget extends StatefulWidget {
  final List<Widget> children;
  final Widget? leftChild;
  final BaseModel model;
  final ViewWidgetGridOptions? gridChild;
  final List<ViewWidgetAction> actions;
  final List<ViewWidgetAction> popupActions;
  final ViewWidgetFavouriteOptions? favourite;
  final bool noRawIdButton;

  const ViewWidget({
    super.key,
    required this.children,
    required this.model,
    this.leftChild,
    this.actions = const [],
    this.popupActions = const [],
    this.gridChild,
    this.favourite,
    this.noRawIdButton = false,
  });

  @override
  State<StatefulWidget> createState() => _ViewWidgetState();
}

class _ViewWidgetState extends State<ViewWidget> {
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();

    if (widget.favourite == null) return;

    setState(() {
      _isFavourite = widget.favourite!.fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    List<ViewWidgetAction> popupActions = [
      ...widget.popupActions,
      if (!widget.noRawIdButton)
        (
          name: "Raw Details",
          icon: Icons.list,
          callback: () {
            navigate(context, RawDetailsPage(map: widget.model.toMap()));
          },
        ),
    ];

    List<Widget> sideButtons = [
      if (widget.favourite != null)
        IconButton(
          onPressed: () async {
            await widget.favourite!.update();
            setState(() {
              _isFavourite = widget.favourite!.fetch();
            });
          },
          icon: Icon(_isFavourite ? Icons.favorite : Icons.favorite_border),
          color: _isFavourite ? Colors.red : null,
        ),
      if (popupActions.isNotEmpty) PopupMenu(items: popupActions),
    ];

    if (widget.gridChild != null) {
      if (widget.gridChild!.onTap != null) {
        return MyCard(
          onTap: widget.gridChild!.onTap,
          child: Center(child: widget.gridChild!.widget),
        );
      } else {
        return MyCard(
          child: PopupMenu(
            items: [
              ...widget.actions.map(
                (action) => (
                  name: action.name,
                  icon: action.icon,
                  callback: action.callback,
                ),
              ),
              ...popupActions.map(
                (action) => (
                  name: action.name,
                  icon: action.icon,
                  callback: action.callback,
                ),
              ),
            ],
            child: Center(child: widget.gridChild!.widget),
          ),
        );
      }
    }

    return MyCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.leftChild != null) ...[
              widget.leftChild!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...widget.children,
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      ...widget.actions.map(
                        (x) => TextButton.icon(
                          onPressed: x.callback,
                          label: Text(x.name),
                          icon: Icon(x.icon),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (sideButtons.isNotEmpty) Column(children: [...sideButtons]),
          ],
        ),
      ),
    );
  }
}
