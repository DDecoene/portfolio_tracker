import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../models/asset_transaction.dart';
import '../database/database_helper.dart';

class TransactionForm extends StatefulWidget {
  final VoidCallback onTransactionComplete;

  const TransactionForm({
    Key? key,
    required this.onTransactionComplete,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  TransactionType _type = TransactionType.buy;
  String _symbol = '';
  String _name = '';
  double _price = 0.0;
  double _quantity = 0.0;
  DateTime _date = DateTime.now();
  List<Asset> _existingAssets = [];
  Asset? _selectedAsset;
  bool _isNewAsset = true;
  bool _isSubmitting = false;  // Add loading state

  @override
  void initState() {
    super.initState();
    _loadExistingAssets();
  }

  Future<void> _loadExistingAssets() async {
    final assets = await _dbHelper.getAllAssets();
    setState(() {
      _existingAssets = assets;
    });
  }

  bool get _showQuantityField => 
      _type == TransactionType.buy || _type == TransactionType.sell;

  bool get _showNewAssetOption =>
      _type == TransactionType.buy;

  bool get _requireAssetSelection =>
      (_type == TransactionType.sell || _type == TransactionType.priceUpdate);

  void _updateSelectedAsset(Asset? asset) {
    setState(() {
      _selectedAsset = asset;
      if (asset != null) {
        _symbol = asset.symbol;
        _name = asset.name;
        _price = asset.currentPrice;
      }
    });
  }

  void _resetForm() {
    setState(() {
      _selectedAsset = null;
      _symbol = '';
      _name = '';
      _price = 0.0;
      if (_type != TransactionType.buy) {
        _isNewAsset = false;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,  // Allow tapping outside to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    try {
      late int assetId;
      
      if (_type == TransactionType.buy && _isNewAsset) {
        final newAsset = Asset(
          symbol: _symbol,
          name: _name,
          currentPrice: _price,
        );
        assetId = await _dbHelper.insertAsset(newAsset);
      } else {
        if (_selectedAsset == null) {
          _showErrorDialog('Please select an asset');
          return;
        }
        assetId = _selectedAsset!.id!;
      }

      final transaction = AssetTransaction(
        assetId: assetId,
        type: _type,
        quantity: _showQuantityField ? _quantity : null,
        price: _price,
        date: _date,
      );

      await _dbHelper.insertTransaction(transaction);
      widget.onTransactionComplete();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction saved successfully')),
        );
      }
    } on InsufficientQuantityException catch (e) {
      _showErrorDialog(e.toString());
    } catch (e) {
      _showErrorDialog('Error saving transaction: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New Transaction',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Transaction Type'),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value!;
                    _resetForm();
                  });
                },
              ),
              if (_showNewAssetOption) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isNewAsset ? 'Creating New Asset' : 'Using Existing Asset',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    Switch(
                      value: _isNewAsset,
                      onChanged: (value) {
                        setState(() {
                          _isNewAsset = value;
                          _resetForm();
                        });
                      },
                    ),
                  ],
                ),
              ],
              if ((!_isNewAsset || !_showNewAssetOption) && _existingAssets.isNotEmpty)
                DropdownButtonFormField<Asset>(
                  value: _selectedAsset,
                  decoration: const InputDecoration(labelText: 'Select Asset'),
                  items: _existingAssets.map((asset) {
                    return DropdownMenuItem(
                      value: asset,
                      child: Text('${asset.symbol} - ${asset.name}'),
                    );
                  }).toList(),
                  validator: (value) {
                    if (_requireAssetSelection && value == null) {
                      return 'Please select an asset';
                    }
                    return null;
                  },
                  onChanged: _updateSelectedAsset,
                ),
              if (_isNewAsset && _showNewAssetOption) ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Symbol'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a symbol';
                    }
                    return null;
                  },
                  onSaved: (value) => _symbol = value!.toUpperCase(),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
              ],
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  prefixText: '\$',
                ),
                initialValue: _selectedAsset?.currentPrice.toString(),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              if (_showQuantityField)
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                  onSaved: (value) => _quantity = double.parse(value!),
                ),
              ListTile(
                title: const Text('Transaction Date'),
                subtitle: Text(
                  '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Transaction'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}