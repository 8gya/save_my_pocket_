// lib/services/local_db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart' as models;

class LocalDbService {
  static Database? _database;
  static const String _databaseName = 'save_my_pocket.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _transactionsTable = 'transactions';
  static const String _budgetCategoriesTable = 'budget_categories';
  static const String _savingsGoalsTable = 'savings_goals';

  /// Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database and create tables
  static Future<Database> _initDatabase() async {
    try {
      // Get the documents directory path
      String path = join(await getDatabasesPath(), _databaseName);

      // Open/create the database
      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _createTables,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  /// Create all database tables
  static Future<void> _createTables(Database db, int version) async {
    try {
      // Users table
      await db.execute('''
        CREATE TABLE $_usersTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          monthly_income REAL NOT NULL DEFAULT 0,
          savings_goal REAL NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          profile_image_url TEXT,
          preferences TEXT
        )
      ''');

      // Transactions table
      await db.execute('''
        CREATE TABLE $_transactionsTable (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          date INTEGER NOT NULL,
          description TEXT,
          type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
          receipt_url TEXT,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
          FOREIGN KEY (user_id) REFERENCES $_usersTable (id) ON DELETE CASCADE
        )
      ''');

      // Budget categories table
      await db.execute('''
        CREATE TABLE $_budgetCategoriesTable (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          budget_amount REAL NOT NULL DEFAULT 0,
          spent_amount REAL NOT NULL DEFAULT 0,
          color TEXT NOT NULL DEFAULT 'blue',
          icon TEXT NOT NULL DEFAULT 'category',
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
          FOREIGN KEY (user_id) REFERENCES $_usersTable (id) ON DELETE CASCADE
        )
      ''');

      // Savings goals table
      await db.execute('''
        CREATE TABLE $_savingsGoalsTable (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          target_amount REAL NOT NULL,
          current_amount REAL NOT NULL DEFAULT 0,
          target_date INTEGER,
          created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now') * 1000),
          completed INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES $_usersTable (id) ON DELETE CASCADE
        )
      ''');

      // Create indexes for better performance
      await db.execute(
        'CREATE INDEX idx_transactions_user_id ON $_transactionsTable (user_id)',
      );
      await db.execute(
        'CREATE INDEX idx_transactions_date ON $_transactionsTable (date DESC)',
      );
      await db.execute(
        'CREATE INDEX idx_transactions_category ON $_transactionsTable (category)',
      );
      await db.execute(
        'CREATE INDEX idx_budget_categories_user_id ON $_budgetCategoriesTable (user_id)',
      );

      print('Database tables created successfully');
    } catch (e) {
      print('Error creating tables: $e');
      rethrow;
    }
  }

  /// Handle database upgrades
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    try {
      if (oldVersion < 2) {}
    } catch (e) {
      print('Error upgrading database: $e');
      rethrow;
    }
  }

  /// Insert or update user profile
  static Future<void> saveUser(models.User user) async {
    try {
      final db = await database;
      await db.insert(
        _usersTable,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user profile');
    }
  }

  /// Get user by ID
  static Future<models.User?> getUser(String userId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        _usersTable,
        where: 'id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return models.User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Get user by email
  static Future<models.User?> getUserByEmail(String email) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        _usersTable,
        where: 'email = ?',
        whereArgs: [email],
        limit: 1,
      );

      if (result.isNotEmpty) {
        return models.User.fromJson(result.first);
      }
      return null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  /// TRANSACTION OPERATIONS

  /// Insert new transaction
  static Future<void> insertTransaction(models.Transaction transaction) async {
    try {
      final db = await database;
      await db.insert(_transactionsTable, {
        ...transaction.toJson(),
        'user_id': 'current_user',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting transaction: $e');
      throw Exception('Failed to save transaction');
    }
  }

  /// Get all transactions for user
  static Future<List<models.Transaction>> getTransactions({
    String? userId,
    int? limit,
    String? category,
    String? type,
  }) async {
    try {
      final db = await database;
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId ?? 'current_user'];

      // Add category filter
      if (category != null) {
        whereClause += ' AND category = ?';
        whereArgs.add(category);
      }

      // Add type filter
      if (type != null) {
        whereClause += ' AND type = ?';
        whereArgs.add(type);
      }

      final List<Map<String, dynamic>> result = await db.query(
        _transactionsTable,
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'date DESC',
        limit: limit,
      );

      return result.map((json) => models.Transaction.fromJson(json)).toList();
    } catch (e) {
      print('Error getting transactions: $e');
      return [];
    }
  }

  /// Get transactions by date range
  static Future<List<models.Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        _transactionsTable,
        where: 'user_id = ? AND date BETWEEN ? AND ?',
        whereArgs: [
          userId ?? 'current_user',
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
        orderBy: 'date DESC',
      );

      return result.map((json) => models.Transaction.fromJson(json)).toList();
    } catch (e) {
      print('Error getting transactions by date range: $e');
      return [];
    }
  }

  /// Update transaction
  static Future<void> updateTransaction(models.Transaction transaction) async {
    try {
      final db = await database;
      await db.update(
        _transactionsTable,
        transaction.toJson(),
        where: 'id = ?',
        whereArgs: [transaction.id],
      );
    } catch (e) {
      print('Error updating transaction: $e');
      throw Exception('Failed to update transaction');
    }
  }

  /// Delete transaction
  static Future<void> deleteTransaction(String transactionId) async {
    try {
      final db = await database;
      await db.delete(
        _transactionsTable,
        where: 'id = ?',
        whereArgs: [transactionId],
      );
    } catch (e) {
      print('Error deleting transaction: $e');
      throw Exception('Failed to delete transaction');
    }
  }

  /// BUDGET CATEGORY OPERATIONS

  /// Insert budget category
  static Future<void> insertBudgetCategory(
    models.BudgetCategory category,
  ) async {
    try {
      final db = await database;
      await db.insert(_budgetCategoriesTable, {
        ...category.toJson(),
        'user_id': 'current_user',
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      print('Error inserting budget category: $e');
      throw Exception('Failed to save budget category');
    }
  }

  /// Get budget categories for user
  static Future<List<models.BudgetCategory>> getBudgetCategories({
    String? userId,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query(
        _budgetCategoriesTable,
        where: 'user_id = ?',
        whereArgs: [userId ?? 'current_user'],
        orderBy: 'name ASC',
      );

      return result
          .map((json) => models.BudgetCategory.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting budget categories: $e');
      return [];
    }
  }

  /// Update budget category spent amount
  static Future<void> updateCategorySpentAmount(
    String categoryId,
    double newSpentAmount,
  ) async {
    try {
      final db = await database;
      await db.update(
        _budgetCategoriesTable,
        {'spent_amount': newSpentAmount},
        where: 'id = ?',
        whereArgs: [categoryId],
      );
    } catch (e) {
      print('Error updating category spent amount: $e');
      throw Exception('Failed to update category spending');
    }
  }

  /// ANALYTICS AND REPORTING

  /// Get spending by category for a date range
  static Future<Map<String, double>> getSpendingByCategory({
    required DateTime startDate,
    required DateTime endDate,
    String? userId,
  }) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT category, SUM(amount) as total_amount
        FROM $_transactionsTable
        WHERE user_id = ? AND type = 'expense' AND date BETWEEN ? AND ?
        GROUP BY category
        ORDER BY total_amount DESC
      ''',
        [
          userId ?? 'current_user',
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );

      Map<String, double> categorySpending = {};
      for (var row in result) {
        categorySpending[row['category']] = row['total_amount'];
      }
      return categorySpending;
    } catch (e) {
      print('Error getting spending by category: $e');
      return {};
    }
  }

  /// Get monthly income and expense totals
  static Future<Map<String, double>> getMonthlyTotals({
    required int year,
    required int month,
    String? userId,
  }) async {
    try {
      final db = await database;
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

      final List<Map<String, dynamic>> result = await db.rawQuery(
        '''
        SELECT type, SUM(amount) as total_amount
        FROM $_transactionsTable
        WHERE user_id = ? AND date BETWEEN ? AND ?
        GROUP BY type
      ''',
        [
          userId ?? 'current_user',
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );

      Map<String, double> totals = {'income': 0.0, 'expense': 0.0};
      for (var row in result) {
        totals[row['type']] = row['total_amount'];
      }
      return totals;
    } catch (e) {
      print('Error getting monthly totals: $e');
      return {'income': 0.0, 'expense': 0.0};
    }
  }

  /// UTILITY METHODS

  static Future<void> clearUserData(String userId) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        await txn.delete(
          _transactionsTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(
          _budgetCategoriesTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(
          _savingsGoalsTable,
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.delete(_usersTable, where: 'id = ?', whereArgs: [userId]);
      });
    } catch (e) {
      print('Error clearing user data: $e');
      throw Exception('Failed to clear user data');
    }
  }

  /// Get database size and info
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final db = await database;
      final userCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $_usersTable'),
          ) ??
          0;
      final transactionCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $_transactionsTable'),
          ) ??
          0;
      final categoryCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM $_budgetCategoriesTable'),
          ) ??
          0;

      return {
        'database_path': db.path,
        'database_version': await db.getVersion(),
        'user_count': userCount,
        'transaction_count': transactionCount,
        'category_count': categoryCount,
      };
    } catch (e) {
      print('Error getting database info: $e');
      return {};
    }
  }

  /// Export data as JSON (for backup)
  static Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final user = await getUser(userId);
      final transactions = await getTransactions(userId: userId);
      final categories = await getBudgetCategories(userId: userId);

      return {
        'user': user?.toJson(),
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
        'export_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error exporting user data: $e');
      return {};
    }
  }

  /// Close database connection
  static Future<void> closeDatabase() async {
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  /// Delete entire database (for testing)
  static Future<void> deleteDatabase() async {
    try {
      String path = join(await getDatabasesPath(), _databaseName);
      await databaseFactory.deleteDatabase(path);
      _database = null;
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}
