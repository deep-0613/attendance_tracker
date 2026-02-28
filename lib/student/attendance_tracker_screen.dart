import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceTrackerScreen extends StatefulWidget {
  const AttendanceTrackerScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceTrackerScreen> createState() => _AttendanceTrackerScreenState();
}

class _AttendanceTrackerScreenState extends State<AttendanceTrackerScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;

  Map<String, dynamic>? _attendanceData;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    try {
      // Get current user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      
      if (userId.isNotEmpty) {
        // Load attendance data
        final attendanceJson = await rootBundle.loadString('assets/json/attendance_percentage.json');
        final attendanceMap = json.decode(attendanceJson);;
        
        if (attendanceMap.containsKey(userId)) {
          setState(() {
            _attendanceData = attendanceMap[userId];
            
            // Update tab controller after data is loaded
            final subjectCount = _attendanceData?['subjects']?.keys.length ?? 0;
            _tabController?.dispose();
            _tabController = TabController(length: subjectCount, vsync: this);
          });
        }
      }
    } catch (e) {
      print('Error loading attendance data: $e');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  double get _overallPercentage {
    if (_attendanceData == null) return 0.0;
    
    // Use the overallPercentage field from JSON instead of calculating
    return _attendanceData!['overallPercentage']?.toDouble() ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F6),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color(0xFFA50C22),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Attendance Tracker',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Overall Percentage Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                // Percentage Circle on left
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 6,
                          ),
                        ),
                      ),
                      
                      // Progress circle
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _overallPercentage / 100,
                          strokeWidth: 6,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getPercentageColor(_overallPercentage),
                          ),
                        ),
                      ),
                      
                      // Percentage text
                      Center(
                        child: Text(
                          '${_overallPercentage.toStringAsFixed(1)}%',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Text on right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Attendance Percentage',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'for this Semester',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Quick stats
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Subject Tabs
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
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
                  // Tab Bar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: const Color(0xFFA50C22),
                    unselectedLabelColor: const Color(0xFF6B7280),
                    indicatorColor: const Color(0xFFA50C22),
                    indicatorWeight: 3,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: _attendanceData == null
                        ? [const Tab(text: 'Loading...')]
                        : (_attendanceData!['subjects'] as Map<String, dynamic>)
                            .keys
                            .map((subject) {
                              return Tab(
                                text: subject.length > 10 
                                    ? subject.substring(0, 10) + '...'
                                    : subject,
                              );
                            })
                            .toList(),
                  ),
                  
                  // Tab Content
                  Expanded(
                    child: _attendanceData == null
                        ? const Center(child: CircularProgressIndicator())
                        : TabBarView(
                            controller: _tabController,
                            children: (_attendanceData!['subjects'] as Map<String, dynamic>)
                                .entries
                                .map((entry) => _buildSubjectTab(entry.key, entry.value))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTab(String subjectName, Map<String, dynamic> subjectData) {
    final totalLectures = subjectData['totalLectures'] as int;
    final attendedLectures = subjectData['attendedLectures'] as int;
    final percentage = subjectData['percentage'] as double;
    final colorString = subjectData['color'] as String;
    final color = _parseColor(colorString);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject Header
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    subjectName.length > 15 ? subjectName.substring(0, 15) + '...' : subjectName,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _getPercentageColor(percentage),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Attendance Stats - More Compact
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  'Total',
                  totalLectures.toString(),
                  Icons.calendar_today_outlined,
                  const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  'Attended',
                  attendedLectures.toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  'Missed',
                  (totalLectures - attendedLectures).toString(),
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Attendance Progress',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getPercentageColor(percentage),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 6),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$attendedLectures/$totalLectures',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    '${totalLectures - attendedLectures} missed',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Recent Attendance - Compact
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Attendance',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Sample recent attendance records - More compact
                _buildCompactAttendanceRecord('2024-02-28', '10:30', 'Present', Colors.green),
                _buildCompactAttendanceRecord('2024-02-27', '2:00', 'Present', Colors.green),
                _buildCompactAttendanceRecord('2024-02-26', '9:00', 'Absent', Colors.red),
                _buildCompactAttendanceRecord('2024-02-25', '11:30', 'Present', Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAttendanceRecord(String date, String time, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$date • $time',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 9,
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      // Remove # if present and convert to hex
      final hexColor = colorString.replaceAll('#', '');
      return Color(int.parse('0xFF$hexColor'));
    } catch (e) {
      // Fallback colors if parsing fails
      switch (colorString) {
        case '#10B981':
          return Colors.green;
        case '#3B82F6':
          return Colors.blue;
        case '#8B5CF6':
          return Colors.purple;
        case '#F59E0B':
          return Colors.orange;
        case '#06B6D4':
          return Colors.teal;
        case '#EF4444':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 80) return Colors.blue;
    if (percentage >= 70) return Colors.orange;
    return Colors.red;
  }
}
