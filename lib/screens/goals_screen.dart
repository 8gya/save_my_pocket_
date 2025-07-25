// lib/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// Savings goals management and tracking screen
class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<SavingsGoal> _goals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  /// Load goals from SharedPreferences
  Future<void> _loadGoals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsData = prefs.getStringList('savings_goals') ?? [];

      _goals = goalsData
          .map((goalJson) {
            final parts = goalJson.split('|');
            if (parts.length >= 7) {
              return SavingsGoal(
                id: parts[0],
                title: parts[1],
                targetAmount: double.tryParse(parts[2]) ?? 0.0,
                currentAmount: double.tryParse(parts[3]) ?? 0.0,
                targetDate: DateTime.fromMillisecondsSinceEpoch(
                  int.tryParse(parts[4]) ?? 0,
                ),
                category: parts[5],
                color: _getColorFromString(parts[6]),
                icon: _getIconFromString(
                  parts.length > 7 ? parts[7] : 'savings',
                ),
              );
            }
            return null;
          })
          .where((goal) => goal != null)
          .cast<SavingsGoal>()
          .toList();
    } catch (e) {
      print('Error loading goals: $e');
      _goals = [];
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Save goals to SharedPreferences
  Future<void> _saveGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final goalsData = _goals.map((goal) {
        return '${goal.id}|${goal.title}|${goal.targetAmount}|${goal.currentAmount}|${goal.targetDate.millisecondsSinceEpoch}|${goal.category}|${_getStringFromColor(goal.color)}|${_getStringFromIcon(goal.icon)}';
      }).toList();

      await prefs.setStringList('savings_goals', goalsData);
    } catch (e) {
      print('Error saving goals: $e');
    }
  }

  /// Add a new goal
  Future<void> _addGoal(SavingsGoal goal) async {
    setState(() {
      _goals.add(goal);
    });
    await _saveGoals();
  }

  /// Update an existing goal
  Future<void> _updateGoal(SavingsGoal updatedGoal) async {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
      if (index != -1) {
        _goals[index] = updatedGoal;
      }
    });
    await _saveGoals();
  }

  /// Delete a goal
  Future<void> _deleteGoal(String goalId) async {
    setState(() {
      _goals.removeWhere((g) => g.id == goalId);
    });
    await _saveGoals();
  }

  /// Add money to a goal
  Future<void> _addMoneyToGoal(String goalId, double amount) async {
    setState(() {
      final index = _goals.indexWhere((g) => g.id == goalId);
      if (index != -1) {
        _goals[index] = _goals[index].copyWith(
          currentAmount: _goals[index].currentAmount + amount,
        );
      }
    });
    await _saveGoals();
  }

  /// Convert color to string for storage
  String _getStringFromColor(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.purple) return 'purple';
    if (color == Colors.teal) return 'teal';
    return 'blue';
  }

  /// Convert string to color
  Color _getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'teal':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }

  /// Convert icon to string for storage
  String _getStringFromIcon(IconData icon) {
    if (icon == Icons.shield) return 'shield';
    if (icon == Icons.flight) return 'flight';
    if (icon == Icons.directions_car) return 'car';
    if (icon == Icons.home) return 'home';
    if (icon == Icons.school) return 'school';
    if (icon == Icons.medical_services) return 'medical';
    if (icon == Icons.beach_access) return 'vacation';
    if (icon == Icons.phone_android) return 'phone';
    return 'savings';
  }

  /// Convert string to icon
  IconData _getIconFromString(String iconString) {
    switch (iconString.toLowerCase()) {
      case 'shield':
        return Icons.shield;
      case 'flight':
        return Icons.flight;
      case 'car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'school':
        return Icons.school;
      case 'medical':
        return Icons.medical_services;
      case 'vacation':
        return Icons.beach_access;
      case 'phone':
        return Icons.phone_android;
      default:
        return Icons.savings;
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
                // Goals overview
                if (_goals.isNotEmpty) _buildGoalsOverview(),

                // Goals list
                Expanded(
                  child: _goals.isEmpty
                      ? _buildEmptyState()
                      : _buildGoalsList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Savings Goals',
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
        if (_goals.isNotEmpty)
          IconButton(
            icon: Icon(Icons.analytics, color: Colors.white),
            onPressed: _showGoalsAnalytics,
          ),
      ],
    );
  }

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
          Text('Loading your goals...'),
        ],
      ),
    );
  }

  Widget _buildGoalsOverview() {
    final totalTargetAmount = _goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.targetAmount,
    );
    final totalCurrentAmount = _goals.fold<double>(
      0.0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final overallProgress = totalTargetAmount > 0
        ? (totalCurrentAmount / totalTargetAmount)
        : 0.0;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.flag, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Goals Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Progress bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: overallProgress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildOverviewStat(
                'Total Saved',
                '\$${totalCurrentAmount.toStringAsFixed(0)}',
              ),
              _buildOverviewStat(
                'Total Goal',
                '\$${totalTargetAmount.toStringAsFixed(0)}',
              ),
              _buildOverviewStat(
                'Progress',
                '${(overallProgress * 100).toInt()}%',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  Widget _buildGoalsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _goals.length,
      itemBuilder: (context, index) {
        return _buildGoalCard(_goals[index]);
      },
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount)
        : 0.0;
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final daysRemaining = goal.targetDate.difference(DateTime.now()).inDays;
    final isOverdue = daysRemaining < 0;
    final isCompleted = goal.currentAmount >= goal.targetAmount;
    final dailySavingRequired = daysRemaining > 0 && remainingAmount > 0
        ? remainingAmount / daysRemaining
        : 0.0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
        border: isCompleted ? Border.all(color: Colors.green, width: 2) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 24),
                ),
                SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              goal.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        goal.category,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                // More options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editGoal(goal);
                    } else if (value == 'delete') {
                      _deleteGoal(goal.id);
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
            SizedBox(height: 20),

            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${goal.currentAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : goal.color,
                  ),
                ),
                Text(
                  '\$${goal.targetAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : goal.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),

            // Progress percentage
            Text(
              '${(progress * 100).toInt()}% completed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isCompleted ? Colors.green : goal.color,
              ),
            ),
            SizedBox(height: 16),

            // Goal details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildGoalDetailRow(
                    'Remaining',
                    '\$${remainingAmount.toStringAsFixed(0)}',
                    Icons.attach_money,
                  ),
                  SizedBox(height: 8),
                  _buildGoalDetailRow(
                    'Target Date',
                    DateFormat('MMM dd, yyyy').format(goal.targetDate),
                    Icons.calendar_today,
                  ),
                  SizedBox(height: 8),
                  _buildGoalDetailRow(
                    isOverdue ? 'Overdue by' : 'Days Left',
                    '${daysRemaining.abs()} days',
                    isOverdue ? Icons.warning : Icons.schedule,
                    textColor: isOverdue ? Colors.red : null,
                  ),
                  if (!isOverdue && remainingAmount > 0) ...[
                    SizedBox(height: 8),
                    _buildGoalDetailRow(
                      'Daily Saving',
                      '\$${dailySavingRequired.toStringAsFixed(2)}',
                      Icons.trending_up,
                      textColor: Colors.green,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomButton(
                    text: isCompleted ? 'Goal Achieved!' : 'Add Money',
                    onPressed: isCompleted
                        ? null
                        : () => _showAddMoneyDialog(goal),
                    height: 40,
                    icon: isCompleted ? Icons.check : Icons.add,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: 'Details',
                    onPressed: () => _viewGoalDetails(goal),
                    isSecondary: true,
                    height: 40,
                    icon: Icons.visibility,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalDetailRow(
    String label,
    String value,
    IconData icon, {
    Color? textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.flag, size: 64, color: Colors.grey[400]),
            ),
            SizedBox(height: 24),
            Text(
              'No savings goals yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Create your first savings goal to start tracking your progress',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            CustomButton(
              text: 'Create Your First Goal',
              onPressed: _showAddGoalDialog,
              icon: Icons.add,
              width: 250,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    showDialog(context: context, builder: (context) => AddGoalDialog()).then((
      newGoal,
    ) {
      if (newGoal != null) {
        _addGoal(newGoal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal "${newGoal.title}" created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  void _showAddMoneyDialog(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AddMoneyDialog(goal: goal),
    ).then((amount) {
      if (amount != null && amount > 0) {
        _addMoneyToGoal(goal.id, amount);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added \$${amount.toStringAsFixed(2)} to ${goal.title}',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  void _editGoal(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AddGoalDialog(existingGoal: goal),
    ).then((updatedGoal) {
      if (updatedGoal != null) {
        _updateGoal(updatedGoal);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Goal updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    });
  }

  void _viewGoalDetails(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(goal.icon, color: goal.color, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Progress
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: goal.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${((goal.currentAmount / goal.targetAmount) * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: goal.color,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Progress Completed',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    SizedBox(height: 12),

                    // Progress bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (goal.currentAmount / goal.targetAmount)
                            .clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: goal.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Details
              _buildDetailRow(
                'Current Amount',
                '\$${goal.currentAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Target Amount',
                '\$${goal.targetAmount.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Remaining',
                '\$${(goal.targetAmount - goal.currentAmount).toStringAsFixed(2)}',
              ),
              _buildDetailRow('Category', goal.category),
              _buildDetailRow(
                'Target Date',
                DateFormat('MMM dd, yyyy').format(goal.targetDate),
              ),

              SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: goal.currentAmount >= goal.targetAmount
                          ? 'Completed!'
                          : 'Add Money',
                      onPressed: goal.currentAmount >= goal.targetAmount
                          ? null
                          : () {
                              Navigator.pop(context);
                              _showAddMoneyDialog(goal);
                            },
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Close',
                      onPressed: () => Navigator.pop(context),
                      isSecondary: true,
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  void _showGoalsAnalytics() {
    final completedGoals = _goals
        .where((g) => g.currentAmount >= g.targetAmount)
        .length;
    final totalGoals = _goals.length;
    final averageProgress = _goals.isEmpty
        ? 0.0
        : _goals
                  .map((g) => g.currentAmount / g.targetAmount)
                  .reduce((a, b) => a + b) /
              _goals.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.analytics, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Goals Analytics'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnalyticRow('Total Goals', '$totalGoals'),
            _buildAnalyticRow('Completed Goals', '$completedGoals'),
            _buildAnalyticRow(
              'Success Rate',
              '${((completedGoals / totalGoals) * 100).toInt()}%',
            ),
            _buildAnalyticRow(
              'Average Progress',
              '${(averageProgress * 100).toInt()}%',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Savings goal data model
class SavingsGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String category;
  final Color color;
  final IconData icon;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.category,
    required this.color,
    required this.icon,
  });

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? category,
    Color? color,
    IconData? icon,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
}

/// Add Goal Dialog
class AddGoalDialog extends StatefulWidget {
  final SavingsGoal? existingGoal;

  const AddGoalDialog({Key? key, this.existingGoal}) : super(key: key);

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(Duration(days: 365));
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.savings;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  final List<IconData> _availableIcons = [
    Icons.savings,
    Icons.shield,
    Icons.flight,
    Icons.directions_car,
    Icons.home,
    Icons.school,
    Icons.medical_services,
    Icons.beach_access,
    Icons.phone_android,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _targetAmountController.text = widget.existingGoal!.targetAmount
          .toString();
      _categoryController.text = widget.existingGoal!.category;
      _selectedDate = widget.existingGoal!.targetDate;
      _selectedColor = widget.existingGoal!.color;
      _selectedIcon = widget.existingGoal!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.existingGoal != null ? 'Edit Goal' : 'Create New Goal',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Target amount field
              TextFormField(
                controller: _targetAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter target amount';
                  }
                  if (double.tryParse(value) == null ||
                      double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category field
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Date picker
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Target Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Color selection
              Text(
                'Choose Color:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableColors.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Icon selection
              Text(
                'Choose Icon:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _availableIcons.map((icon) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedIcon == icon
                            ? _selectedColor.withOpacity(0.2)
                            : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: _selectedIcon == icon
                            ? Border.all(color: _selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        icon,
                        color: _selectedIcon == icon
                            ? _selectedColor
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveGoal,
          child: Text(widget.existingGoal != null ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 3650)), // 10 years
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveGoal() {
    if (!_formKey.currentState!.validate()) return;

    final goal = SavingsGoal(
      id:
          widget.existingGoal?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      targetAmount: double.parse(_targetAmountController.text.trim()),
      currentAmount: widget.existingGoal?.currentAmount ?? 0.0,
      targetDate: _selectedDate,
      category: _categoryController.text.trim(),
      color: _selectedColor,
      icon: _selectedIcon,
    );

    Navigator.pop(context, goal);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _targetAmountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}

/// Add Money Dialog
class AddMoneyDialog extends StatefulWidget {
  final SavingsGoal goal;

  const AddMoneyDialog({Key? key, required this.goal}) : super(key: key);

  @override
  _AddMoneyDialogState createState() => _AddMoneyDialogState();
}

class _AddMoneyDialogState extends State<AddMoneyDialog> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final remainingAmount =
        widget.goal.targetAmount - widget.goal.currentAmount;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Money to ${widget.goal.title}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.goal.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Current: \$${widget.goal.currentAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Target: \$${widget.goal.targetAmount.toStringAsFixed(2)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'Remaining: \$${remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: widget.goal.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Amount to Add',
              prefixText: '\$',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 12),

          // Quick amount buttons
          Text(
            'Quick amounts:',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickAmountButton(remainingAmount * 0.25, '25%'),
              _buildQuickAmountButton(remainingAmount * 0.5, '50%'),
              _buildQuickAmountButton(remainingAmount, 'All'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final amount = double.tryParse(_amountController.text.trim());
            if (amount != null && amount > 0) {
              Navigator.pop(context, amount);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(double amount, String label) {
    return GestureDetector(
      onTap: () {
        _amountController.text = amount.toStringAsFixed(2);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: widget.goal.color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$label (\$${amount.toStringAsFixed(0)})',
          style: TextStyle(fontSize: 12, color: widget.goal.color),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
