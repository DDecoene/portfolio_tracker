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
  bool _isSubmitting = false;

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
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
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, 
                color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              const Text('Error'),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
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
          SnackBar(
            content: const Text('Transaction saved successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
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

  InputDecoration _getInputDecoration(String label, [Widget? prefix]) {
    return InputDecoration(
      labelText: label,
      prefix: prefix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'New Transaction',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<TransactionType>(
                value: _type,
                decoration: _getInputDecoration('Transaction Type'),
                items: TransactionType.values.map((type) {
                  IconData icon;
                  switch (type) {
                    case TransactionType.buy:
                      icon = Icons.add_circle_outline;
                      break;
                    case TransactionType.sell:
                      icon = Icons.remove_circle_outline;
                      break;
                    case TransactionType.priceUpdate:
                      icon = Icons.update;
                      break;
                  }
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(type.toString().split('.').last.toUpperCase()),
                      ],
                    ),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Asset Type',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _isNewAsset ? 'Creating New Asset' : 'Using Existing Asset',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
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
                ),
              ],
              const SizedBox(height: 16),
              if ((!_isNewAsset || !_showNewAssetOption) && _existingAssets.isNotEmpty)
                DropdownButtonFormField<Asset>(
                  value: _selectedAsset,
                  decoration: _getInputDecoration('Select Asset'),
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
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _getInputDecoration('Symbol'),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a symbol';
                    }
                    return null;
                  },
                  onSaved: (value) => _symbol = value!.toUpperCase(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _getInputDecoration('Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onSaved: (value) => _name = value!,
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                decoration: _getInputDecoration('Price', 
                  Text('\$', style: TextStyle(color: colorScheme.onSurface))),
                initialValue: _selectedAsset?.currentPrice.toString(),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              if (_showQuantityField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: _getInputDecoration('Quantity'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
              ],
              const SizedBox(height: 16),
              InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Transaction Date',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Icon(Icons.calendar_today, 
                        color: colorScheme.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting 
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Text('Save Transaction',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}