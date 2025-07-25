// lib/screens/budget_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/user.dart' as models;
import '../services/local_db_service.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// Budget management and tracking screen
class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // State variables
  List<models.BudgetCategory> _budgetCategories = [];
  Map<String, double> _currentSpending = {};
  bool _isLoading = true;
  String _selectedPeriod = 'This Month';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBudgetData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load budget categories and spending data
  Future<void> _loadBudgetData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load budget categories from database
      _budgetCategories = await LocalDbService.getBudgetCategories();

      // Load current spending by category
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      _currentSpending = await LocalDbService.getSpendingByCategory(
        startDate: startOfMonth,
        endDate: endOfMonth,
      );

      // If no budget categories exist, create default ones
      if (_budgetCategories.isEmpty) {
        await _createDefaultBudgets();
        _budgetCategories = await LocalDbService.getBudgetCategories();
      }
    } catch (e) {
      print('Error loading budget data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Create default budget categories
  Future<void> _createDefaultBudgets() async {
    final defaultBudgets = [
      models.BudgetCategory(
        id: 'food_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Food & Dining',
        budgetAmount: 500.0,
        spentAmount: 0.0,
        color: 'orange',
        icon: 'restaurant',
      ),
      models.BudgetCategory(
        id: 'transport_${DateTime.now().millisecondsSinceEpoch + 1}',
        name: 'Transportation',
        budgetAmount: 200.0,
        spentAmount: 0.0,
        color: 'blue',
        icon: 'directions_car',
      ),
      models.BudgetCategory(
        id: 'shopping_${DateTime.now().millisecondsSinceEpoch + 2}',
        name: 'Shopping',
        budgetAmount: 300.0,
        spentAmount: 0.0,
        color: 'purple',
        icon: 'shopping_bag',
      ),
    ];

    for (var budget in defaultBudgets) {
      await LocalDbService.insertBudgetCategory(budget);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
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
                      Tab(text: 'Overview'),
                      Tab(text: 'Categories'),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [_buildOverviewTab(), _buildCategoriesTab()],
                  ),
                ),
              ],
            ),
    );
  }

  /// Build app bar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Budget Tracker',
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
          icon: Icon(Icons.add, color: Colors.white),
          onPressed: _showAddBudgetDialog,
        ),
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text('Loading budget data...'),
        ],
      ),
    );
  }

  /// Build overview tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          _buildPeriodSelector(),
          SizedBox(height: 20),

          // Budget summary
          _buildBudgetSummary(),
          SizedBox(height: 20),

          // Budget chart
          _buildBudgetChart(),
          SizedBox(height: 20),

          // Quick insights
          _buildQuickInsights(),
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
            onPressed: _showAddBudgetDialog,
            height: 45,
          ),
          SizedBox(height: 20),

          // Categories list
          Text(
            'Budget Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          Expanded(
            child: _budgetCategories.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: _budgetCategories.length,
                    itemBuilder: (context, index) {
                      return _buildBudgetCategoryCard(_budgetCategories[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Build period selector
  Widget _buildPeriodSelector() {
    final periods = ['This Week', 'This Month', 'This Year'];

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Budget Period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 12),

          Row(
            children: periods.map((period) {
              final isSelected = _selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPeriod = period;
                    });
                    _loadBudgetData(); // Reload data for new period
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: period != periods.last ? 8 : 0,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      period,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build budget summary
  Widget _buildBudgetSummary() {
    final totalBudget = _budgetCategories.fold<double>(
      0.0,
      (sum, category) => sum + category.budgetAmount,
    );
    final totalSpent = _currentSpending.values.fold<double>(
      0.0,
      (sum, amount) => sum + amount,
    );
    final remaining = totalBudget - totalSpent;
    final spentPercentage = totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Budget Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: spentPercentage.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: spentPercentage > 0.8 ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Budget details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Budget',
                '\$${totalBudget.toStringAsFixed(2)}',
                Colors.blue,
              ),
              _buildSummaryItem(
                'Spent',
                '\$${totalSpent.toStringAsFixed(2)}',
                Colors.red,
              ),
              _buildSummaryItem(
                'Remaining',
                '\$${remaining.toStringAsFixed(2)}',
                Colors.green,
              ),
            ],
          ),
          SizedBox(height: 12),

          Center(
            child: Text(
              '${(spentPercentage * 100).toInt()}% of budget used',
              style: TextStyle(
                color: spentPercentage > 0.8 ? Colors.red : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build summary item
  Widget _buildSummaryItem(String label, String amount, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Build budget chart
  Widget _buildBudgetChart() {
    if (_budgetCategories.isEmpty) {
      return Container();
    }

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Spending Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),

          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _budgetCategories.map((category) {
                  final spent = _currentSpending[category.name] ?? 0.0;
                  final percentage = category.budgetAmount > 0
                      ? (spent / category.budgetAmount) * 100
                      : 0.0;

                  return PieChartSectionData(
                    value: spent > 0
                        ? spent
                        : 1, // Minimum value for visibility
                    title: '${percentage.toInt()}%',
                    color: _getCategoryColor(category.color),
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
            ),
          ),
          SizedBox(height: 16),

          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: _budgetCategories.map((category) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category.color),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(category.name, style: TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Build quick insights
  Widget _buildQuickInsights() {
    final insights = _generateInsights();

    if (insights.isEmpty) return Container();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Budget Insights',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          ...insights
              .map(
                (insight) => Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(insight['icon'], color: insight['color'], size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight['text'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  /// Build budget category card
  Widget _buildBudgetCategoryCard(models.BudgetCategory category) {
    final spent = _currentSpending[category.name] ?? 0.0;
    final progress = category.budgetAmount > 0
        ? (spent / category.budgetAmount)
        : 0.0;
    final isOverBudget = spent > category.budgetAmount;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIconData(category.icon),
                  color: _getCategoryColor(category.color),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Budget: ${category.formattedBudgetAmount}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              // More options
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editBudgetCategory(category);
                  } else if (value == 'delete') {
                    _deleteBudgetCategory(category);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Progress bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: isOverBudget
                      ? Colors.red
                      : _getCategoryColor(category.color),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Spent: \$${spent.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isOverBudget ? Colors.red : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Remaining: \$${(category.budgetAmount - spent).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  color: isOverBudget ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          if (isOverBudget) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Over budget by \$${(spent - category.budgetAmount).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No budget categories yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first budget category to start tracking',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  /// Get category color
  Color _getCategoryColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// Get category icon
  IconData _getCategoryIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  /// Generate insights based on spending patterns
  List<Map<String, dynamic>> _generateInsights() {
    List<Map<String, dynamic>> insights = [];

    for (var category in _budgetCategories) {
      final spent = _currentSpending[category.name] ?? 0.0;
      final percentage = category.budgetAmount > 0
          ? (spent / category.budgetAmount)
          : 0.0;

      if (percentage > 0.9) {
        insights.add({
          'icon': Icons.warning,
          'color': Colors.red,
          'text':
              '${category.name} is ${(percentage * 100).toInt()}% over budget',
        });
      } else if (percentage > 0.8) {
        insights.add({
          'icon': Icons.info,
          'color': Colors.orange,
          'text': '${category.name} is approaching budget limit',
        });
      }
    }

    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.check_circle,
        'color': Colors.green,
        'text': 'You\'re staying within your budget limits!',
      });
    }

    return insights;
  }

  /// Show add budget dialog
  void _showAddBudgetDialog() {
    showDialog(context: context, builder: (context) => AddBudgetDialog()).then((
      result,
    ) {
      if (result == true) {
        _loadBudgetData(); // Reload data after adding
      }
    });
  }

  /// Edit budget category
  void _editBudgetCategory(models.BudgetCategory category) {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(existingCategory: category),
    ).then((result) {
      if (result == true) {
        _loadBudgetData(); // Reload data after editing
      }
    });
  }

  /// Delete budget category
  void _deleteBudgetCategory(models.BudgetCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Budget Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Implement delete from database
              Navigator.pop(context);
              _loadBudgetData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Budget category deleted')),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Add Budget Dialog Widget
class AddBudgetDialog extends StatefulWidget {
  final models.BudgetCategory? existingCategory;

  const AddBudgetDialog({Key? key, this.existingCategory}) : super(key: key);

  @override
  _AddBudgetDialogState createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();

  String _selectedColor = 'blue';
  String _selectedIcon = 'category';
  bool _isLoading = false;

  final List<String> _colors = [
    'blue',
    'green',
    'red',
    'orange',
    'purple',
    'teal',
  ];
  final List<String> _icons = [
    'category',
    'restaurant',
    'directions_car',
    'shopping_bag',
    'movie',
    'receipt',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      _nameController.text = widget.existingCategory!.name;
      _budgetController.text = widget.existingCategory!.budgetAmount.toString();
      _selectedColor = widget.existingCategory!.color;
      _selectedIcon = widget.existingCategory!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.existingCategory != null ? 'Edit Budget' : 'Add Budget Category',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Budget amount field
            TextFormField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a budget amount';
                }
                if (double.tryParse(value) == null ||
                    double.parse(value) <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBudgetCategory,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingCategory != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  Future<void> _saveBudgetCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final category = models.BudgetCategory(
        id:
            widget.existingCategory?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        budgetAmount: double.parse(_budgetController.text.trim()),
        spentAmount: widget.existingCategory?.spentAmount ?? 0.0,
        color: _selectedColor,
        icon: _selectedIcon,
      );

      await LocalDbService.insertBudgetCategory(category);
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save budget category: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }
}
