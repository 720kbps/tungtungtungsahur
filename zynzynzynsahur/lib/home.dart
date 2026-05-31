import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/signRequest.dart';
import 'signing_webview.dart';
import 'pdf_viewer_screen.dart';
import 'document_details_screen.dart';
import 'login.dart';
import 'statistics_screen.dart';
import 'package:zynzynzynsahur/services/zynyo_service.dart';

class HomePage extends StatefulWidget {
  final ZynyoService zynyoService;
  final String email;

  const HomePage({super.key, required this.zynyoService, required this.email});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<SignRequest>> _documentsFuture;
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Signed', 'Rejected'];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  Future<void> _fetchDocuments() async {
    setState(() {
      _documentsFuture = widget.zynyoService.getDocuments().then(
            (list) => list
                .map((item) => SignRequest.fromJson(item as Map<String, dynamic>))
                .where((request) => request.signatories.any((s) => s.email.toLowerCase() == widget.email.toLowerCase()))
                .toList(),
          );
    });
    await _documentsFuture;
  }

  List<SignRequest> _applyFilter(List<SignRequest> documents) {
    if (_selectedFilter == 'All') return documents;
    return documents.where((doc) {
      if (_selectedFilter == 'Pending') return doc.isPending;
      if (_selectedFilter == 'Signed') return doc.isSigned;
      if (_selectedFilter == 'Rejected') return doc.isRejected;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Zynyo Inbox",
          style: GoogleFonts.inter(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(zynyoService: widget.zynyoService),
                  ),
                );
              } else if (value == 'statistics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'statistics',
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Statistics'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          Expanded(
            child: FutureBuilder<List<SignRequest>>(
              future: _documentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final allRequests = snapshot.data ?? [];
                final filteredRequests = _applyFilter(allRequests);

                return RefreshIndicator(
                  onRefresh: _fetchDocuments,
                  child: filteredRequests.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Text(
                                  "No $_selectedFilter documents found.",
                                  style: GoogleFonts.inter(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredRequests.length,
                          itemBuilder: (context, index) {
                            return _DocumentCard(
                              request: filteredRequests[index],
                              currentUserEmail: widget.email,
                              onSign: (request) => _onSignDocument(context, request),
                              onViewPdf: (request) => _onViewPdf(context, request),
                              onViewDetails: (request) => _onViewDetails(context, request),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                filter,
                style: GoogleFonts.inter(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                }
              },
              selectedColor: Colors.black,
              backgroundColor: const Color(0xFFECEEF2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
              side: BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onSignDocument(BuildContext context, SignRequest request) async {
    final userSignatory = request.signatories.firstWhere(
      (s) => s.email.toLowerCase() == widget.email.toLowerCase(),
      orElse: () => request.signatories.first,
    );

    if (userSignatory.publicUUID != null) {
      final url = await widget.zynyoService.getSigningUrl(userSignatory.publicUUID!);
      if (url != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SigningWebView(
              url: url,
              title: request.documentInfo.name,
            ),
          ),
        ).then((_) => _fetchDocuments());
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No signing link available for this signatory.")),
      );
    }
  }

  void _onViewPdf(BuildContext context, SignRequest request) async {
    final response = await widget.zynyoService.getSignedDocument(request.uuid!);
    final base64Pdf = response['documentContent'];
    if (base64Pdf != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            base64Content: base64Pdf,
            title: request.documentInfo.name,
          ),
        ),
      );
    }
  }

  void _onViewDetails(BuildContext context, SignRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailsScreen(request: request),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final SignRequest request;
  final String currentUserEmail;
  final Function(SignRequest) onSign;
  final Function(SignRequest) onViewPdf;
  final Function(SignRequest) onViewDetails;

  const _DocumentCard({
    required this.request,
    required this.currentUserEmail,
    required this.onSign,
    required this.onViewPdf,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final signedCount = request.signatories.where((s) => s.state == 'SIGNED').length;
    final totalCount = request.signatories.length;
    final currentUserSignatory = request.signatories.firstWhere(
      (s) => s.email.toLowerCase() == currentUserEmail.toLowerCase(),
      orElse: () => request.signatories.first,
    );
    final hasCurrentUserSigned = currentUserSignatory.state == 'SIGNED';

    Color statusColor;
    Color iconBgColor;
    IconData iconData;
    String statusText;

    if (request.isRejected) {
      statusColor = const Color(0xFFFEE2E2);
      iconBgColor = const Color(0xFFFEF2F2);
      iconData = Icons.close;
      statusText = "Rejected";
    } else if (request.isSigned) {
      statusColor = const Color(0xFFDCFCE7);
      iconBgColor = const Color(0xFFF0FDF4);
      iconData = Icons.check_circle_outline;
      statusText = "Signed";
    } else if (hasCurrentUserSigned) {
      statusColor = const Color(0xFFDBEAFE);
      iconBgColor = const Color(0xFFEFF6FF);
      iconData = Icons.access_time;
      statusText = "Waiting";
    } else {
      statusColor = const Color(0xFFFFEDD5);
      iconBgColor = const Color(0xFFFFF7ED);
      iconData = Icons.description_outlined;
      statusText = "Pending";
    }

    return GestureDetector(
      onTap: () => onViewDetails(request),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: _getStatusTextColor(request), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.documentInfo.name,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        statusText == "Waiting" 
                          ? "Sent to ${request.signatories.firstWhere((s) => s.state != 'SIGNED', orElse: () => request.signatories.first).name}"
                          : "From ${request.submitterName}",
                        style: GoogleFonts.inter(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: GoogleFonts.inter(
                          color: _getStatusTextColor(request),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // We don't have date in model yet, but can show signatory count
                    if (!request.isSigned && !request.isRejected)
                    Text(
                      "$signedCount of $totalCount",
                      style: GoogleFonts.inter(
                        color: Colors.black38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!request.isSigned && !request.isRejected)
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: Color(0xFF4F46E5)),
                      const SizedBox(width: 6),
                      Text(
                        "${totalCount - signedCount} signatory remaining",
                        style: GoogleFonts.inter(
                          color: const Color(0xFF4F46E5),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                else
                   Row(
                    children: [
                      Icon(
                        request.isSigned ? Icons.check_circle : Icons.error_outline,
                        size: 16,
                        color: _getStatusTextColor(request),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.isSigned ? "All signatures collected" : "Request rejected",
                        style: GoogleFonts.inter(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                
                if (!request.isSigned && !request.isRejected)
                  TextButton(
                    onPressed: () => onSign(request),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Sign now",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF2563EB)),
                      ],
                    ),
                  )
                else if (request.isSigned)
                   TextButton(
                    onPressed: () => onViewPdf(request),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Text(
                          "View PDF",
                          style: GoogleFonts.inter(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusTextColor(SignRequest request) {
    if (request.isRejected) return const Color(0xFF991B1B);
    if (request.isSigned) return const Color(0xFF166534);
    
    // Check if current user signed but others didn't (Waiting)
    final currentUserSignatory = request.signatories.firstWhere(
      (s) => s.email.toLowerCase() == currentUserEmail.toLowerCase(),
      orElse: () => request.signatories.first,
    );
    if (currentUserSignatory.state == 'SIGNED') return const Color(0xFF1E40AF);

    return const Color(0xFF9A3412);
  }
}
