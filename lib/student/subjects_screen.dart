import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'syncfusion_pdf_viewer_screen.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({Key? key}) : super(key: key);

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/subjects_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      
      setState(() {
        _subjects = List<Map<String, dynamic>>.from(data['subjects']);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading subjects: $e');
      // Use fallback data if JSON doesn't exist
      setState(() {
        _subjects = _getFallbackSubjects();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackSubjects() {
    return [
      {
        'code': '023RC22',
        'name': 'Image Processing',
        'faculty': 'Manjiri Samant',
        'type': 'Theory',
        'credits': 4,
        'syllabus': [
          'Introduction to Digital Image Processing',
          'Image Enhancement and Filtering',
          'Image Segmentation',
          'Feature Extraction and Description',
          'Object Recognition and Classification',
          'Image Compression Techniques',
          'Practical Applications and Case Studies'
        ],
        'color': '0xFFE3F2FD',
        'curriculum_pdf': 'assets/pdfs/Software Engineering.pdf'
      },
      {
        'code': '023RC23',
        'name': 'Computer Networks',
        'faculty': 'N. R. Kadam',
        'type': 'Theory',
        'credits': 4,
        'syllabus': [
          'Network Models and Protocols',
          'Physical Layer and Transmission Media',
          'Data Link Layer and MAC Protocols',
          'Network Layer and Routing Algorithms',
          'Transport Layer Protocols (TCP/UDP)',
          'Application Layer Protocols',
          'Network Security Fundamentals'
        ],
        'color': '0xFFF3E5F5',
        'curriculum_pdf': 'assets/pdfs/computer_networks_curriculum.pdf'
      },
      {
        'code': '023RC24',
        'name': 'Software Engineering',
        'faculty': 'V. Kulkarni',
        'type': 'Theory',
        'credits': 4,
        'syllabus': [
          'Software Process Models',
          'Requirements Engineering',
          'System Modeling and Design',
          'Architectural Design Patterns',
          'Software Testing Strategies',
          'Project Management and Planning',
          'Software Maintenance and Evolution'
        ],
        'color': '0xFFE8F5E8',
        'curriculum_pdf': 'assets/pdf/Image_Processing.pdf'
      },
      {
        'code': '023RC25',
        'name': 'Internet Programming',
        'faculty': 'F. I. Shaikh',
        'type': 'Theory',
        'credits': 4,
        'syllabus': [
          'Web Technologies Overview',
          'HTML5 and Semantic Markup',
          'CSS3 and Responsive Design',
          'JavaScript and DOM Manipulation',
          'Server-Side Programming with Node.js',
          'RESTful API Design',
          'Modern Frameworks and Tools'
        ],
        'color': '0xFFFFF3E0',
        'curriculum_pdf': 'assets/pdf/notes.pdf'
      },
      {
        'code': '023RC26',
        'name': 'LAN Lab',
        'faculty': 'M. Kadam',
        'type': 'Lab',
        'credits': 2,
        'syllabus': [
          'Network Configuration and Setup',
          'IP Addressing and Subnetting',
          'Router and Switch Configuration',
          'Network Troubleshooting Tools',
          'LAN Security Implementation',
          'Network Performance Monitoring',
          'Practical Network Design'
        ],
        'color': '0xFFFCE4EC',
        'curriculum_pdf': 'assets/pdf/notes.pdf'
      },
      {
        'code': '023RC27',
        'name': 'SE Lab',
        'faculty': 'V. Kulkarni',
        'type': 'Lab',
        'credits': 2,
        'syllabus': [
          'Software Development Life Cycle',
          'Version Control with Git',
          'Agile Development Practices',
          'Unit Testing and TDD',
          'Code Review and Refactoring',
          'Documentation and Reporting',
          'Project Presentation'
        ],
        'color': '0xFFE0F2F1',
        'curriculum_pdf': 'assets/pdf/SE_LAB.pdf'
      }
    ];
  }

  @override
  Widget build(BuildContext context) {
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
                            "Subjects & Syllabus",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "TYCO",
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

        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFA50C22),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Stats Cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              "Total Subjects",
                              "${_subjects.length}",
                              Icons.menu_book_outlined,
                              const Color(0xFFE3F2FD),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              "Total Credits",
                              "${_subjects.fold<int>(0, (sum, subject) => sum + (subject['credits'] as int))}",
                              Icons.school_outlined,
                              const Color(0xFFE8F5E8),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      /// Subjects List
                      Text(
                        "All Subjects",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      ..._subjects.map((subject) => _buildSubjectCard(subject)).toList(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: const Color(0xFFA50C22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF111827),
                  ),
                ),
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          /// Header with color band
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Color(int.parse(subject['color'] ?? '0xFFFFF1F2')),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject['name'] ?? 'Unknown Subject',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${subject['code'] ?? 'N/A'} • ${subject['type'] ?? 'Theory'}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA50C22).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${subject['credits'] ?? 0} Credits",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA50C22),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          /// Details body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              children: [
                _subjectInfoRow(
                  Icons.person_outline_rounded,
                  "Faculty",
                  subject['faculty'] ?? 'Not Assigned',
                ),
                const _divider(),
                _subjectInfoRow(
                  Icons.menu_book_outlined,
                  "Topics Covered",
                  "${(subject['syllabus'] as List<dynamic>?)?.length ?? 0} Topics",
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openCurriculumPDF(subject),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA50C22),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "View Curriculum",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subjectInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFA50C22)),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  void _showSyllabusDialog(Map<String, dynamic> subject) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Dialog Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFA50C22),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject['name'] ?? 'Subject Syllabus',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject['code'] ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              
              /// Syllabus Content
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Course Topics",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...(subject['syllabus'] as List<dynamic>? ?? []).map((topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA50C22),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  topic.toString(),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF374151),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              
              /// Close Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _openCurriculumPDF(subject),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFA50C22)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_outlined,
                              size: 18,
                              color: Color(0xFFA50C22),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "View Curriculum",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFA50C22),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA50C22),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Close",
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
            ],
          ),
        ),
      ),
    );
  }

  void _openCurriculumPDF(Map<String, dynamic> subject) {
    final String pdfPath = subject['curriculum_pdf'] ?? '';
    final String subjectName = subject['name'] ?? 'Unknown Subject';
    final String subjectCode = subject['code'] ?? 'N/A';

    print('Opening PDF: $pdfPath'); // Debug print

    if (pdfPath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Curriculum PDF not available for this subject",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          backgroundColor: const Color(0xFFEF4444),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SyncfusionPDFViewerScreen(
          pdfPath: pdfPath,
          subjectName: subjectName,
          subjectCode: subjectCode,
        ),
      ),
    );
  }
}

class _divider extends StatelessWidget {
  const _divider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 18, thickness: 1, color: Color(0xFFF3F4F6));
}