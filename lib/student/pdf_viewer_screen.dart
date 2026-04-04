import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String subjectName;
  final String subjectCode;

  const PDFViewerScreen({
    Key? key,
    required this.pdfPath,
    required this.subjectName,
    required this.subjectCode,
  }) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 0;
  PDFViewController? _pdfController;
  String? _localPath;

  @override
  void initState() {
    super.initState();
    _preparePDF();
  }

  Future<void> _preparePDF() async {
    try {
      // Copy asset to local file
      final byteData = await rootBundle.load(widget.pdfPath);
      final file = File('${(await getTemporaryDirectory()).path}/temp.pdf');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      setState(() {
        _localPath = file.path;
      });
      
      print('PDF copied to: ${file.path}'); // Debug print
    } catch (e) {
      print('Error preparing PDF: $e'); // Debug print
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building PDF Viewer with path: ${widget.pdfPath}'); // Debug print
    
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F3F6),
        
        /// Custom App Bar
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: const Color(0xFFA50C22),
            elevation: 1,
            automaticallyImplyLeading: true,
            title: Column(
              children: [
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/somaiyalogo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.subjectName,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Curriculum • ${widget.subjectCode}",
                            style: GoogleFonts.inter(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      "assets/images/somaiyatrust.png",
                      height: 45,
                      width: 45,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
        ),

        body: Column(
          children: [
            /// Page navigation bar
            if (_totalPages > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _currentPage > 0
                          ? () => _pdfController?.setPage(_currentPage - 1)
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_left),
                      color: _currentPage > 0 
                          ? const Color(0xFFA50C22) 
                          : Colors.grey,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "Page ${_currentPage + 1} of $_totalPages",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _currentPage < _totalPages - 1
                          ? () => _pdfController?.setPage(_currentPage + 1)
                          : null,
                      icon: const Icon(Icons.keyboard_arrow_right),
                      color: _currentPage < _totalPages - 1 
                          ? const Color(0xFFA50C22) 
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            
            /// PDF Viewer
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isLoading || _localPath == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFFA50C22),
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Loading curriculum...",
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : PDFView(
                          filePath: _localPath,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: false,
                          pageFling: false,
                          onRender: (pages) {
                            setState(() {
                              _totalPages = pages ?? 0;
                              _isLoading = false;
                            });
                          },
                          onError: (error) {
                            print('PDF Error: $error'); // Debug print
                            setState(() {
                              _isLoading = false;
                            });
                            _showErrorDialog();
                          },
                          onPageError: (page, error) {
                            print('Error loading page $page: $error');
                          },
                          onViewCreated: (PDFViewController pdfViewController) {
                            _pdfController = pdfViewController;
                          },
                          onPageChanged: (page, total) {
                            setState(() {
                              _currentPage = page ?? 0;
                            });
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
        
        /// Bottom action buttons
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFA50C22)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Back",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA50C22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _totalPages > 0 ? _downloadPDF : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA50C22),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Download",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          "PDF Not Available",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        content: Text(
          "The curriculum PDF for this subject is currently not available. Please try again later or contact the faculty.",
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "OK",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA50C22),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadPDF() {
    // Show a simple snackbar for now
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Download functionality will be implemented soon!",
          style: GoogleFonts.inter(fontSize: 14),
        ),
        backgroundColor: const Color(0xFFA50C22),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}