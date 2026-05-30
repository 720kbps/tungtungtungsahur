import 'package:flutter/material.dart';
import 'models/signRequest.dart';
import 'signing_webview.dart';
import 'pdf_viewer_screen.dart';
import 'document_details_screen.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';

class HomePage extends StatefulWidget {
  final ZynyoService zynyoService;
  final String email;

  const HomePage({required this.zynyoService, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SignRequest>> _documentsFuture;

  @override
  void initState() {
    super.initState();
    _documentsFuture = widget.zynyoService.getDocuments().then(
      (list) => list
          .map((item) => SignRequest.fromJson(item as Map<String, dynamic>))
          .where((request) => request.signatories.any((s) => s.email.toLowerCase() == widget.email.toLowerCase()))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign Requests Inbox"),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<SignRequest>>(
        future: _documentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(child: Text("No documents found."));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];

              return ExpansionTile(
                leading: Icon(
                  request.isRejected
                      ? Icons.cancel
                      : request.isSigned
                          ? Icons.check_circle
                          : Icons.pending,
                  color: request.isRejected
                      ? Colors.red
                      : request.isSigned
                          ? Colors.green
                          : Colors.orange,
                ),
                title: Text(request.documentInfo.name),
                subtitle: Text("From: ${request.submitterName}"),
                children: [
                  ListTile(
                    leading: Icon(Icons.edit, color: Colors.blue),
                    title: Text("Sign Document"),
                    subtitle: Text("Open in secure webview"),
                    onTap: () async {
                      // Find the signatory that matches the logged in user's email
                      final userSignatory = request.signatories.firstWhere(
                        (s) => s.email.toLowerCase() == widget.email.toLowerCase(),
                        orElse: () => request.signatories.first,
                      );

                      if (userSignatory.publicUUID != null) {
                        final url = await widget.zynyoService.getSigningUrl(userSignatory.publicUUID!);
                        print("SIGNING URL: $url");
                        
                        // if (url != null && mounted) {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => SigningWebView(
                        //         url: url,
                        //         title: request.documentInfo.name,
                        //       ),
                        //     ),
                        //   );
                        // }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("No signing link available for this signatory.")),
                        );
                      }
                    },
                  ),
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
                  ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.blue),
                    title: Text("View Details"),
                    subtitle: Text("State: ${request.state ?? 'Unknown'}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DocumentDetailsScreen(request: request),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}