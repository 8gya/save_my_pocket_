// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user.dart' as models;

/// Service for Firebase operations (Auth, Firestore, Storage)
class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection names
  static const String _usersCollection = 'users';
  static const String _transactionsCollection = 'transactions';
  static const String _budgetCategoriesCollection = 'budget_categories';

  /// Sign up with email and password
  static Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Sign up error: $e');
      throw Exception('Failed to create account');
    }
  }

  /// Sign in with email and password
  static Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.message}');
      throw Exception(_getAuthErrorMessage(e.code));
    } catch (e) {
      print('Sign in error: $e');
      throw Exception('Failed to sign in');
    }
  }

  /// Sign in anonymously (for demo purposes)
  static Future<User?> signInAnonymously() async {
    try {
      final UserCredential userCredential = await _auth.signInAnonymously();
      return userCredential.user;
    } catch (e) {
      print('Anonymous sign in error: $e');
      throw Exception('Failed to sign in anonymously');
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      throw Exception('Failed to sign out');
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Save user profile to Firestore
  static Future<void> saveUserProfile(models.User userProfile) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .set(userProfile.toJson());
    } catch (e) {
      print('Error saving user profile: $e');
      throw Exception('Failed to save user profile');
    }
  }

  /// Get user profile from Firestore
  static Future<models.User?> getUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data() != null) {
        return models.User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Save transaction to Firestore
  static Future<void> saveTransaction(models.Transaction transaction) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .collection(_transactionsCollection)
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      print('Error saving transaction: $e');
      throw Exception('Failed to save transaction');
    }
  }

  /// Get all transactions for current user
  static Future<List<models.Transaction>> getTransactions() async {
    try {
      final user = getCurrentUser();
      if (user == null) return [];

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .collection(_transactionsCollection)
          .orderBy('date', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                models.Transaction.fromJson(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  /// Delete transaction
  static Future<void> deleteTransaction(String transactionId) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .collection(_transactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction');
    }
  }

  /// Save budget category
  static Future<void> saveBudgetCategory(models.BudgetCategory category) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .collection(_budgetCategoriesCollection)
          .doc(category.id)
          .set(category.toJson());
    } catch (e) {
      print('Error saving budget category: $e');
      throw Exception('Failed to save budget category');
    }
  }

  /// Get budget categories
  static Future<List<models.BudgetCategory>> getBudgetCategories() async {
    try {
      final user = getCurrentUser();
      if (user == null) return [];

      final QuerySnapshot querySnapshot = await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .collection(_budgetCategoriesCollection)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => models.BudgetCategory.fromJson(
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (e) {
      print('Error getting budget categories: $e');
      return [];
    }
  }

  /// Upload profile image
  static Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      final String fileName =
          'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'profile_images/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image');
    }
  }

  /// Upload receipt image
  static Future<String?> uploadReceiptImage(
    File imageFile,
    String transactionId,
  ) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      final String fileName =
          'receipt_${transactionId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = _storage.ref().child(
        'receipts/${user.uid}/$fileName',
      );

      final UploadTask uploadTask = storageRef.putFile(imageFile);
      final TaskSnapshot taskSnapshot = await uploadTask;

      final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading receipt image: $e');
      throw Exception('Failed to upload receipt image');
    }
  }

  /// Delete image from storage
  static Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference imageRef = _storage.refFromURL(imageUrl);
      await imageRef.delete();
    } catch (e) {
      print('Error deleting image: $e');
      // Don't throw error for image deletion failures
    }
  }

  /// Get user-friendly auth error messages
  static String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'An authentication error occurred.';
    }
  }

  /// Listen to auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if user is signed in
  static bool get isSignedIn => _auth.currentUser != null;

  /// Get current user ID
  static String? get currentUserId => _auth.currentUser?.uid;

  /// Real-time transaction updates
  static Stream<List<models.Transaction>> getTransactionsStream() {
    final user = getCurrentUser();
    if (user == null) return Stream.value([]);

    return _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .collection(_transactionsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => models.Transaction.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Initialize Firebase services
  static Future<void> initialize() async {
    try {
      // Firebase is already initialized in main.dart
      print('Firebase services ready');
    } catch (e) {
      print('Error initializing Firebase services: $e');
    }
  }
}
