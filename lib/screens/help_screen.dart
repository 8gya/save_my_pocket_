// lib/screens/help_screen.dart
import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../routes.dart';

/// Help and support screen with FAQ and contact options
class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];
  List<FAQItem> _allFAQs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFAQs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadFAQs() {
    _allFAQs = [
      FAQItem(
        question: 'How do I add a new expense?',
        answer:
            'Tap the "+" button on the home screen or go to Add Expense from the menu. Fill in the amount, category, and description, then tap Save.',
        category: 'Basic Usage',
      ),
      FAQItem(
        question: 'How do I set up a budget?',
        answer:
            'Go to the Budget screen, tap "Add Category", enter your budget amount for each spending category. The app will track your spending against these limits.',
        category: 'Budgeting',
      ),
      FAQItem(
        question: 'Can I export my financial data?',
        answer:
            'Yes! Go to Settings > Export Data or use the export button in Reports. You can download your data as PDF or CSV format.',
        category: 'Data Management',
      ),
      FAQItem(
        question: 'How do I create savings goals?',
        answer:
            'Visit the Goals screen and tap the "+" button. Set your target amount, deadline, and category. Track progress by adding money regularly.',
        category: 'Goals',
      ),
      FAQItem(
        question: 'Is my financial data secure?',
        answer:
            'Yes, all data is encrypted and stored securely on your device and our secure servers. We never share your personal financial information.',
        category: 'Security',
      ),
      FAQItem(
        question: 'How do I change my profile information?',
        answer:
            'Go to Profile screen, tap the edit icon, update your information, and save changes. This includes name, income, and savings goals.',
        category: 'Account',
      ),
      FAQItem(
        question: 'Can I categorize my transactions?',
        answer:
            'Yes! When adding transactions, select from predefined categories like Food, Transport, Shopping, or create custom categories in Budget settings.',
        category: 'Basic Usage',
      ),
      FAQItem(
        question: 'How do I view spending reports?',
        answer:
            'Go to Reports screen to see detailed analytics including monthly trends, category breakdowns, and spending insights with interactive charts.',
        category: 'Reports',
      ),
      FAQItem(
        question: 'What if I exceed my budget?',
        answer:
            'The app will show warnings when you approach or exceed budget limits. You can adjust budgets or review spending patterns to stay on track.',
        category: 'Budgeting',
      ),
      FAQItem(
        question: 'How do I delete a transaction?',
        answer:
            'In the transaction list, swipe left on any transaction or tap the menu button and select Delete. This action cannot be undone.',
        category: 'Basic Usage',
      ),
    ];
    _filteredFAQs = _allFAQs;
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
                Tab(text: 'FAQ'),
                Tab(text: 'Contact'),
                Tab(text: 'About'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildFAQTab(), _buildContactTab(), _buildAboutTab()],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(
        'Help & Support',
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
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search FAQs...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: _filterFAQs,
          ),
        ),

        // FAQ categories
        _buildFAQCategories(),

        // FAQ list
        Expanded(
          child: _filteredFAQs.isEmpty
              ? _buildNoResultsState()
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filteredFAQs.length,
                  itemBuilder: (context, index) {
                    return _buildFAQItem(_filteredFAQs[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFAQCategories() {
    final categories = _allFAQs.map((faq) => faq.category).toSet().toList();

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', true);
          }
          return _buildCategoryChip(categories[index - 1], false);
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          _filterByCategory(category == 'All' ? null : category);
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).primaryColor,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            faq.category,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No FAQs found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try different search terms or browse categories',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Contact header
          Container(
            padding: EdgeInsets.all(24),
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
              children: [
                Icon(
                  Icons.support_agent,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Need More Help?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Our support team is here to help you with any questions or issues.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Contact options
          _buildContactOption(
            'Email Support',
            'Get help via email within 24 hours',
            Icons.email,
            Colors.blue,
            () => _contactSupport('email'),
          ),
          SizedBox(height: 12),

          _buildContactOption(
            'Live Chat',
            'Chat with our support team now',
            Icons.chat,
            Colors.green,
            () => _contactSupport('chat'),
          ),
          SizedBox(height: 12),

          _buildContactOption(
            'Phone Support',
            'Call us for immediate assistance',
            Icons.phone,
            Colors.orange,
            () => _contactSupport('phone'),
          ),
          SizedBox(height: 12),

          _buildContactOption(
            'Report a Bug',
            'Help us improve the app',
            Icons.bug_report,
            Colors.red,
            () => _contactSupport('bug'),
          ),
          SizedBox(height: 20),

          // Quick actions
          Container(
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
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Send Feedback',
                        onPressed: () => _sendFeedback(),
                        isSecondary: true,
                        height: 40,
                        icon: Icons.feedback,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Rate App',
                        onPressed: () => _rateApp(),
                        height: 40,
                        icon: Icons.star,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    String title,
    String subtitle,
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
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // App info
          Container(
            padding: EdgeInsets.all(24),
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
              children: [
                // App logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.savings, size: 40, color: Colors.white),
                ),
                SizedBox(height: 16),

                Text(
                  'SaveMyPocket',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  'Version 1.0.0',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 16),

                Text(
                  'Your smart finance companion for tracking expenses, managing budgets, and achieving savings goals.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Features overview
          _buildInfoSection('Key Features', Icons.star, [
            'Track income and expenses',
            'Set and monitor budgets',
            'Create savings goals',
            'Generate financial reports',
            'Secure data encryption',
            'Export data capabilities',
          ]),
          SizedBox(height: 20),

          _buildInfoSection('Legal Information', Icons.gavel, [
            'Privacy Policy',
            'Terms of Service',
            'Data Usage Policy',
            'Open Source Licenses',
          ], isClickable: true),
          SizedBox(height: 20),

          Container(
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
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Made with Love',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                Text(
                  'SaveMyPocket is built to help you take control of your finances and achieve your financial goals. Thank you for using our app!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),

                Text(
                  '© 2024 SaveMyPocket. All rights reserved.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String title,
    IconData icon,
    List<String> items, {
    bool isClickable = false,
  }) {
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
          Row(
            children: [
              Icon(icon, color: Theme.of(context).primaryColor, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          ...items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        isClickable ? Icons.link : Icons.check_circle,
                        size: 16,
                        color: isClickable ? Colors.blue : Colors.green,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: isClickable ? () => _openLink(item) : null,
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 14,
                              color: isClickable
                                  ? Colors.blue
                                  : Colors.grey[700],
                              decoration: isClickable
                                  ? TextDecoration.underline
                                  : null,
                            ),
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

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs = _allFAQs
            .where(
              (faq) =>
                  faq.question.toLowerCase().contains(query.toLowerCase()) ||
                  faq.answer.toLowerCase().contains(query.toLowerCase()) ||
                  faq.category.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      if (category == null) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs = _allFAQs
            .where((faq) => faq.category == category)
            .toList();
      }
    });
  }

  void _contactSupport(String type) {
    String message;
    switch (type) {
      case 'email':
        message = 'Opening email client...';
        break;
      case 'chat':
        message = 'Starting live chat...';
        break;
      case 'phone':
        message = 'Calling support: +1-800-SAVE-123';
        break;
      case 'bug':
        message = 'Opening bug report form...';
        break;
      default:
        message = 'Contacting support...';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _sendFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening feedback form...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening app store for rating...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _openLink(String linkName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $linkName...'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// FAQ item model
class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
