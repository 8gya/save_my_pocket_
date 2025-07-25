// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_db_service.dart';
import '../models/user.dart' as models;

/// Manages user authentication and profile data
class AuthProvider extends ChangeNotifier {
  // User profile data
  String _name = '';
  String _email = '';
  double _monthlyIncome = 0.0;
  double _savingsGoal = 0.0;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  // Real-time financial data
  double _currentBalance = 0.0;
  double _currentSavings = 0.0;

  // Getters for accessing user data
  String get name => _name;
  String get email => _email;
  double get monthlyIncome => _monthlyIncome;
  double get savingsGoal => _savingsGoal;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  // Getters for financial data
  double get currentBalance => _currentBalance;
  double get currentSavings => _currentSavings;

  /// Load user data from SharedPreferences (local storage)
  Future<void> loadUserData() async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load all user data from local storage
      _name = prefs.getString('user_name') ?? '';
      _email = prefs.getString('user_email') ?? '';
      _monthlyIncome = prefs.getDouble('user_monthly_income') ?? 0.0;
      _savingsGoal = prefs.getDouble('user_savings_goal') ?? 0.0;
      _isLoggedIn = prefs.getBool('user_logged_in') ?? false;

      // Load financial data
      await _loadFinancialData();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load current financial data (balance and savings)
  Future<void> _loadFinancialData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Load saved current savings
      _currentSavings = prefs.getDouble('current_savings') ?? 0.0;

      // Calculate current balance from transactions
      final transactions = await LocalDbService.getTransactions();
      _currentBalance = transactions.fold<double>(
        0.0,
        (sum, transaction) =>
            sum +
            (transaction.isIncome ? transaction.amount : -transaction.amount),
      );
    } catch (e) {
      print('Error loading financial data: $e');
      _currentBalance = 0.0;
      _currentSavings = 0.0;
    }
  }

  /// Refresh financial data and notify listeners
  Future<void> refreshFinancialData() async {
    await _loadFinancialData();
    notifyListeners();
  }

  /// Update current savings and persist to storage
  Future<void> updateCurrentSavings(double newSavingsAmount) async {
    try {
      _currentSavings = newSavingsAmount;

      // Persist to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_savings', _currentSavings);

      notifyListeners();
    } catch (e) {
      print('Error updating current savings: $e');
    }
  }

  /// Transfer money from balance to savings
  Future<bool> transferToSavings(double amount) async {
    try {
      if (amount <= 0 || amount > _currentBalance) {
        throw Exception('Invalid transfer amount');
      }

      // Create transfer transaction
      final transferTransaction = models.Transaction(
        id: 'transfer_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Transfer to Savings',
        amount: amount,
        category: 'Savings Transfer',
        date: DateTime.now(),
        description: 'Money transferred to savings account',
        type: 'expense', // This reduces the balance
      );

      // Save transaction to database
      await LocalDbService.insertTransaction(transferTransaction);

      // Update local state
      _currentBalance -= amount;
      _currentSavings += amount;

      // Persist savings to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('current_savings', _currentSavings);

      notifyListeners();
      return true;
    } catch (e) {
      print('Error transferring to savings: $e');
      return false;
    }
  }

  /// Add new transaction and update balance
  Future<bool> addTransaction(models.Transaction transaction) async {
    try {
      // Save transaction to database
      await LocalDbService.insertTransaction(transaction);

      // Update current balance
      if (transaction.isIncome) {
        _currentBalance += transaction.amount;
      } else {
        _currentBalance -= transaction.amount;
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding transaction: $e');
      return false;
    }
  }

  /// Register/Login user with basic info (onboarding process)
  Future<bool> registerUser({
    required String name,
    required String email,
    required double monthlyIncome,
    required double savingsGoal,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate API call delay
      await Future.delayed(Duration(seconds: 1));

      // Validate inputs
      if (name.isEmpty ||
          email.isEmpty ||
          monthlyIncome <= 0 ||
          savingsGoal <= 0) {
        throw Exception('Please fill all fields with valid data');
      }

      // Save to SharedPreferences (local storage)
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setDouble('user_monthly_income', monthlyIncome);
      await prefs.setDouble('user_savings_goal', savingsGoal);
      await prefs.setBool('user_logged_in', true);

      // Initialize financial data
      await prefs.setDouble('current_savings', 0.0);

      // Update local variables
      _name = name;
      _email = email;
      _monthlyIncome = monthlyIncome;
      _savingsGoal = savingsGoal;
      _isLoggedIn = true;
      _currentBalance = 0.0;
      _currentSavings = 0.0;

      // Initialize user in database with their profile data
      await _initializeUserInDatabase();

      // FIXED: Add initial welcome income transaction to give user starting balance
      await _addWelcomeTransaction();

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error registering user: $e');
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// FIXED: Add welcome transaction to give new users a starting balance
  Future<void> _addWelcomeTransaction() async {
    try {
      // Add a welcome bonus transaction so users have some money to play with
      final welcomeTransaction = models.Transaction(
        id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Welcome Bonus',
        amount: 1000.0, // Give users $1000 to start with
        category: 'Gift',
        date: DateTime.now(),
        description:
            'Welcome to SaveMyPocket! Here\'s some money to get you started.',
        type: 'income',
      );

      await LocalDbService.insertTransaction(welcomeTransaction);

      // Update current balance
      _currentBalance += welcomeTransaction.amount;

      print('Added welcome transaction: ${welcomeTransaction.formattedAmount}');
    } catch (e) {
      print('Error adding welcome transaction: $e');
    }
  }

  /// Initialize user in database with their profile data
  Future<void> _initializeUserInDatabase() async {
    try {
      // Initialize database
      await LocalDbService.database;

      // Optionally create default budget categories based on user income
      await _createDefaultBudgetCategories();
    } catch (e) {
      print('Error initializing user in database: $e');
    }
  }

  /// Create default budget categories based on user income
  Future<void> _createDefaultBudgetCategories() async {
    try {
      // Only create if no categories exist
      final existingCategories = await LocalDbService.getBudgetCategories();
      if (existingCategories.isNotEmpty) return;

      // Create categories based on percentage of monthly income
      final budgetCategories = [
        {
          'name': 'Food & Dining',
          'percentage': 0.15,
          'color': 'orange',
          'icon': 'restaurant',
        },
        {
          'name': 'Transportation',
          'percentage': 0.10,
          'color': 'blue',
          'icon': 'directions_car',
        },
        {
          'name': 'Shopping',
          'percentage': 0.08,
          'color': 'purple',
          'icon': 'shopping_bag',
        },
        {
          'name': 'Entertainment',
          'percentage': 0.05,
          'color': 'green',
          'icon': 'movie',
        },
        {
          'name': 'Bills & Utilities',
          'percentage': 0.25,
          'color': 'red',
          'icon': 'receipt',
        },
      ];

      for (var categoryData in budgetCategories) {
        final budgetAmount =
            _monthlyIncome * (categoryData['percentage'] as double);

        final categoryName = categoryData['name'] as String;
        final category = models.BudgetCategory(
          id: 'default_${categoryName.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
          name: categoryName,
          budgetAmount: budgetAmount,
          spentAmount: 0.0,
          color: categoryData['color'] as String,
          icon: categoryData['icon'] as String,
        );

        await LocalDbService.insertBudgetCategory(category);
      }
    } catch (e) {
      print('Error creating default budget categories: $e');
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    double? monthlyIncome,
    double? savingsGoal,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Update fields if provided
      if (name != null && name.isNotEmpty) {
        _name = name;
        await prefs.setString('user_name', name);
      }
      if (email != null && email.isNotEmpty) {
        _email = email;
        await prefs.setString('user_email', email);
      }
      if (monthlyIncome != null && monthlyIncome > 0) {
        _monthlyIncome = monthlyIncome;
        await prefs.setDouble('user_monthly_income', monthlyIncome);
      }
      if (savingsGoal != null && savingsGoal > 0) {
        _savingsGoal = savingsGoal;
        await prefs.setDouble('user_savings_goal', savingsGoal);
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      print('Error updating profile: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Calculate savings progress percentage based on current savings amount
  double calculateSavingsProgress(double? currentSavings) {
    final savings = currentSavings ?? _currentSavings;
    if (_savingsGoal <= 0) return 0.0;
    return (savings / _savingsGoal).clamp(0.0, 1.0);
  }

  /// Get current balance from transactions (legacy method - now use currentBalance getter)
  @deprecated
  Future<double> getCurrentBalance() async {
    return _currentBalance;
  }

  /// Get current savings (legacy method - now use currentSavings getter)
  @deprecated
  Future<double> getCurrentSavings() async {
    return _currentSavings;
  }

  /// Get formatted currency display
  String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get financial health status based on savings progress
  String getFinancialHealthStatus([double? currentSavings]) {
    final progress = calculateSavingsProgress(currentSavings);
    if (progress >= 1.0) return 'Excellent';
    if (progress >= 0.75) return 'Good';
    if (progress >= 0.5) return 'Fair';
    if (progress >= 0.25) return 'Poor';
    return 'Needs Improvement';
  }

  /// Get monthly spending analysis
  Map<String, double> getMonthlySpendingAnalysis() {
    return {
      'income': _monthlyIncome,
      'savings_target': monthlySavingsTarget,
      'spending_budget': monthlySpendingBudget,
      'current_savings': _currentSavings,
      'current_balance': _currentBalance,
    };
  }

  /// Logout user and clear all data
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Clear SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset all variables
      _name = '';
      _email = '';
      _monthlyIncome = 0.0;
      _savingsGoal = 0.0;
      _isLoggedIn = false;
      _currentBalance = 0.0;
      _currentSavings = 0.0;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error during logout: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return _name.isNotEmpty &&
        _email.isNotEmpty &&
        _monthlyIncome > 0 &&
        _savingsGoal > 0;
  }

  /// Get monthly savings target (percentage of income)
  double get monthlySavingsTarget {
    return _monthlyIncome * 0.2; // 20% of monthly income as savings target
  }

  /// Get spending budget (income minus savings target)
  double get monthlySpendingBudget {
    return _monthlyIncome - monthlySavingsTarget;
  }
}
