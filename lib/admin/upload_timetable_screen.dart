import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'assign_subjects_screen.dart';

class UploadTimetableScreen extends StatefulWidget {
  const UploadTimetableScreen({Key? key}) : super(key: key);

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  String _selectedBatch = '';
  List<Map<String, String>> _assignments = [];

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    final prefs = await SharedPreferences.getInstance();
    final assignmentsJson = prefs.getString('assignments_${_selectedBatch}');
    if (assignmentsJson != null && assignmentsJson.isNotEmpty) {
      // Parse assignments JSON if needed (for now, we'll track count)
      setState(() {
        // For simplicity, we'll just track if assignments exist
        // In a real implementation, you'd parse the JSON properly
      });
    }
  }

  Future<void> _saveAssignmentsCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('assignments_count_${_selectedBatch}', count);
  }

  Future<int> _getAssignmentsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('assignments_count_${_selectedBatch}') ?? 0;
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

  Widget _buildTab({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _selectBatch(title);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? color : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectBatch(String batch) {
    setState(() {
      _selectedBatch = batch;
    });
    _showSuccessSnackBar('$batch selected');
    _loadAssignments();
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
          'Upload Timetable',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header
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
                        Icons.calendar_month,
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
                            'Select Batch',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Choose a batch for timetable upload',
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
          
          // Horizontal Tabs
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                // Tab Headers
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                  ),
                  child: Row(
                    children: [
                      _buildTab(
                        title: 'FYCO',
                        icon: Icons.school,
                        color: const Color(0xFF3B82F6),
                        isSelected: _selectedBatch == 'FYCO',
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        title: 'SYCO',
                        icon: Icons.engineering,
                        color: const Color(0xFF10B981),
                        isSelected: _selectedBatch == 'SYCO',
                      ),
                      const SizedBox(width: 8),
                      _buildTab(
                        title: 'TYCO',
                        icon: Icons.workspace_premium,
                        color: const Color(0xFF8B5CF6),
                        isSelected: _selectedBatch == 'TYCO',
                      ),
                    ],
                  ),
                ),
                
                // Selected Batch Display
                if (_selectedBatch.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          _getBatchIcon(_selectedBatch),
                          size: 64,
                          color: _getBatchColor(_selectedBatch),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$_selectedBatch Selected',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _getBatchColor(_selectedBatch),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ready for timetable upload',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => AssignSubjectsScreen(batch: _selectedBatch)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA50C22),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Assign Subjects to Faculty',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Create Timetable Button
                        FutureBuilder<int>(
                          future: _getAssignmentsCount(),
                          builder: (context, snapshot) {
                            final assignmentsCount = snapshot.data ?? 0;
                            if (assignmentsCount > 0) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _showSuccessSnackBar('Creating timetable for $_selectedBatch with $assignmentsCount assignments!');
                                    // TODO: Implement timetable creation logic
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Create Timetable',
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getBatchIcon(String batch) {
    switch (batch) {
      case 'FYCO':
        return Icons.school;
      case 'SYCO':
        return Icons.engineering;
      case 'TYCO':
        return Icons.workspace_premium;
      default:
        return Icons.calendar_today;
    }
  }

  Color _getBatchColor(String batch) {
    switch (batch) {
      case 'FYCO':
        return const Color(0xFF3B82F6);
      case 'SYCO':
        return const Color(0xFF10B981);
      case 'TYCO':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}
