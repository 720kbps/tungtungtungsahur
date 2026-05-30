import 'package:flutter/material.dart';
import 'models/signRequest.dart'; // Import our new model

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // mock fake list
    final List<SignRequest> mockRequests = [
      SignRequest(
        documentInfo: DocumentInfo(name: "Employment Contract", description: "Standard contract"),
        submitter: "hr@company.com",
        submitterName: "HR Department",
        signatories: [],
        applicationVersion: "1.0",
        state: "SIGNED",
      ),
      SignRequest(
        documentInfo: DocumentInfo(name: "NDA Agreement", description: "Confidentiality"),
        submitter: "legal@company.com",
        submitterName: "Legal Team",
        signatories: [],
        applicationVersion: "1.0",
        state: "PENDING",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Document Inbox"),
        backgroundColor: Colors.blue,
      ),
      // 2. The ListView (The scrollable container)
      body: ListView.builder(
        itemCount: mockRequests.length,
        itemBuilder: (context, index) {
          final request = mockRequests[index];

          // 3. The ListTile (The individual row)
          return ListTile(
            leading: Icon(
              request.isSigned ? Icons.check_circle : Icons.description,
              color: request.isSigned ? Colors.green : Colors.grey,
            ),
            title: Text(request.documentInfo.name),
            subtitle: Text("From: ${request.submitterName}"),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              print("Clicked on ${request.documentInfo.name}");
            },
          );
        },
      ),
    );
  }
}
