import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samaki_clinic/BackEnd/Screens/AppointmentListScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Consultation_ListScreen.dart';
import 'package:samaki_clinic/BackEnd/Screens/CustomerList_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Invoice_list_Screen.dart';
import 'package:samaki_clinic/BackEnd/Screens/Product_Screen.dart';
import 'package:samaki_clinic/BackEnd/logic/CustomerList_provider.dart';



class DashboardPage extends StatefulWidget {
  final int initialIndex;
  const DashboardPage({super.key, this.initialIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  final List<String> _titles = [
    'Dashboard',
    'Appointment List',
    'Consultation List',
    'Invoice List',
    'Customer List',
    'Product List',
    
  ];

  final List<Widget> _pages = [
    _buildDashboardContent(),
    const AppointmentListScreen(),
    const ConsultationScreen(),
    const InvoiceScreen(),
    ChangeNotifierProvider(
      create: (_) => CustomerProvider(),
      child: const CustomerListViewScreen(),
    ),
    const ProductListView(),
   
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  static Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatCard('Appointments', '12', Icons.calendar_today, Colors.lightBlue),
            SizedBox(width: 12),
            _buildStatCard('Consultations', '5', Icons.healing, Colors.blueAccent),
            SizedBox(width: 12),
            _buildStatCard('New Customers', '3', Icons.group_add, Colors.blue[400]!),
            SizedBox(width: 12),
            _buildStatCard('Revenue', '\$2,450', Icons.attach_money, Colors.indigo),
          ],
        ),
        SizedBox(height: 24),
        Text("Today's Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1976D2))),
        SizedBox(height: 12),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 26),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  static Widget _buildActivityItem(String time, String title, IconData icon, Color iconColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.15), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF2C3E50))),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
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

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Color(0xFF1976D2),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        children: [
          SizedBox(height: 20),
          Image.asset('assets/Samaki_logo.png', height: 40),
          SizedBox(height: 10),
          Text('Samaki Clinic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 24),
          _buildNavItem(Icons.dashboard, 'Dashboard', 0),
          _buildNavItem(Icons.calendar_month, 'Appointment List', 1),
          _buildNavItem(Icons.healing, 'Consultation List', 2),
          _buildNavItem(Icons.receipt, 'Invoice List', 3),
          _buildNavItem(Icons.people, 'Customer List', 4),
          _buildNavItem(Icons.shopping_bag, 'Product List', 5),
          // _buildNavItem(Icons.person, 'Profile', 6),
          Spacer(),
          Divider(color: Colors.white24),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              children: [
                SizedBox(width: 12),
                Icon(Icons.person, color: Colors.white, size: 16),
                SizedBox(width: 6),
               
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
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Text(_titles[_selectedIndex], 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
          Spacer(),
          Container(
            width: 200,
            height: 34,
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Color(0xFFF1F4F8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.blueGrey[100]!),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.blueGrey[400], size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[400]),
                    ),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          _buildNotificationButton(),
          SizedBox(width: 12),
          CircleAvatar(
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
            color: Color(0xFFF1F4F8),
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
            decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}