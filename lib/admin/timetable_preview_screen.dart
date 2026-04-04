import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimetablePreviewScreen extends StatelessWidget {
  final String batch;
  final List<Map<String, dynamic>> timetable;

  const TimetablePreviewScreen({
    Key? key,
    required this.batch,
    required this.timetable,
  }) : super(key: key);

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
          '$batch Timetable Preview',
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
            margin: const EdgeInsets.all(16),
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
            child: Row(
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
                        '$batch Schedule',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${timetable.length} entries loaded from API',
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
          ),
          
          // Timetable Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: timetable.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 64,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No timetable data available',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll<Color>(const Color(0xFFF1F3F6)),
                        dataRowColor: WidgetStateProperty.resolveWith<Color>((states) {
                          if (states.contains(WidgetState.selected)) {
                            return const Color(0xFFE0F2FE).withValues(alpha: 0.1);
                          }
                          return Colors.transparent;
                        }),
                        columns: [
                          DataColumn(
                            label: _buildTableHeader('Course Code'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Course Name'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Day'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Time'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Room'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Faculty'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Type'),
                          ),
                          DataColumn(
                            label: _buildTableHeader('Lab Batch'),
                          ),
                        ],
                        rows: timetable.map((entry) {
                          final isLab = entry['session_type'] == 'LAB';
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  entry['course_code'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isLab ? const Color(0xFFA50C22) : const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  entry['course_name'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  entry['day_of_week'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  '${entry['start_time']?.substring(0, 5) ?? 'N/A'} - ${entry['end_time']?.substring(0, 5) ?? 'N/A'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  entry['room_number'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  entry['faculty_id'] ?? 'N/A',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isLab 
                                        ? const Color(0xFFFCE4EC)
                                        : entry['session_type'] == 'PROJECT'
                                            ? const Color(0xFFF0FDF4)
                                            : const Color(0xFFF0F9FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    entry['session_type'] ?? 'N/A',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isLab 
                                          ? const Color(0xFFA50C22)
                                          : entry['session_type'] == 'PROJECT'
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF3B82F6),
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                entry['lab_batch'] != null
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFA50C22),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Batch ${entry['lab_batch']}',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        '-',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildTimetableEntry(Map<String, dynamic> entry) {
    final isLab = entry['session_type'] == 'LAB';
    final isProject = entry['session_type'] == 'PROJECT';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isLab 
            ? const Color(0xFFFCE4EC)
            : isProject 
                ? const Color(0xFFF0FDF4)
                : const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isLab 
              ? const Color(0xFFA50C22)
              : isProject 
                  ? const Color(0xFF10B981)
                  : const Color(0xFF3B82F6),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with course info
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLab 
                      ? const Color(0xFFA50C22)
                      : isProject 
                          ? const Color(0xFF10B981)
                          : const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isLab ? Icons.science : isProject ? Icons.assignment : Icons.book,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['course_code'] ?? 'N/A',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLab 
                            ? const Color(0xFFA50C22)
                            : isProject 
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                      ),
                    ),
                    Text(
                      entry['course_name'] ?? 'N/A',
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
          
          const SizedBox(height: 12),
          
          // Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Day',
                  entry['day_of_week'] ?? 'N/A',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Time',
                  '${entry['start_time']?.substring(0, 5) ?? 'N/A'} - ${entry['end_time']?.substring(0, 5) ?? 'N/A'}',
                  Icons.access_time,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Room',
                  entry['room_number'] ?? 'N/A',
                  Icons.room,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Faculty',
                  entry['faculty_id'] ?? 'N/A',
                  Icons.person,
                ),
              ),
            ],
          ),
          
          // Lab batch if applicable
          if (isLab && entry['lab_batch'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA50C22),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Batch ${entry['lab_batch']}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF6B7280),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
