import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'assign_subjects_screen.dart';
import 'timetable_preview_screen.dart';

class UploadTimetableScreen extends StatefulWidget {
  const UploadTimetableScreen({Key? key}) : super(key: key);

  @override
  State<UploadTimetableScreen> createState() => _UploadTimetableScreenState();
}

class _UploadTimetableScreenState extends State<UploadTimetableScreen> {
  String _selectedBatch = '';
  bool _isLoading = false;
  bool _showGenerateButton = false;
  bool _showPreviewButton = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
  }

  // View timetable for specific batch
  void _viewBatchTimetable(String batch) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timetablesJson = prefs.getString('generated_timetables');
      
      if (timetablesJson != null && timetablesJson.isNotEmpty) {
        final allTimetables = jsonDecode(timetablesJson) as List;
        final batchTimetables = allTimetables.where((tt) => tt['batch'] == batch).toList();
        
        if (batchTimetables.isNotEmpty) {
          final List<Map<String, dynamic>> typedTimetables = batchTimetables.map((tt) => Map<String, dynamic>.from(tt)).toList();
          _showTimetableDialog(batch, typedTimetables);
        } else {
          _showErrorSnackBar('No timetable found for $batch');
        }
      } else {
        _showErrorSnackBar('No timetables generated yet');
      }
    } catch (e) {
      _showErrorSnackBar('Error loading timetable: $e');
    }
  }

  // Show timetable dialog - now navigates to new screen
  void _showTimetableDialog(String batch, List<Map<String, dynamic>> timetables) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetablePreviewScreen(batch: batch, timetable: timetables),
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

  Future<void> _loadAssignments() async {
    // Simple load method - not used in current implementation
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
            color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
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
      _showGenerateButton = true;
      _showPreviewButton = false;
    });
    _showSuccessSnackBar('$batch selected');
  }

  // Fetch timetable from API
  Future<List<Map<String, dynamic>>> _fetchTimetableFromAPI(String batch) async {
    try {
      final response = await http.get(
        Uri.parse('http://13.235.16.3:5001/timetable?batch=$batch'),
      );
      
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        print('DEBUG: API Response type: ${data.runtimeType}');
        print('DEBUG: API Response data: $data');
        
        // Handle API response format: {count: X, data: [entries]}
        List<dynamic> timetableList;
        if (data is Map && data.containsKey('data')) {
          timetableList = data['data'] as List<dynamic>;
          print('DEBUG: Response has count and data fields with ${timetableList.length} entries');
        } else if (data is List) {
          timetableList = data;
          print('DEBUG: Response is a direct List with ${data.length} items');
        } else if (data is Map) {
          // If it's a single object, wrap it in a list
          timetableList = [data];
          print('DEBUG: Response is a Map, wrapping in list');
        } else {
          throw Exception('Invalid response format: ${data.runtimeType}');
        }
        
        return timetableList.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Failed to load timetable: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: API Error: $e');
      throw Exception('Error fetching timetable: $e');
    }
  }

  // Generate timetable with 2-second buffer
  Future<void> _generateTimetable() async {
    setState(() {
      _isGenerating = true;
    });
    
    // Show 2-second buffer
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      _isGenerating = false;
      _showGenerateButton = false;
      _showPreviewButton = true;
    });
    
    _showSuccessSnackBar('Timetable generated successfully!');
  }

  // Preview timetable
  Future<void> _previewTimetable() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final timetable = await _fetchTimetableFromAPI(_selectedBatch);
      setState(() {
        _isLoading = false;
      });
      
      _showTimetablePreview(_selectedBatch, timetable);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load timetable: $e');
    }
  }

  // Show timetable preview screen
  void _showTimetablePreview(String batch, List<Map<String, dynamic>> timetable) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimetablePreviewScreen(
          batch: batch,
          timetable: timetable,
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
                  color: Colors.black.withValues(alpha: 0.05),
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
                        
                        // Generate Timetable Button
                        if (_showGenerateButton)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isGenerating ? null : _generateTimetable,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isGenerating
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Generating...',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Generate Timetable',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        
                        // Preview Timetable Button
                        if (_showPreviewButton)
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _previewTimetable,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Loading...',
                                              style: GoogleFonts.inter(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Preview $_selectedBatch Timetable',
                                          style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        
                        // Information Message
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF0EA5E9)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Color(0xFF0EA5E9)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Timetables are now generated individually from the Assign Subjects screen for each batch',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF0C4A6E),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
