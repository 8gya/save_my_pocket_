# SaveMyPocket

A personal finance Flutter app for tracking expenses, managing budgets, and achieving savings goals.

## Features

- Expense and Income Tracking - Add and categorize transactions
- Budget Management - Set limits and track spending by category
- Savings Goals - Create and monitor financial targets
- Analytics - Interactive charts and financial insights
- Offline Support - Local SQLite database

## Quick Start

1. **Install Flutter** (3.0.0+)
2. **Clone & Setup**
   git clone https://github.com/yourusername/savemypocket.git
   cd savemypocket
   flutter pub get
   flutter run
   

## Key Dependencies

yaml
dependencies:
  provider: ^6.0.5      # State management
  sqflite: ^2.3.0       # Local database
  fl_chart: ^0.65.0     # Charts
  intl: ^0.18.1         # Date formatting
```

## Project Structure

lib/
├── models/            Data models (User, Transaction, Budget)
├── providers/         State management (AuthProvider)
├── screens/           UI screens (Home, Budget, Goals, etc.)
├── services/         # Database & API services
└── widgets/          # Reusable components


## App Overview

SaveMyPocket provides a comprehensive financial management experience through an intuitive interface. Start with the onboarding process to set up your profile, monthly income, and savings goals. The home dashboard displays your current balance, savings progress, and recent transactions with quick action buttons to add expenses or income. Navigate through the app using the menu to access Budget tracking (set spending limits by category with visual progress bars), Goals management (create savings targets with deadline tracking), and Reports (Charts showing spending patterns and financial insights). The app automatically calculates your financial health and offers a transfer feature to move money from your balance to savings. All data is stored locally using SQLite for offline functionality, with options to export your financial data and customize settings through the profile and settings screens.
