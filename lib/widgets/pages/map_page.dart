import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:route_log/widgets/pages/lists/service_page.dart';
import 'package:route_log/widgets/pages/lists/vehicles_page.dart';

class BustimesMapPage extends StatefulWidget {
  final bool isPage;
  final String? preSearch;

  const BustimesMapPage({super.key, this.preSearch, this.isPage = false});

  @override
  State<BustimesMapPage> createState() => _BustimesMapPageState();
}

class _BustimesMapPageState extends State<BustimesMapPage> {
  InAppWebViewController? _controller;

  @override
  void initState() {
    super.initState();
    Permission.locationWhenInUse.request();
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Center(
        child: const Text("The map can only be used on Android at the moment."),
      );
    }
    final givenWidget = PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_controller != null && await _controller!.canGoBack()) {
          _controller?.goBack();
          return;
        }

        if (widget.isPage && context.mounted) {
          Navigator.of(context).pop();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.preSearch ?? "https://bustimes.org/map"),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              geolocationEnabled: true,
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onGeolocationPermissionsShowPrompt: (controller, origin) async {
              return GeolocationPermissionShowPromptResponse(
                origin: origin,
                allow: true,
                retain: true,
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final url = navigationAction.request.url?.toString();
              if (url == null) return NavigationActionPolicy.ALLOW;

              final search = url.split("/").last;
              if (context.mounted) {
                if (url.contains("/vehicles/")) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => VehiclesPage(
                            search: AllVehicles(),
                            fullSearch: {"slug": search},
                          ),
                    ),
                  );
                  return NavigationActionPolicy.CANCEL;
                } else if (url.contains("/services/")) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) => ServicePage(
                            search: AllServices(),
                            fullSearch: {"slug": search},
                          ),
                    ),
                  );
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
          ),

          // 🔙 Floating back button
          Positioned(
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            right: 16,
            child: FloatingActionButton(
              heroTag: "webview-back",
              onPressed: () async {
                if (_controller != null && await _controller!.canGoBack()) {
                  await _controller!.goBack();
                } else {}
              },
              child: const Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );

    return widget.isPage
        ? Scaffold(
          appBar: AppBar(title: Text("Bustimes Map")),
          body: givenWidget,
        )
        : givenWidget;
  }
}
