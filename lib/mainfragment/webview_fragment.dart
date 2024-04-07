import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewFragment extends StatefulWidget {
  final String url;

  const WebViewFragment({super.key, required this.url});

  @override
  State<WebViewFragment> createState() => _WebViewFragmentState();
}

class _WebViewFragmentState extends State<WebViewFragment> {
  late final WebViewController controller;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter WebView'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
