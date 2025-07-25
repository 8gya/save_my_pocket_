// lib/screens/detail_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// Detailed view for transactions and financial analytics
class DetailScreen extends StatefulWidget {
  final String title;
  final dynamic data;

  const DetailScreen({Key? key, required this.title, this.data})
    : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock data for charts and analytics
  List<Map<String, dynamic>> _expenseCategories = [];
  List<Map<String, dynamic>> _monthlyData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load mock data for demonstration
  void _loadMockData() {
    _expenseCategories = [
      {'category': 'Food', 'amount': 450.0, 'color': Colors.orange},
      {'category': 'Transport', 'amount': 200.0, 'color': Colors.blue},
      {'category': 'Shopping', 'amount': 300.0, 'color': Colors.purple},
      {'category': 'Bills', 'amount': 500.0, 'color': Colors.red},
      {'category': 'Entertainment', 'amount': 150.0, 'color': Colors.green},
    ];

    _monthlyData = [
      {'month': 'Jan', 'income': 3500.0, 'expense': 2800.0},
      {'month': 'Feb', 'income': 3500.0, 'expense': 2600.0},
      {'month': 'Mar', 'income': 3700.0, 'expense': 2900.0},
      {'month': 'Apr', 'income': 3500.0, 'expense': 2750.0},
      {'month': 'May', 'income': 3800.0, 'expense': 3000.0},
      {'month': 'Jun', 'income': 3500.0, 'expense': 2650.0},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: Theme.of(context).primaryColor,
              tabs: [
                Tab(text: 'Transactions'),
                Tab(text: 'Analytics'),
                Tab(text: 'Categories'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsTab(),
                _buildAnalyticsTab(),
                _buildCategoriesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build app bar with back navigation
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        widget.title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => AppRoutes.navigateBack(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
        ),
      ],
    );
  }

  /// Build transactions tab
  Widget _buildTransactionsTab() {
    final transactions = widget.data as List<Map<String, dynamic>>? ?? [];

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  '+\$3,500.00',
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  '-\$1,200.00',
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Section title
          Text(
            'All Transactions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(transactions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build analytics tab with charts
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly trend chart
          _buildChartCard(
            'Monthly Trends',
            'Income vs Expenses over time',
            _buildLineChart(),
          ),
          SizedBox(height: 20),

          // Expense breakdown
          _buildChartCard(
            'Expense Breakdown',
            'Spending by category',
            _buildPieChart(),
          ),
          SizedBox(height: 20),

          // Financial insights
          _buildInsightsCard(),
        ],
      ),
    );
  }

  /// Build categories tab
  Widget _buildCategoriesTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add category button
          CustomButton(
            text: 'Add New Category',
            icon: Icons.add,
            onPressed: _showAddCategoryDialog,
            height: 45,
          ),
          SizedBox(height: 20),

          // Categories list
          Text(
            'Expense Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              itemCount: _expenseCategories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(_expenseCategories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary card widget
  Widget _buildSummaryCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Build transaction card
  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final isIncome = transaction['amount'] > 0;
    final date = transaction['date'] as DateTime;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              transaction['icon'],
              color: isIncome ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          SizedBox(width: 12),

          // Transaction details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['title'],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction['category'],
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    SizedBox(width: 8),
                    Text('•', style: TextStyle(color: Colors.grey[400])),
                    SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd').format(date),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isIncome ? '+' : ''}\$${transaction['amount'].abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  /// Build chart card container
  Widget _buildChartCard(String title, String subtitle, Widget chart) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 20),
          SizedBox(height: 200, child: chart),
        ],
      ),
    );
  }

  /// Build line chart for monthly trends
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _monthlyData.length) {
                  final monthValue = _monthlyData[index]['month'];
                  return Text(
                    monthValue is String ? monthValue : '',
                    style: TextStyle(fontSize: 12),
                  );
                }
                return Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Income line
          LineChartBarData(
            spots: _monthlyData.asMap().entries.map((entry) {
              final incomeValue = entry.value['income'];
              return FlSpot(
                entry.key.toDouble(),
                incomeValue is num ? incomeValue.toDouble() : 0.0,
              );
            }).toList(),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          // Expense line
          LineChartBarData(
            spots: _monthlyData.asMap().entries.map((entry) {
              final expenseValue = entry.value['expense'];
              return FlSpot(
                entry.key.toDouble(),
                expenseValue is num ? expenseValue.toDouble() : 0.0,
              );
            }).toList(),
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }

  /// Build pie chart for expense categories
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: _expenseCategories.map((category) {
          return PieChartSectionData(
            value: category['amount'],
            title: '${((category['amount'] / 1600) * 100).toInt()}%',
            color: category['color'],
            radius: 60,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  /// Build category card
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: category['color'],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              category['category'],
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '\$${category['amount'].toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Build insights card
  Widget _buildInsightsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),
          _buildInsightItem(
            Icons.trending_up,
            'Your expenses decreased by 8% this month',
            Colors.green,
          ),
          SizedBox(height: 12),
          _buildInsightItem(
            Icons.warning,
            'Food spending is 15% above average',
            Colors.orange,
          ),
          SizedBox(height: 12),
          _buildInsightItem(
            Icons.check_circle,
            'You\'re on track to meet your savings goal',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  /// Build insight item
  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start adding your income and expenses',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Options'),
        content: Text('Filter functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Show add category dialog
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Category'),
        content: Text('Add category functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}
