import 'package:flutter/material.dart';
import 'models/signRequest.dart';
import 'signing_webview.dart';
import 'pdf_viewer_screen.dart'; // Import the PDF viewer screen

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // A robust base64 PDF for testing (Hello World)
    const String mockPdfBase64 = "JVBERi0xLjcKJeLjz9MKMSAwIG9iaiA8PC9UeXBlL0NhdGFsb2cvUGFnZXMgMiAwIFI+PmVuZG9iaiAyIDAgb2JqIDw8L1R5cGUvUGFnZXMvQ291bnQgMS9LaWRzWzMgMCBSXT4+ZW5kb2JqIDMgMCBvYmogPDwvVHlwZS9QYWdlL1BhcmVudCAyIDAgUi9SZXNvdXJjZXM8PC9Gb250PDwvRjEgNCAwIFI+Pj4+L01lZGlhQm94WzAgMCA1OTUuMjc1IDg0MS44OV0vQ29udGVudHMgNSAwIFI+PmVuZG9iaiA0IDAgb2JqIDw8L1R5cGUvRm9udC9TdWJ0eXBlL1R5cGUxL0Jhc2VGb250L0hlbHZldGljYT4+ZW5kb2JqIDUgMCBvYmogPDwvTGVuZ3RoIDQ0Pj5zdHJlYW0KQlQgL0YxIDEyIFRmIDcwIDcwMCBUZCAoSGVsbG8sIFp5bnlvIFBERiBUZXN0ISkgVGogRVQKZW5kc3RyZWFtIGVuZG9iaiB4cmVmIDAgNiAwMDAwMDAwMDAwIDY1NTM1IGYgMDAwMDAwMDAxNSAwMDAwMCBuIDAwMDAwMDAwNjAgMDAwMDAgbiAwMDAwMDAwMTExIDAwMDAwIG4gMDAwMDAwMDIxOSAwMDAwMCBuIDAwMDAwMDAyOTYgMDAwMDAgbiB0cmFpbGVyIDw8L1NpemUgNi9Sb290IDEgMCBSPj4Kc3RhcnR4cmVmIDM5MSAlJUVPRg==";

    final List<SignRequest> mockRequests = [
      SignRequest(
        documentInfo: DocumentInfo(name: "Employment Contract", description: "Standard contract"),
        submitter: "hr@company.com",
        submitterName: "HR Department",
        signatories: [],
        applicationVersion: "1.0",
        state: "SIGNED",
        signingUrl: "https://www.google.com",
        content: mockPdfBase64,
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

          // ExpansionTile (The dropdown row)
          return ExpansionTile(
            leading: Icon(
              request.isSigned ? Icons.check_circle : Icons.description,
              color: request.isSigned ? Colors.green : Colors.grey,
            ),
            title: Text(request.documentInfo.name),
            subtitle: Text("From: ${request.submitterName}"),
            children: [
              // Option 1: Sign Document
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text("Sign Document"),
                subtitle: Text("Open in secure webview"),
                onTap: () {
                  if (request.signingUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SigningWebView(
                          url: request.signingUrl!,
                          title: request.documentInfo.name,
                        ),
                      ),
                    );
                  }
                },
              ),
              // Option 2: View PDF
              ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.blue),
                title: Text("View PDF Document"),
                onTap: () {
                  if (request.content != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PdfViewerScreen(
                          base64Content: request.content!,
                          title: request.documentInfo.name,
                        ),
                      ),
                    );
                  }
                },
              ),
              // Option 3: Details
              ListTile(
                leading: Icon(Icons.info_outline, color: Colors.blue),
                title: Text("View Details"),
                onTap: () {
                  // Show details dialog
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
