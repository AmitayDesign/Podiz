import 'package:flutter/material.dart';
import 'package:podiz/src/theme/context_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum DocumentType { privacy, terms }

extension DocumentTypeX on DocumentType {
  String get title {
    switch (this) {
      case DocumentType.privacy:
        return 'Privacy';
      case DocumentType.terms:
        return 'Terms';
    }
  }

  String get url {
    switch (this) {
      case DocumentType.privacy:
        return 'https://app.getterms.io/view/9zEeI/privacy/en-us';
      case DocumentType.terms:
        return 'https://app.getterms.io/view/9zEeI/tos/en-us';
    }
  }
}

class DocumentScreen extends StatefulWidget {
  final DocumentType type;
  const DocumentScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  var loading = true;
  late final webViewController = WebViewController()
    ..loadRequest(Uri.parse(widget.type.url))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (progress) {
          if (progress == 100) setState(() => loading = false);
        },
      ),
    );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type.title),
        backgroundColor: context.colorScheme.primaryContainer,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          WebViewWidget(controller: webViewController),
          if (loading) const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }
}
