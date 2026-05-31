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

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Inbox (recipient)
  final List<SignRequest> _inboxDocs = [];
  bool _inboxLoading = false;
  bool _inboxHasMore = true;
  int _inboxPage = 0;

  // Sent (submitter)
  final List<SignRequest> _sentDocs = [];
  bool _sentLoading = false;
  bool _sentHasMore = true;
  int _sentPage = 0;

  static const int _pageSize = 20;

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Signed', 'Rejected'];

  final ScrollController _inboxScrollController = ScrollController();
  final ScrollController _sentScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInbox(reset: true);
    _fetchSent(reset: true);

    _inboxScrollController.addListener(() {
      if (_inboxScrollController.position.pixels >=
          _inboxScrollController.position.maxScrollExtent - 200) {
        _fetchInbox();
      }
    });
    _sentScrollController.addListener(() {
      if (_sentScrollController.position.pixels >=
          _sentScrollController.position.maxScrollExtent - 200) {
        _fetchSent();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inboxScrollController.dispose();
    _sentScrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInbox({bool reset = false}) async {
    if (_inboxLoading || (!_inboxHasMore && !reset)) return;
    setState(() => _inboxLoading = true);

    if (reset) {
      _inboxDocs.clear();
      _inboxPage = 0;
      _inboxHasMore = true;
    }

    try {
      final list = await widget.zynyoService.getDocuments(
        email: widget.email,
        startPosition: _inboxPage * _pageSize,
        maxResults: _pageSize,
        recipientFilter: true,
      );
      final docs = list
          .map((item) => SignRequest.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _inboxDocs.addAll(docs);
        _inboxPage++;
        _inboxHasMore = docs.length == _pageSize;
      });
    } catch (e) {
      print("Inbox fetch error: $e");
    } finally {
      setState(() => _inboxLoading = false);
    }
  }

  Future<void> _fetchSent({bool reset = false}) async {
    if (_sentLoading || (!_sentHasMore && !reset)) return;
    setState(() => _sentLoading = true);

    if (reset) {
      _sentDocs.clear();
      _sentPage = 0;
      _sentHasMore = true;
    }

    try {
      final list = await widget.zynyoService.getDocuments(
        email: widget.email,
        startPosition: _sentPage * _pageSize,
        maxResults: _pageSize,
        recipientFilter: false,
      );
      final docs = list
          .map((item) => SignRequest.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _sentDocs.addAll(docs);
        _sentPage++;
        _sentHasMore = docs.length == _pageSize;
      });
    } catch (e) {
      print("Sent fetch error: $e");
    } finally {
      setState(() => _sentLoading = false);
    }
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
        ).then((_) => _fetchInbox(reset: true));
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black38,
          labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              icon: const Icon(Icons.inbox),
              text: "Inbox (${_inboxDocs.length})",
            ),
            Tab(
              icon: const Icon(Icons.send),
              text: "Sent (${_sentDocs.length})",
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilters(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDocumentList(
                  docs: _applyFilter(_inboxDocs),
                  isLoading: _inboxLoading,
                  hasMore: _inboxHasMore,
                  scrollController: _inboxScrollController,
                  onRefresh: () => _fetchInbox(reset: true),
                  emptyMessage: "No documents in your inbox.",
                  showSignButton: true,
                ),
                _buildDocumentList(
                  docs: _applyFilter(_sentDocs),
                  isLoading: _sentLoading,
                  hasMore: _sentHasMore,
                  scrollController: _sentScrollController,
                  onRefresh: () => _fetchSent(reset: true),
                  emptyMessage: "You haven't sent any documents.",
                  showSignButton: false,
                ),
              ],
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
                if (selected) setState(() => _selectedFilter = filter);
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

  Widget _buildDocumentList({
    required List<SignRequest> docs,
    required bool isLoading,
    required bool hasMore,
    required ScrollController scrollController,
    required Future<void> Function() onRefresh,
    required String emptyMessage,
    required bool showSignButton,
  }) {
    if (!isLoading && docs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text("Refresh"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: docs.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == docs.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          return _DocumentCard(
            request: docs[index],
            currentUserEmail: widget.email,
            showSignButton: showSignButton,
            onSign: (request) => _onSignDocument(context, request),
            onViewPdf: (request) => _onViewPdf(context, request),
            onViewDetails: (request) => _onViewDetails(context, request),
          );
        },
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final SignRequest request;
  final String currentUserEmail;
  final bool showSignButton;
  final Function(SignRequest) onSign;
  final Function(SignRequest) onViewPdf;
  final Function(SignRequest) onViewDetails;

  const _DocumentCard({
    required this.request,
    required this.currentUserEmail,
    required this.showSignButton,
    required this.onSign,
    required this.onViewPdf,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final signedCount = request.signatories.where((s) => s.state == 'VALIDATED').length;
    final totalCount = request.signatories.length;
    final currentUserSignatory = request.signatories.firstWhere(
      (s) => s.email.toLowerCase() == currentUserEmail.toLowerCase(),
      orElse: () => request.signatories.first,
    );
    final hasCurrentUserSigned = currentUserSignatory.state == 'VALIDATED';

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
                  child: Icon(iconData, color: _getStatusTextColor(), size: 24),
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
                            ? "Sent to ${request.signatories.firstWhere((s) => s.state != 'VALIDATED', orElse: () => request.signatories.first).name}"
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
                          color: _getStatusTextColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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
                        color: _getStatusTextColor(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        request.isSigned
                            ? "All signatures collected"
                            : "Request rejected",
                        style: GoogleFonts.inter(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                if (showSignButton && !request.isSigned && !request.isRejected && !hasCurrentUserSigned)
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

  Color _getStatusTextColor() {
    if (request.isRejected) return const Color(0xFF991B1B);
    if (request.isSigned) return const Color(0xFF166534);
    final currentUserSignatory = request.signatories.firstWhere(
      (s) => s.email.toLowerCase() == currentUserEmail.toLowerCase(),
      orElse: () => request.signatories.first,
    );
    if (currentUserSignatory.state == 'VALIDATED') return const Color(0xFF1E40AF);
    return const Color(0xFF9A3412);
  }
}