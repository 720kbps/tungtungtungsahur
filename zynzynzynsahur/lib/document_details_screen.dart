import 'package:flutter/material.dart';
import 'models/signRequest.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final SignRequest request;

  const DocumentDetailsScreen({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Document Details"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("Status & ID"),
            _detailRow("UUID", request.uuid ?? "N/A"),
            _detailRow("State", request.state ?? "Unknown"),
            _detailRow("Reference", request.reference ?? "None"),

            const Divider(height: 32),
            _sectionHeader("Document Information"),
            _detailRow("Name", request.documentInfo.name),
            _detailRow("Description", request.documentInfo.description),

            const Divider(height: 32),
            _sectionHeader("Submitter"),
            _detailRow("Name", request.submitterName),
            _detailRow("Email", request.submitter),

            const Divider(height: 32),
            _sectionHeader("Signatories"),
            ...request.signatories.map((s) => _signatoryTile(s)).toList(),

            const Divider(height: 32),
            _sectionHeader("Other Information"),
            _detailRow("App Version", request.applicationVersion),
            _detailRow("Callback URL", request.callbackURL ?? "None"),
            _detailRow("Signing URL", request.signingUrl ?? "None"),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _signatoryTile(Signatory s) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${s.email}"),
            Text("Role: ${s.signatoryRole}"),
            Text("Public UUID: ${s.publicUUID ?? 'N/A'}"),
            Text("Auth: ${s.authenticationMethods.map((a) => a.type).join(', ')}"),
          ],
        ),
      ),
    );
  }
}
