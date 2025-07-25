// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'routes.dart';

/// Main application widget with theme and provider setup
class SaveMyPocketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication provider for user management
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'SaveMyPocket',
        debugShowCheckedModeBanner: false,

        // App theme - clean green finance theme
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: Color(0xFF2E7D32), // Dark green
          scaffoldBackgroundColor: Color(0xFFF8F9FA),
          cardColor: Colors.white,
          fontFamily: 'Roboto',

          // Clean button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
          ),

          // Input field theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
          ),
        ),

        // Initial route determination
        home: AppInitializer(),

        // All app routes
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

/// Determines initial screen based on user authentication status
class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  /// Check if user has completed setup/login
  Future<void> _checkUserStatus() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadUserData();

      setState(() {
        _isUserLoggedIn = authProvider.isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      print('Error checking user status: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking user status
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF2E7D32),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(Icons.savings, size: 60, color: Color(0xFF2E7D32)),
              ),
              SizedBox(height: 32),

              // App name
              Text(
                'SaveMyPocket',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),

              // Tagline
              Text(
                'Your Smart Finance Companion',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 50),

              // Loading indicator
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Navigate to appropriate screen
    return _isUserLoggedIn ? HomeScreen() : LoginScreen();
  }
}
