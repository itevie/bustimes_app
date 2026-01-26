import 'package:flutter/material.dart';
import 'package:route_log/bustimes/models/livery.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveryImageWidget extends StatefulWidget {
  final Livery livery;

  const LiveryImageWidget({super.key, required this.livery});

  @override
  State<LiveryImageWidget> createState() => _LiveryImageWidgetState();
}

class _LiveryImageWidgetState extends State<LiveryImageWidget> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadHtmlString('''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>
  body {
    margin: 0;
    padding: 0;
    background: transparent;
  }
  .livery {
    width: 36px;
    height: 24px;
    border: 1px solid black;
  }
</style>
</head>
<body>
  <div class="livery" style="background:${widget.livery.leftCss}"></div>
</body>
</html>
''');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 24,
      child: WebViewWidget(controller: controller),
    );
  }
}
