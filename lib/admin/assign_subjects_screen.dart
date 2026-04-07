import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AssignSubjectsScreen extends StatefulWidget {
  const AssignSubjectsScreen({Key? key, required this.batch}) : super(key: key);

  final String batch;

  @override
  State<AssignSubjectsScreen> createState() => _AssignSubjectsScreenState();
}

class _AssignSubjectsScreenState extends State<AssignSubjectsScreen> {
  String _selectedFaculty = '';
  String _selectedCourse = '';
  List<dynamic> _faculty = [];
  List<dynamic> _courses = [];
  bool _isLoading = false;
  
  // Store multiple selections
  List<Map<String, String>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadFaculty();
    _loadCourses();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = prefs.getString('assignments_${widget.batch}');
    if (assignmentsJson != null && assignmentsJson.isNotEmpty) {
      try {
        final assignmentsList = jsonDecode(assignmentsJson) as List;
        setState(() {
          _assignments = assignmentsList.map((item) => Map<String, String>.from(item)).toList();
        });
      } catch (e) {
        print('Error loading assignments: $e');
      }
    }
  }

  Future<void> _saveAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('assignments_${widget.batch}', jsonEncode(_assignments));
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

  Future<void> _loadFaculty() async {
    try {
      final response = await http.get(
        Uri.parse('http://13.235.16.3:5001/api/faculty/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _faculty = data['data'] ?? [];
        });
      }
    } catch (e) {
      print('Error loading faculty: $e');
    }
  }

  Future<void> _loadCourses() async {
    try {
      final response = await http.get(
        Uri.parse('http://13.235.16.3:5001/courses/'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allCourses = data['courses'] ?? [];
        
        // Filter courses by batch
        final filteredCourses = allCourses.where((course) {
          return course[3].toString() == widget.batch; // course[3] is batch
        }).toList();
        
        setState(() {
          _courses = filteredCourses;
        });
      }
    } catch (e) {
      print('Error loading courses: $e');
    }
  }

  Future<void> _assignSubject() async {
    if (_selectedFaculty.isEmpty || _selectedCourse.isEmpty) {
      _showErrorSnackBar('Please select both faculty and course');
      return;
    }

    // Add to assignments list instead of replacing
    setState(() {
      _assignments.add({
        'faculty': _getFacultyName(_selectedFaculty),
        'course': _getCourseName(_selectedCourse),
        'faculty_id': _selectedFaculty,
        'course_code': _selectedCourse,
      });
    });

    // Save assignments to persistent storage
    await _saveAssignments();

    _showSuccessSnackBar('Selection ready: ${_getFacultyName(_selectedFaculty)} → ${_getCourseName(_selectedCourse)}');
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
          'Assign Subjects',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA50C22),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_ind,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assign Subjects',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Select faculty and course to assign subjects',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dropdowns Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Faculty',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedFaculty.isEmpty ? null : _selectedFaculty,
                    decoration: InputDecoration(
                      hintText: 'Choose faculty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFA50C22)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _faculty.map<DropdownMenuItem<String>>((fac) {
                      return DropdownMenuItem<String>(
                        value: fac['faculty_id'].toString(),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            '${fac['name']} (${fac['faculty_id']})',
                            style: GoogleFonts.inter(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFaculty = value ?? '';
                      });
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    'Select Course',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCourse.isEmpty ? null : _selectedCourse,
                    decoration: InputDecoration(
                      hintText: 'Choose course',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFA50C22)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _courses.map<DropdownMenuItem<String>>((course) {
                      return DropdownMenuItem<String>(
                        value: course[0].toString(), // course_code
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            '${course[1]} (${course[0]})', // course_name (course_code)
                            style: GoogleFonts.inter(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value ?? '';
                      });
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Selection Display Card
            if (_selectedFaculty.isNotEmpty || _selectedCourse.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.assignment_turned_in,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Selection',
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Faculty: ${_getFacultyName(_selectedFaculty)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Course: ${_getCourseName(_selectedCourse)}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Assign Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _assignSubject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA50C22),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Assign Subject',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            
            // Selection Summary Card Below Button
            if (_assignments.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: const Color(0xFF10B981),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Assignments (${_assignments.length})',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Display assignments as cards
                    ..._assignments.map((assignment) => _buildAssignmentCard(assignment)).toList(),
                    const SizedBox(height: 16),
                    // Clear All Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _assignments.clear();
                          });
                          _showSuccessSnackBar('All assignments cleared');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF4444)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: const Color(0xFFEF4444),
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
    );
  }
  
  String _getFacultyName(String facultyId) {
    final faculty = _faculty.firstWhere((fac) => fac['faculty_id'].toString() == facultyId, orElse: () => null);
    return faculty?['name']?.toString() ?? 'Unknown Faculty';
  }
  
  String _getCourseName(String courseCode) {
    for (var course in _courses) {
      // Handle both List and String formats
      if (course is List) {
        if (course[0].toString() == courseCode) {
          return course[1]?.toString() ?? 'Unknown Course';
        }
      } else if (course is String) {
        if (course == courseCode) {
          return course;
        }
      }
    }
    return 'Unknown Course';
  }
  
  Widget _buildAssignmentCard(Map<String, String> assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${assignment['faculty']} → ${assignment['course']}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${assignment['faculty_id']} → ${assignment['course_code']}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFFEF4444)),
            onPressed: () {
              setState(() {
                _assignments.removeWhere((item) => 
                  item['faculty'] == assignment['faculty'] && 
                  item['course'] == assignment['course']
                );
              });
              _showSuccessSnackBar('Assignment removed');
            },
          ),
        ],
      ),
    );
  }
}