import 'package:flutter/material.dart';
import 'models/signRequest.dart';
import 'signing_webview.dart'; // Import the new WebView screen

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<SignRequest> mockRequests = [
      SignRequest(
        documentInfo: DocumentInfo(name: "Employment Contract", description: "Standard contract"),
        submitter: "hr@company.com",
        submitterName: "HR Department",
        signatories: [],
        applicationVersion: "1.0",
        state: "SIGNED",
        signingUrl: "https://www.google.com", // Mock URL
      ),
      SignRequest(
        documentInfo: DocumentInfo(name: "NDA Agreement", description: "Confidentiality"),
        submitter: "legal@company.com",
        submitterName: "Legal Team",
        signatories: [],
        applicationVersion: "1.0",
        state: "PENDING",
        signingUrl: "https://flutter.dev", // Mock URL
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Requests Inbox"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        itemCount: mockRequests.length,
        itemBuilder: (context, index) {
          final request = mockRequests[index];

          return ListTile(
            leading: Icon(
              request.isSigned ? Icons.check_circle : Icons.description,
              color: request.isSigned ? Colors.green : Colors.grey,
            ),
            title: Text(request.documentInfo.name),
            subtitle: Text("From: ${request.submitterName}"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (request.signingUrl != null) {
                // Navigate to the WebView screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SigningWebView(
                      url: request.signingUrl!,
                      title: request.documentInfo.name,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No signing URL available")),
                );
              }
            },
          );
        },
      ),
    );
  }
}
