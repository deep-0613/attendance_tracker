import 'package:flutter/material.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({Key? key}) : super(key: key);

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Timetable Screen'),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Third Year, CO',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Term - Even, Sem VI',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          
          // Timetable Grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    // Header Row
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildHeaderCell('Day', 50),
                          _buildHeaderCell('10:30-11:30', 80),
                          _buildHeaderCell('11:30-12:30', 80),
                          _buildHeaderCell('12:30-1:15', 70),
                          _buildHeaderCell('1:15-2:15', 80),
                          _buildHeaderCell('2:15-3:15', 80),
                          _buildHeaderCell('3:30-4:30', 80),
                          _buildHeaderCell('4:30-5:30', 80),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Monday Row
                    _buildDayRow('MON', [
                      {'subject': 'IP', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'SE', 'faculty': 'VSG', 'room': '209'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'LAN', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'LAN', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'IP', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'SE', 'faculty': 'VSG', 'room': '209'},
                    ]),
                    
                    // Tuesday Row
                    _buildDayRow('TUE', [
                      {'subject': 'CC Lab', 'faculty': 'PRA', 'room': '404'},
                      {'subject': 'LAN Lab', 'faculty': 'NRK', 'room': '404'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'SE Lab', 'faculty': 'VSG', 'room': '404'},
                      {'subject': 'IP', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'SE', 'faculty': 'VSG', 'room': '209'},
                      {'subject': 'LAN', 'faculty': 'NRK', 'room': '207'},
                    ]),
                    
                    // Wednesday Row
                    _buildDayRow('WED', [
                      {'subject': 'SE', 'faculty': 'VSG', 'room': '209'},
                      {'subject': 'IP', 'faculty': 'NRK', 'room': '207'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'LAN', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'LAN', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'IP', 'faculty': 'NRK', 'room': '207'},
                      {'subject': 'SE', 'faculty': 'VSG', 'room': '209'},
                    ]),
                    
                    // Thursday Row
                    _buildDayRow('THU', [
                      {'subject': 'SE Lab', 'faculty': 'VSG', 'room': '404'},
                      {'subject': 'CC Lab', 'faculty': 'PRA', 'room': '404'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'LAN Lab', 'faculty': 'NRK', 'room': '404'},
                      {'subject': 'SE Lab', 'faculty': 'VSG', 'room': '404'},
                      {'subject': 'CC Lab', 'faculty': 'PRA', 'room': '404'},
                      {'subject': 'LAN Lab', 'faculty': 'NRK', 'room': '404'},
                    ]),
                    
                    // Friday Row
                    _buildDayRow('FRI', [
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                    ]),
                    
                    // Saturday Row
                    _buildDayRow('SAT', [
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': '', 'faculty': '', 'room': ''},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                      {'subject': 'Project', 'faculty': 'All', 'room': 'Lab'},
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE53935),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade300)),
        color: Colors.grey.shade100,
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDayRow(String day, List<Map<String, String>> subjects) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Day cell
          Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey.shade50,
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          
          // Subject cells
          for (int i = 0; i < subjects.length; i++)
            Container(
              width: i == 2 ? 70 : 80, // Lunch break column is narrower
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                color: i == 2 ? Colors.orange.shade50 : Colors.white, // Lunch break color
              ),
              child: i == 2
                  ? Text(
                      'LUNCH\nBREAK',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : subjects[i]['subject']!.isNotEmpty
                      ? GestureDetector(
                          onTap: () => _showSubjectModal(subjects[i]['subject']!),
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              final isMondayIP = day == 'MON' && i == 0 && subjects[i]['subject'] == 'IP';
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isMondayIP 
                                      ? Colors.red.withOpacity(0.3 + (_animation.value * 0.7))
                                      : Colors.white,
                                  border: isMondayIP 
                                      ? Border.all(color: Colors.red.withOpacity(_animation.value), width: 2)
                                      : Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      subjects[i]['subject']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isMondayIP ? Colors.red.shade800 : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      subjects[i]['faculty']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: isMondayIP ? Colors.red.shade600 : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      subjects[i]['room']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: isMondayIP ? Colors.red.shade600 : Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'IP':
        return const Color(0xFF4CAF50); // Green
      case 'SE':
        return const Color(0xFF2196F3); // Blue
      case 'LAN':
        return const Color(0xFF9C27B0); // Purple
      case 'CC Lab':
        return const Color(0xFFFF9800); // Orange
      case 'LAN Lab':
        return const Color(0xFF795548); // Brown
      case 'SE Lab':
        return const Color(0xFFF44336); // Red
      case 'Project':
        return const Color(0xFF607D8B); // Blue Grey
      default:
        return Colors.grey;
    }
  }

  void _showSubjectModal(String subject) {
    String courseName = '';
    String code = '';
    String faculty = '';
    
    switch (subject) {
      case 'IP':
        courseName = 'Image Processing';
        code = '023RC22';
        faculty = 'Manjiri Samant';
        break;
      case 'SE':
        courseName = 'Software Engineering';
        code = '023RC23';
        faculty = 'VSG';
        break;
      case 'LAN':
        courseName = 'Local Area Networks';
        code = '023RC24';
        faculty = 'NRK';
        break;
      case 'CC Lab':
        courseName = 'Cloud Computing Lab';
        code = '023RC25';
        faculty = 'PRA';
        break;
      case 'LAN Lab':
        courseName = 'LAN Lab';
        code = '023RC26';
        faculty = 'NRK';
        break;
      case 'SE Lab':
        courseName = 'Software Engineering Lab';
        code = '023RC27';
        faculty = 'VSG';
        break;
      case 'Project':
        courseName = 'Project Work';
        code = '023RC28';
        faculty = 'All Faculty';
        break;
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Course Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalRow('Course', courseName),
                const SizedBox(height: 12),
                _buildModalRow('Code', code),
                const SizedBox(height: 12),
                _buildModalRow('Faculty', faculty),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
