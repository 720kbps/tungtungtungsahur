import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SigningWebView extends StatefulWidget {
  final String url;
  final String title;

  const SigningWebView({
    Key? key,
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  State<SigningWebView> createState() => _SigningWebViewState();
}

class _SigningWebViewState extends State<SigningWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blue,
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
