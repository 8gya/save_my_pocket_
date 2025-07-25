// lib/routes.dart
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/budget_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/help_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/add_income_screen.dart';
import 'screens/view_details_screen.dart';

/// Centralized route management for the SaveMyPocket app
class AppRoutes {
  // Route name constants
  static const String login = '/login';
  static const String home = '/home';
  static const String detail = '/detail';
  static const String expense = '/expense';
  static const String income = '/income';
  static const String budget = '/budget';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String reports = '/reports';
  static const String goals = '/goals';
  static const String help = '/help';
  static const String addExpense = '/add_expense';
  static const String addIncome = '/add_income';
  static const String viewDetails = '/view_details';

  /// Generate routes based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );

      case home:
        return MaterialPageRoute(
          builder: (_) => HomeScreen(),
          settings: settings,
        );

      case detail:
        // Extract arguments for detail screen
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => DetailScreen(
            title: args?['title'] ?? 'Details',
            data: args?['data'],
          ),
          settings: settings,
        );

      case expense:
        return MaterialPageRoute(
          builder: (_) => ExpenseScreen(type: 'expense'),
          settings: settings,
        );

      case income:
        return MaterialPageRoute(
          builder: (_) => ExpenseScreen(type: 'income'),
          settings: settings,
        );

      case budget:
        return MaterialPageRoute(
          builder: (_) => BudgetScreen(),
          settings: settings,
        );

      case profile:
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(),
          settings: settings,
        );

      case reports:
        return MaterialPageRoute(
          builder: (_) => ReportsScreen(),
          settings: settings,
        );

      case goals:
        return MaterialPageRoute(
          builder: (_) => GoalsScreen(),
          settings: settings,
        );

      case help:
        return MaterialPageRoute(
          builder: (_) => HelpScreen(),
          settings: settings,
        );

      case addExpense:
        return MaterialPageRoute(
          builder: (_) => AddExpenseScreen(),
          settings: settings,
        );

      case addIncome:
        return MaterialPageRoute(
          builder: (_) => AddIncomeScreen(),
          settings: settings,
        );

      case viewDetails:
        return MaterialPageRoute(
          builder: (_) => ViewDetailsScreen(),
          settings: settings,
        );

      default:
        // Default route - redirect to login
        return MaterialPageRoute(
          builder: (_) => LoginScreen(),
          settings: settings,
        );
    }
  }

  /// Navigate to specific route with optional arguments
  static Future<void> navigateTo(
    BuildContext context,
    String routeName, {
    Map<String, dynamic>? arguments,
    bool replace = false,
  }) async {
    if (replace) {
      await Navigator.pushReplacementNamed(
        context,
        routeName,
        arguments: arguments,
      );
    } else {
      await Navigator.pushNamed(context, routeName, arguments: arguments);
    }
  }

  /// Navigate back or to home if no previous route
  static void navigateBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, home);
    }
  }

  /// Quick navigation methods for common routes
  static Future<void> navigateToHome(
    BuildContext context, {
    bool replace = false,
  }) {
    return navigateTo(context, home, replace: replace);
  }

  static Future<void> navigateToLogin(
    BuildContext context, {
    bool replace = false,
  }) {
    return navigateTo(context, login, replace: replace);
  }

  static Future<void> navigateToExpense(BuildContext context) {
    return navigateTo(context, expense);
  }

  static Future<void> navigateToIncome(BuildContext context) {
    return navigateTo(context, income);
  }

  static Future<void> navigateToBudget(BuildContext context) {
    return navigateTo(context, budget);
  }

  static Future<void> navigateToProfile(BuildContext context) {
    return navigateTo(context, profile);
  }

  static Future<void> navigateToSettings(BuildContext context) {
    return navigateTo(context, settings);
  }

  static Future<void> navigateToReports(BuildContext context) {
    return navigateTo(context, reports);
  }

  static Future<void> navigateToGoals(BuildContext context) {
    return navigateTo(context, goals);
  }

  static Future<void> navigateToHelp(BuildContext context) {
    return navigateTo(context, help);
  }

  // NEW NAVIGATION METHODS - These were missing!
  static Future<void> navigateToAddExpense(BuildContext context) {
    return navigateTo(context, addExpense);
  }

  static Future<void> navigateToAddIncome(BuildContext context) {
    return navigateTo(context, addIncome);
  }

  static Future<void> navigateToViewDetails(BuildContext context) {
    return navigateTo(context, viewDetails);
  }

  /// Navigate to detail screen with specific data
  static Future<void> navigateToDetail(
    BuildContext context, {
    required String title,
    dynamic data,
  }) {
    return navigateTo(
      context,
      detail,
      arguments: {'title': title, 'data': data},
    );
  }
}
