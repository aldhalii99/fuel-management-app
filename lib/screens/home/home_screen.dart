import 'package:flutter/material.dart';
import '../../db/database_helper.dart';
import '../fuel/fuel_screen.dart';
import '../stations/stations_screen.dart';
import '../operations/operations_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';
import '../web_test_screen.dart';  // ← أضف هذا الاستيراد

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, Map<String, dynamic>> _fuelSummary = {};
  int _totalOperations = 0;
  double _totalQuantity = 0;

  // قائمة الشاشات - أضف WebTestScreen
  final List<Widget> _screens = [
    Container(), // سيتم استبداله بـ HomeDashboard
    const OperationsScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
    const WebTestScreen(), // ← أضف هذا
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final dbHelper = DatabaseHelper.instance;
      final operations = await dbHelper.getAllOperations();

      // حساب الإحصائيات
      final Map<String, Map<String, dynamic>> summary = {
        'ديزل': {'منصرف': 0.0, 'غير منصرف': 0.0, 'color': Colors.orange},
        'بترول': {'منصرف': 0.0, 'غير منصرف': 0.0, 'color': Colors.red},
      };

      double totalQty = 0;

      for (var op in operations) {
        String fuelName = op['fuel_name'] ?? '';
        String status = op['status'] ?? 'غير منصرف';
        double quantity = (op['quantity'] ?? 0).toDouble();

        if (summary.containsKey(fuelName)) {
          summary[fuelName]![status] =
              (summary[fuelName]![status] ?? 0) + quantity;
        }

        totalQty += quantity;
      }

      setState(() {
        _fuelSummary = summary;
        _totalOperations = operations.length;
        _totalQuantity = totalQty;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام ادارة المحروقات'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _currentIndex == 0
          ? _buildHomeDashboard()
          : _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 20),
            _buildStatsSection(),
            const SizedBox(height: 20),
            _buildFuelSummarySection(),
            const SizedBox(height: 20),
            _buildQuickActions(),
            const SizedBox(height: 20),
            _buildWebTestSection(), // ← أضف هذا الجزء
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.local_gas_station, size: 60, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'مرحباً بك في نظام إدارة الوقود',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'التاريخ: ${DateTime.now().toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _statCard(
          title: 'إجمالي العمليات',
          value: _totalOperations.toString(),
          icon: Icons.receipt_long,
          color: Colors.blue,
        ),
        _statCard(
          title: 'الكمية الإجمالية',
          value: '${_totalQuantity.toStringAsFixed(1)} لتر',
          icon: Icons.local_gas_station,
          color: Colors.green,
        ),
        _statCard(
          title: 'عدد أنواع الوقود',
          value: _fuelSummary.length.toString(),
          icon: Icons.category,
          color: Colors.orange,
        ),
        _statCard(
          title: 'آخر تحديث',
          value: 'الآن',
          icon: Icons.update,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFuelSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ملخص الوقود',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._fuelSummary.entries.map((entry) => _fuelSummaryCard(entry.key, entry.value)),
      ],
    );
  }

  Widget _fuelSummaryCard(String fuelName, Map<String, dynamic> data) {
    double dispensed = (data['منصرف'] ?? 0).toDouble();
    double notDispensed = (data['غير منصرف'] ?? 0).toDouble();
    double total = dispensed + notDispensed;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.local_gas_station, color: data['color']),
                    const SizedBox(width: 8),
                    Text(
                      fuelName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${total.toStringAsFixed(1)} لتر',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _statusIndicator(
                    'منصرف',
                    dispensed,
                    total > 0 ? (dispensed / total * 100) : 0,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _statusIndicator(
                    'غير منصرف',
                    notDispensed,
                    total > 0 ? (notDispensed / total * 100) : 0,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusIndicator(String title, double value, double percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} لتر (${percentage.toStringAsFixed(0)}%)',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوظائف السريعة',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _quickActionButton(
              'إضافة عملية',
              Icons.add_circle,
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OperationsScreen()),
                );
              },
            ),
            _quickActionButton(
              'التقارير',
              Icons.analytics,
              Colors.green,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                );
              },
            ),
            _quickActionButton(
              'إدارة الوقود',
              Icons.local_gas_station,
              Colors.orange,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FuelScreen()),
                );
              },
            ),
            _quickActionButton(
              'المحطات',
              Icons.store,
              Colors.purple,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StationsScreen()),
                );
              },
            ),
            // يمكنك إضافة زر اختبار ويب هنا أيضاً
            _quickActionButton(
              'اختبار اتصال ويب',
              Icons.wifi,
              Colors.blue,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WebTestScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // أضف هذه الدالة الجديدة
  Widget _buildWebTestSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'اختبار اتصال الويب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'اختبر اتصال التطبيق بخادم الويب على الاستضافة',
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 4; // الانتقال لشاشة اختبار الويب
              });
            },
            icon: const Icon(Icons.wifi_find),
            label: const Text('بدء اختبار الاتصال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.list_alt),
          label: 'العمليات',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart),
          label: 'التقارير',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'الإعدادات',
        ),
        BottomNavigationBarItem(  // ← هذا هو العنصر الجديد
          icon: Icon(Icons.cloud),
          label: 'اختبار ويب',
        ),
      ],
    );
  }
}