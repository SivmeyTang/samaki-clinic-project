// dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Screens/AppointmentListScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Consultation_ListScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/CustomerList_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Product_Screen.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';

class DashboardPage extends StatefulWidget {
  // --- MODIFIED ---
  // Added optional initialIndex to determine which page to show first.
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  // --- ADDED ---
  // Use the initialIndex from the widget to set the selected index.
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  final List<String> _titles = [
    'Dashboard',
    'Appointment List',
    'Consultation List',
    'Invoice List',
    'Customer List',
    'Product List',
    'AP',
  ];

  // Your _pages list remains the same. Just ensure ConsultationScreen is at index 2.
  final List<Widget> _pages = [
    _buildDashboardContent(), // 0
    const AppointmentListScreen(), // 1
    const ConsultationScreen(), // 2
    //const CreateAppointmentScreen(), // 3
    ChangeNotifierProvider(
      create: (_) => CustomerProvider(), // 4
      child: const CustomerListViewScreen(),
    ),
    const ProductListView(), // 5
  ];

  static Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(title,
          style: TextStyle(fontSize: 18, color: Colors.blueGrey[600])),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _pages[_selectedIndex],
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

  // --- ALL YOUR OTHER WIDGETS (_buildDashboardContent, _buildSidebar, etc.) ---
  // --- REMAIN EXACTLY THE SAME. NO CHANGES NEEDED BELOW THIS LINE. ---

  static Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatCard('Appointments', '12', Icons.calendar_today, Colors.lightBlue),
            const SizedBox(width: 12),
            _buildStatCard('Consultations', '5', Icons.healing, Colors.blueAccent),
            const SizedBox(width: 12),
            _buildStatCard('New Customers', '3', Icons.group_add, Colors.blue[400]!),
            const SizedBox(width: 12),
            _buildStatCard('Revenue', '\$2,450', Icons.attach_money, Colors.indigo),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Today\'s Activity',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1976D2)),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              _buildActivityItem('10:30 AM', 'New appointment booked', Icons.calendar_month, Colors.blue[300]!),
              _buildActivityItem('11:45 AM', 'Consultation completed', Icons.check_circle, Colors.lightBlueAccent),
              _buildActivityItem('1:15 PM', 'Invoice sent', Icons.receipt, Colors.blue[400]!),
              _buildActivityItem('2:30 PM', 'New customer registered', Icons.person_add, Colors.blueAccent[100]!),
              _buildActivityItem('3:45 PM', 'Prescription created', Icons.medication, Colors.blue[500]!),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityItem(String time, String title, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/Samaki_logo.png', height: 40),
          const SizedBox(height: 10),
          const Text('Samaki Clinic',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 24),
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.calendar_month, 'Appointment List', 1),
          _buildNavItem(Icons.healing, 'Consultation List', 2),
          _buildNavItem(Icons.receipt, 'Invoice List', 3),
          _buildNavItem(Icons.people, 'Customer List', 4),
          _buildNavItem(Icons.shopping_bag, 'Product List', 5),
          const Spacer(),
          const Divider(color: Colors.white24),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.person, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text('Dr. Veterinarian',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool selected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Text(_titles[_selectedIndex],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
          const Spacer(),
          Container(
            width: 200,
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.blueGrey[400], size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[400]),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildNotificationButton(),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1976D2),
            child: Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F4F8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blueGrey[100]!),
          ),
          child: Icon(Icons.notifications_none, size: 18, color: Colors.blueGrey[400]),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}