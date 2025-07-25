// lib/models/user.dart
import 'dart:convert';

/// User data model for SaveMyPocket app
class User {
  final String id;
  final String name;
  final String email;
  final double monthlyIncome;
  final double savingsGoal;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.monthlyIncome,
    required this.savingsGoal,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
    this.preferences,
  });

  /// Create User instance from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      monthlyIncome: (json['monthly_income'] ?? 0).toDouble(),
      savingsGoal: (json['savings_goal'] ?? 0).toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
          : null,
      profileImageUrl: json['profile_image_url']?.toString(),
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  /// Convert User instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'monthly_income': monthlyIncome,
      'savings_goal': savingsGoal,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
    };
  }

  /// Create a copy of User with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    double? monthlyIncome,
    double? savingsGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      savingsGoal: savingsGoal ?? this.savingsGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Convert User to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Create User from JSON string
  factory User.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromJson(json);
  }

  /// Check if user profile is complete
  bool get isProfileComplete {
    return name.isNotEmpty &&
        email.isNotEmpty &&
        monthlyIncome > 0 &&
        savingsGoal > 0;
  }

  /// Get user's first name
  String get firstName {
    return name.split(' ').first;
  }

  /// Get formatted monthly income
  String get formattedMonthlyIncome {
    return '\$${monthlyIncome.toStringAsFixed(2)}';
  }

  /// Get formatted savings goal
  String get formattedSavingsGoal {
    return '\$${savingsGoal.toStringAsFixed(2)}';
  }

  /// Calculate savings progress percentage
  double getSavingsProgress(double currentSavings) {
    if (savingsGoal <= 0) return 0.0;
    return (currentSavings / savingsGoal).clamp(0.0, 1.0);
  }

  /// Get initials for profile avatar
  String get initials {
    if (name.isEmpty) return 'U';
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  /// Get default preferences
  static Map<String, dynamic> get defaultPreferences {
    return {
      'currency': 'USD',
      'notifications': true,
      'dark_mode': false,
      'budget_alerts': true,
      'weekly_reports': true,
    };
  }

  /// Create empty user instance
  factory User.empty() {
    return User(
      id: '',
      name: '',
      email: '',
      monthlyIncome: 0.0,
      savingsGoal: 0.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, monthlyIncome: $monthlyIncome, savingsGoal: $savingsGoal)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.monthlyIncome == monthlyIncome &&
        other.savingsGoal == savingsGoal;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, email, monthlyIncome, savingsGoal);
  }
}

/// Transaction data model
class Transaction {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final String type; // 'income' or 'expense'
  final String? receiptUrl;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    required this.type,
    this.receiptUrl,
  });

  /// Create Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category']?.toString() ?? '',
      date: json['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['date'])
          : DateTime.now(),
      description: json['description']?.toString(),
      type: json['type']?.toString() ?? 'expense',
      receiptUrl: json['receipt_url']?.toString(),
    );
  }

  /// Convert Transaction to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'description': description,
      'type': type,
      'receipt_url': receiptUrl,
    };
  }

  /// Check if transaction is income
  bool get isIncome => type == 'income';

  /// Check if transaction is expense
  bool get isExpense => type == 'expense';

  /// Get formatted amount with sign
  String get formattedAmount {
    final sign = isIncome ? '+' : '-';
    return '$sign\$${amount.abs().toStringAsFixed(2)}';
  }

  /// Create copy with updated fields
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    String? type,
    String? receiptUrl,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      type: type ?? this.type,
      receiptUrl: receiptUrl ?? this.receiptUrl,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, title: $title, amount: $amount, type: $type)';
  }
}

/// Budget category model
class BudgetCategory {
  final String id;
  final String name;
  final double budgetAmount;
  final double spentAmount;
  final String color;
  final String icon;

  const BudgetCategory({
    required this.id,
    required this.name,
    required this.budgetAmount,
    required this.spentAmount,
    required this.color,
    required this.icon,
  });

  /// Create from JSON
  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      budgetAmount: (json['budget_amount'] ?? 0).toDouble(),
      spentAmount: (json['spent_amount'] ?? 0).toDouble(),
      color: json['color']?.toString() ?? 'blue',
      icon: json['icon']?.toString() ?? 'category',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'budget_amount': budgetAmount,
      'spent_amount': spentAmount,
      'color': color,
      'icon': icon,
    };
  }

  /// Get remaining budget
  double get remainingAmount => budgetAmount - spentAmount;

  /// Get spending percentage
  double get spendingPercentage {
    if (budgetAmount <= 0) return 0.0;
    return (spentAmount / budgetAmount).clamp(0.0, 1.0);
  }

  /// Check if budget is exceeded
  bool get isOverBudget => spentAmount > budgetAmount;

  /// Get formatted budget amount
  String get formattedBudgetAmount => '\${budgetAmount.toStringAsFixed(2)}';

  /// Get formatted spent amount
  String get formattedSpentAmount => '\${spentAmount.toStringAsFixed(2)}';

  /// Get formatted remaining amount
  String get formattedRemainingAmount =>
      '\${remainingAmount.toStringAsFixed(2)}';

  @override
  String toString() {
    return 'BudgetCategory(id: $id, name: $name, budget: $budgetAmount, spent: $spentAmount)';
  }
}
