// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart' as models;
import '../services/local_db_service.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// Main dashboard screen showing real financial data
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<models.Transaction> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Load data and refresh AuthProvider financial data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Refresh financial data in AuthProvider
      await authProvider.refreshFinancialData();

      // Load recent transactions
      final transactions = await LocalDbService.getTransactions();
      _recentTransactions = transactions.take(4).toList();
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: Color(0xFFF8F9FA),
          appBar: _buildAppBar(authProvider),
          body: _isLoading
              ? _buildLoadingState()
              : RefreshIndicator(
                  onRefresh: _refreshData,
                  color: Theme.of(context).primaryColor,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Welcome section with real data
                        _buildWelcomeSection(authProvider),

                        // Main content
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Savings overview with real progress
                              _buildSavingsOverview(authProvider),
                              SizedBox(height: 24),

                              // Quick actions
                              _buildQuickActions(),
                              SizedBox(height: 24),

                              // Recent transactions
                              _buildRecentTransactions(),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
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
          Text('Loading your financial data...'),
        ],
      ),
    );
  }

  /// Build app bar with user info and actions
  PreferredSizeWidget _buildAppBar(AuthProvider authProvider) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'SaveMyPocket',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        // Notifications
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('No new notifications')));
          },
        ),

        // Profile menu
        PopupMenuButton<String>(
          icon: Icon(Icons.account_circle, color: Colors.white),
          onSelected: (value) {
            if (value == 'profile') {
              AppRoutes.navigateToProfile(context);
            } else if (value == 'settings') {
              AppRoutes.navigateToSettings(context);
            } else if (value == 'help') {
              AppRoutes.navigateToHelp(context);
            } else if (value == 'logout') {
              _handleLogout(authProvider);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person, size: 18),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 18),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help, size: 18),
                  SizedBox(width: 12),
                  Text('Help'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Logout', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build welcome section with real balance and savings data from AuthProvider
  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting with real user name
            Text(
              'Hello, ${authProvider.name.isNotEmpty ? authProvider.name.split(' ').first : 'User'}!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),

            Text(
              'Here\'s your financial overview',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 24),

            // Balance and Savings cards with Save button
            Row(
              children: [
                // Current Balance card (from AuthProvider)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          authProvider.formatCurrency(
                            authProvider.currentBalance,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Save button - Always enabled
                GestureDetector(
                  onTap: () => _showSaveMoneyDialog(authProvider),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(height: 2),
                        Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),

                // Current Savings card (from AuthProvider)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Savings',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 4),
                        Text(
                          authProvider.formatCurrency(
                            authProvider.currentSavings,
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build savings overview using AuthProvider data
  Widget _buildSavingsOverview(AuthProvider authProvider) {
    final progress = authProvider.calculateSavingsProgress(null);

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
          // Section title
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Savings Progress',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Dynamic progress bar based on AuthProvider data
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
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Real progress details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Savings',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    authProvider.formatCurrency(authProvider.currentSavings),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Goal',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    authProvider.formatCurrency(authProvider.savingsGoal),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),

          // Dynamic progress percentage
          Center(
            child: Text(
              '${(progress * 100).toInt()}% of your goal achieved',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick actions section
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Expense',
                Icons.remove_circle_outline,
                Colors.red,
                () => _navigateToAddExpense(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Add Income',
                Icons.add_circle_outline,
                Colors.red,
                () => _navigateToAddIncome(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'View Details',
                Icons.analytics_outlined,
                Colors.blue,
                () => _navigateToViewDetails(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),

        // Second row of actions
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Budget',
                Icons.account_balance_wallet,
                Colors.purple,
                () => AppRoutes.navigateToBudget(context),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Goals',
                Icons.flag,
                Colors.orange,
                () => AppRoutes.navigateToGoals(context),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Reports',
                Icons.bar_chart,
                Colors.teal,
                () => AppRoutes.navigateToReports(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build action card widget
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build recent transactions section
  Widget _buildRecentTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            if (_recentTransactions.isNotEmpty)
              TextButton(
                onPressed: _navigateToViewDetails,
                child: Text('See All'),
              ),
          ],
        ),
        SizedBox(height: 16),

        // Transaction list or empty state
        Container(
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
          child: _recentTransactions.isEmpty
              ? _buildEmptyTransactionsState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: _recentTransactions.length,
                  separatorBuilder: (context, index) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(_recentTransactions[index]);
                  },
                ),
        ),
      ],
    );
  }

  /// Build individual transaction item with real data
  Widget _buildTransactionItem(models.Transaction transaction) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: transaction.isIncome
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getTransactionIcon(transaction.category),
          color: transaction.isIncome ? Colors.green : Colors.red,
          size: 20,
        ),
      ),
      title: Text(
        transaction.title,
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction.category,
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Text(
        transaction.formattedAmount,
        style: TextStyle(
          color: transaction.isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  /// Get appropriate icon for transaction category
  IconData _getTransactionIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Icons.restaurant;
      case 'transportation':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
      case 'freelance':
      case 'business':
        return Icons.work;
      case 'investment':
        return Icons.trending_up;
      case 'gift':
        return Icons.card_giftcard;
      case 'bonus':
        return Icons.stars;
      case 'savings transfer':
        return Icons.savings;
      default:
        return Icons.receipt;
    }
  }

  /// Build empty transactions state
  Widget _buildEmptyTransactionsState() {
    return Container(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start by adding your first income or expense',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Add Income',
                  onPressed: _navigateToAddIncome,
                  height: 40,
                  icon: Icons.add,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'Add Expense',
                  onPressed: _navigateToAddExpense,
                  isSecondary: true,
                  height: 40,
                  icon: Icons.remove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Refresh data from AuthProvider and database
  Future<void> _refreshData() async {
    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data refreshed successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Navigate to add expense screen
  Future<void> _navigateToAddExpense() async {
    await AppRoutes.navigateToExpense(context);
    _refreshData(); // Refresh data when returning
  }

  /// Navigate to add income screen
  Future<void> _navigateToAddIncome() async {
    await AppRoutes.navigateToIncome(context);
    _refreshData(); // Refresh data when returning
  }

  void _navigateToViewDetails() {
    AppRoutes.navigateToViewDetails(context);
  }

  void _showSaveMoneyDialog(AuthProvider authProvider) {
    final _amountController = TextEditingController();

    // Check if user has any balance to save
    if (authProvider.currentBalance <= 0) {
      // Show message to add income first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('Add Income First'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'You need to add some income before you can save money.',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Text(
                'Your current balance is ${authProvider.formatCurrency(authProvider.currentBalance)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
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
                Navigator.pop(context);
                _navigateToAddIncome();
              },
              child: Text('Add Income'),
            ),
          ],
        ),
      );
      return;
    }

    // Show normal save money dialog if user has balance
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.savings, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Save Money'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer money from your current balance to savings',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 16),

            // Available balance
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Available Balance:'),
                  Text(
                    authProvider.formatCurrency(authProvider.currentBalance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Amount input
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount to Save',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: '0.00',
              ),
            ),
            SizedBox(height: 16),

            // Quick amount buttons
            Text(
              'Quick amounts:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildQuickAmountButton(
                  _amountController,
                  authProvider.currentBalance * 0.1,
                  '10%',
                ),
                _buildQuickAmountButton(
                  _amountController,
                  authProvider.currentBalance * 0.25,
                  '25%',
                ),
                _buildQuickAmountButton(
                  _amountController,
                  authProvider.currentBalance * 0.5,
                  '50%',
                ),
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
            onPressed: () async {
              final amount = double.tryParse(_amountController.text.trim());
              if (amount != null &&
                  amount > 0 &&
                  amount <= authProvider.currentBalance) {
                Navigator.pop(context);

                // Use AuthProvider's transfer method
                final success = await authProvider.transferToSavings(amount);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Successfully saved \$${amount.toStringAsFixed(2)}!',
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );

                  // Refresh transactions list
                  _refreshData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error saving money. Please try again.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please enter a valid amount within your balance',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Save Money'),
          ),
        ],
      ),
    );
  }

  /// Build quick amount button
  Widget _buildQuickAmountButton(
    TextEditingController controller,
    double amount,
    String label,
  ) {
    return GestureDetector(
      onTap: () {
        controller.text = amount.toStringAsFixed(2);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '$label (\$${amount.toStringAsFixed(0)})',
          style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  /// Handle user logout
  Future<void> _handleLogout(AuthProvider authProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await authProvider.logout();
        AppRoutes.navigateToLogin(context, replace: true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
