import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeleteStudentScreen extends StatefulWidget {
  const DeleteStudentScreen({Key? key}) : super(key: key);

  @override
  State<DeleteStudentScreen> createState() => _DeleteStudentScreenState();
}

class _DeleteStudentScreenState extends State<DeleteStudentScreen> {
  List<dynamic> _students = [];
  List<dynamic> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
    _searchController.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    print('Loading students...');
    try {
      final response = await http.get(
        Uri.parse('http://13.235.16.3:5001/student/'),
      );

      print('Load students response status: ${response.statusCode}');
      print('Load students response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');
        setState(() {
          _students = data['data'] ?? [];
          _filteredStudents = _students;
          _isLoading = false;
        });
        print('Students loaded: ${_students.length} students');
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load students');
      }
    } catch (e) {
      print('Error loading students: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Network error: $e');
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((student) {
        return student['name'].toString().toLowerCase().contains(query) ||
               student['roll_number'].toString().toLowerCase().contains(query) ||
               student['student_id'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _deleteStudent(String studentId) async {
    print('Attempting to delete student: $studentId');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete student with ID: $studentId?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final deleteUrl = 'http://13.235.16.3:5001/student/$studentId';
        print('Delete URL: $deleteUrl');
        
        final response = await http.delete(
          Uri.parse(deleteUrl),
        );

        print('Delete response status: ${response.statusCode}');
        print('Delete response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 204) {
          _showSuccessSnackBar('Student deleted successfully!');
          _loadStudents();
        } else {
          _showErrorSnackBar('Failed to delete student. Status: ${response.statusCode}');
        }
      } catch (e) {
        print('Delete error: $e');
        _showErrorSnackBar('Network error: $e');
      }
    }
  }

  Widget _buildStudentCard(dynamic student) {
    final studentId = student['student_id'].toString();
    final name = student['name'].toString();
    final rollNumber = student['roll_number'].toString();
    final email = student['email'].toString();
    final department = student['department'].toString();
    final year = student['year'].toString();
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFA50C22),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Roll: $rollNumber',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
                  onPressed: () => _deleteStudent(studentId),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.business, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Text(
                  department,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.school, size: 14, color: const Color(0xFF6B7280)),
                const SizedBox(width: 3),
                Text(
                  year,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFA50C22),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Delete Students',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search students by name, roll number, or ID...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFA50C22)),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          
          // Student List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person_off, size: 64, color: Color(0xFF9CA3AF)),
                            const SizedBox(height: 16),
                            Text(
                              'No students found',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          return _buildStudentCard(_filteredStudents[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
