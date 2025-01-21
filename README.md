# Portfolio Tracker
A Flutter application for tracking investment assets and their performance.

## Purpose
The app allows users to track multiple assets (stocks, crypto, etc.) by recording buy/sell transactions and price updates. It calculates profits/losses and displays current portfolio value based on local transaction history.

## Core Functionality

### Asset Management
- Users can track multiple assets
- Each asset has:
  - Symbol (e.g., "AAPL", "BTC")
  - Name (e.g., "Apple Inc.", "Bitcoin")
  - Current price
  - Total quantity owned
  - Average purchase price
  - Total value
  - Profit/loss amount and percentage

### Transaction Types
1. **Buy**
   - Record purchase of an asset
   - Required info: symbol, name, quantity, price, date
   - Updates average purchase price and total quantity
   - Option to create new asset or use existing

2. **Sell**
   - Record sale of an asset
   - Required info: symbol, quantity, price, date
   - Updates total quantity
   - Validates sufficient quantity is available

3. **Price Update**
   - Update current price of an asset
   - Required info: symbol, price, date
   - Updates current price and profit/loss calculations

### Data Storage
- Uses SQLite (sqflite package) for local storage
- Three main components:
  1. Assets Table (assets)
     - Primary storage for asset information
     - Fields: id, symbol, name, current_price, total_quantity, average_purchase_price
  2. Transactions Table (asset_transactions)
     - Records all transaction history
     - Fields: id, asset_id, type (buy/sell/price_update), quantity, price, date
  3. Database versioning
     - Current version: 3
     - Includes automatic date format standardization
     - Handles price synchronization with latest transactions

### Views

1. **Home Screen (home_screen.dart)**
   - Total portfolio value
   - Total profit/loss
   - List of assets showing:
     - Symbol and name
     - Current price
     - Total quantity
     - Profit/loss percentage
     - Total value
     - Average purchase price

2. **Transaction History Screen (transaction_history_screen.dart)**
   - Detailed asset summary
   - Chronological list of all transactions
   - Visual indicators for transaction types:
     - Buy (↑)
     - Sell (↓)
     - Price Update (⟳)

3. **Transaction Form (transaction_form.dart)**
   - Modal bottom sheet
   - Dynamic fields based on transaction type
   - Asset selection for existing assets
   - New asset creation option
   - Date selection
   - Input validation
   - Loading state during submission

## Technical Stack
- Flutter SDK ^3.6.1
- sqflite ^2.3.0 for database
- path ^1.8.3 for database path management
- Material Design UI components

## Project Structure
```
lib/
├── main.dart                        # Application entry point
├── models/
│   ├── asset.dart                   # Asset data model
│   └── asset_transaction.dart       # Transaction data model
├── screens/
│   ├── home_screen.dart            # Main portfolio view
│   ├── transaction_form.dart        # Transaction input form
│   └── transaction_history_screen.dart # Transaction history view
└── database/
    ├── database_helper.dart         # Main database interface
    ├── database_core.dart           # Core database setup
    ├── asset_operations.dart        # Asset-specific operations
    └── transaction_operations.dart  # Transaction-specific operations
```

## Features

### Asset Management
- Create new assets through buy transactions
- Track multiple assets simultaneously
- Real-time profit/loss calculations
- Historical transaction tracking
- Current price updates

### Transaction Processing
- Validates sufficient quantity for sells
- Automatic average price calculations
- UTC-standardized transaction dates
- Transaction history with type indicators
- Support for retroactive transactions

### User Interface
- Material Design implementation
- Responsive layout
- Loading states for operations
- Error handling and user feedback
- Color-coded profit/loss indicators
- Sorted asset listings
- Detailed transaction history

## Data Flow
1. User initiates transaction via form
2. Transaction validated and processed
3. Asset record updated atomically
4. Database state maintained consistently
5. UI refreshed to show current values
6. All calculations performed locally

## Persistence
- All data stored locally in SQLite database
- No backend server required
- No internet connection needed
- Automatic database versioning
- Data persists between app launches