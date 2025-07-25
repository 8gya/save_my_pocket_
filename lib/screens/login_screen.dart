// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// User onboarding and registration screen
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form inputs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _incomeController = TextEditingController();
  final _savingsGoalController = TextEditingController();

  // Page controller for onboarding steps
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _incomeController.dispose();
    _savingsGoalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [_buildWelcomePage(), _buildRegistrationPage()],
        ),
      ),
    );
  }

  /// Welcome page with app introduction
  Widget _buildWelcomePage() {
    return Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.savings, size: 70, color: Colors.white),
          ),
          SizedBox(height: 40),

          // App title
          Text(
            'SaveMyPocket',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),

          // App description
          Text(
            'Take control of your finances with smart budgeting and savings tracking',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60),

          // Features list
          _buildFeatureItem(
            Icons.account_balance_wallet,
            'Track your expenses',
          ),
          SizedBox(height: 16),
          _buildFeatureItem(Icons.trending_up, 'Set savings goals'),
          SizedBox(height: 16),
          _buildFeatureItem(Icons.insights, 'Get financial insights'),
          SizedBox(height: 60),

          // Get started button
          CustomButton(
            text: 'Get Started',
            onPressed: () {
              _pageController.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }

  /// Registration page with user info form
  Widget _buildRegistrationPage() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator
                _buildProgressIndicator(),
                SizedBox(height: 30),

                // Title
                Text(
                  'Let\'s set up your profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  'We need some basic info to personalize your experience',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),

                // Form fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Name field
                        _buildInputField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Email field
                        _buildInputField(
                          controller: _emailController,
                          label: 'Email Address',
                          hint: 'Enter your email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Monthly income field
                        _buildInputField(
                          controller: _incomeController,
                          label: 'Monthly Income',
                          hint: 'Enter your monthly income',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your monthly income';
                            }
                            final income = double.tryParse(value);
                            if (income == null || income <= 0) {
                              return 'Please enter a valid income amount';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Savings goal field
                        _buildInputField(
                          controller: _savingsGoalController,
                          label: 'Savings Goal',
                          hint: 'Enter your savings target',
                          icon: Icons.savings,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your savings goal';
                            }
                            final goal = double.tryParse(value);
                            if (goal == null || goal <= 0) {
                              return 'Please enter a valid savings goal';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Back',
                        onPressed: () {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        isSecondary: true,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Create',
                        isLoading: authProvider.isLoading,
                        onPressed: () => _handleRegistration(authProvider),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build feature item for welcome page
  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        ),
        SizedBox(width: 16),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Build input field with consistent styling
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  /// Build progress indicator
  Widget _buildProgressIndicator() {
    return Row(
      children: List.generate(2, (index) {
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: index < 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: index <= _currentPage
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  /// Handle user registration
  Future<void> _handleRegistration(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final success = await authProvider.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        monthlyIncome: double.parse(_incomeController.text.trim()),
        savingsGoal: double.parse(_savingsGoalController.text.trim()),
      );

      if (success) {
        // Navigate to home screen
        AppRoutes.navigateTo(context, AppRoutes.home, replace: true);
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
