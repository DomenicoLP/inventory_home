import 'package:flutter/material.dart';

import '../add_product_page.dart';
import '../constants/product_options.dart';
import '../models/food_product.dart';
import '../services/inventory_repository.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({
    super.key,
  });

  @override
  State<PantryPage> createState() => PantryPageState();
}

class PantryPageState extends State<PantryPage> {
  final InventoryRepository _repository = InventoryRepository();
  final TextEditingController _searchController =
      TextEditingController();

  List<FoodProduct> _products = [];
  String _selectedCategory = 'Tutti';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final products = await _repository.getProducts();

    if (!mounted) return;

    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  Future<void> refresh() async {
    await _loadProducts();
  }

  List<String> get _categories {
    final categories = _products
        .map((product) => product.category)
        .where((category) => category.trim().isNotEmpty)
        .toSet()
        .toList();

    categories.sort();

    return [
      'Tutti',
      ...categories,
    ];
  }

  List<FoodProduct> get _filteredProducts {
    final search = _searchController.text.trim().toLowerCase();

    return _products.where((product) {
      final matchesSearch =
          search.isEmpty ||
          product.name.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search);

      final matchesCategory =
          _selectedCategory == 'Tutti' ||
          product.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  Future<void> _changeQuantity(
    FoodProduct product,
    double amount,
  ) async {
    final newQuantity = product.quantity + amount;

    if (newQuantity < 0) {
      return;
    }

    final updatedProduct = product.copyWith(
      quantity: newQuantity,
    );

    await _repository.updateProduct(updatedProduct);

    if (!mounted) return;

    setState(() {
      final index = _products.indexWhere(
        (item) => item.id == product.id,
      );

      if (index != -1) {
        _products[index] = updatedProduct;
      }
    });
  }

  Future<void> _deleteProduct(
    FoodProduct product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Eliminare prodotto?'),
          content: Text(
            'Vuoi eliminare "${product.name}" dalla dispensa?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || product.id == null) {
      return;
    }

    await _repository.deleteProduct(product.id!);

    if (!mounted) return;

    setState(() {
      _products.removeWhere(
        (item) => item.id == product.id,
      );
    });
  }

  Future<void> _editProduct(
    FoodProduct product,
  ) async {
    final updatedProduct = await showDialog<FoodProduct>(
      context: context,
      builder: (context) {
        return _EditProductDialog(
          product: product,
        );
      },
    );

    if (updatedProduct == null) {
      return;
    }

    await _repository.updateProduct(updatedProduct);

    if (!mounted) return;

    setState(() {
      final index = _products.indexWhere(
        (item) => item.id == product.id,
      );

      if (index != -1) {
        _products[index] = updatedProduct;
      }
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Nessuna scadenza';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _expirationText(DateTime? date) {
    if (date == null) {
      return 'Nessuna scadenza';
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiration = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final days = expiration.difference(today).inDays;

    if (days < 0) {
      return 'Scaduto il ${_formatDate(date)}';
    }

    if (days == 0) {
      return 'Scade oggi';
    }

    if (days == 1) {
      return 'Scade domani';
    }

    return 'Scade tra $days giorni';
  }

  Color _expirationColor(DateTime? date) {
    if (date == null) {
      return Colors.grey;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final expiration = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final days = expiration.difference(today).inDays;

    if (days < 0) {
      return Colors.red;
    }

    if (days <= 3) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispensa'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadProducts,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  100,
                ),
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cerca prodotto...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _categories.map((category) {
                        final selected =
                            category == _selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 8,
                          ),
                          child: FilterChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (filteredProducts.isEmpty)
                    _EmptyPantry(
                      hasProducts: _products.isNotEmpty,
                    )
                  else
                    ...filteredProducts.map(
                      (product) => _ProductCard(
                        product: product,
                        expirationText:
                            _expirationText(
                          product.expirationDate,
                        ),
                        expirationColor:
                            _expirationColor(
                          product.expirationDate,
                        ),
                        onIncrease: () {
                          _changeQuantity(
                            product,
                            1,
                          );
                        },
                        onDecrease: () {
                          _changeQuantity(
                            product,
                            -1,
                          );
                        },
                        onEdit: () {
                          _editProduct(product);
                        },
                        onDelete: () {
                          _deleteProduct(product);
                        },
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddProductPage(),
      ),
    );

    if (result == null) {
      return;
    }

    final product = FoodProduct(
      name: result['name'] as String,
      category: result['category'] as String,
      quantity: (result['quantity'] as num).toDouble(),
      unit: result['unit'] as String,
      location: result['location'] as String,
      expirationDate: result['expirationDate'] as DateTime?,
      minimumStock: result['minimumStock'] as double?,
      notes: result['notes'] as String?,
    );

    final savedProduct = await _repository.addProduct(product);

    if (!mounted) {
      return;
    }

    setState(() {
      _products.add(savedProduct);
    });
  }
}

class _ProductCard extends StatelessWidget {
  final FoodProduct product;
  final String expirationText;
  final Color expirationColor;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.expirationText,
    required this.expirationColor,
    required this.onIncrease,
    required this.onDecrease,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        product.minimumStock != null &&
        product.quantity <= product.minimumStock!;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.fastfood_outlined,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${product.category} • '
                        '${product.location}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    }

                    if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Modifica'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Elimina'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                IconButton(
                  onPressed: product.quantity > 0
                      ? onDecrease
                      : null,
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                ),

                Text(
                  '${product.quantity} ${product.unit}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                ),

                const Spacer(),

                if (isLowStock)
                  const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),

                Flexible(
                  child: Text(
                    expirationText,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: expirationColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPantry extends StatelessWidget {
  final bool hasProducts;

  const _EmptyPantry({
    required this.hasProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            hasProducts
                ? Icons.search_off
                : Icons.inventory_2_outlined,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasProducts
                ? 'Nessun prodotto trovato.'
                : 'La dispensa è vuota.',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final FoodProduct product;

  const _EditProductDialog({
    required this.product,
  });

  @override
  State<_EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState
    extends State<_EditProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _minimumStockController;
  late final TextEditingController _notesController;

  late String _category;
  late String _unit;
  late String _location;
  DateTime? _expirationDate;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.product.name,
    );

    _quantityController = TextEditingController(
      text: widget.product.quantity.toString(),
    );

    _minimumStockController = TextEditingController(
      text: widget.product.minimumStock?.toString() ?? '',
    );

    _notesController = TextEditingController(
      text: widget.product.notes ?? '',
    );

    _category = widget.product.category;
    _unit = widget.product.unit;
    _location = widget.product.location;
    _expirationDate = widget.product.expirationDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 3650),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _expirationDate = selectedDate;
      });
    }
  }

  void _save() {
    final name = _nameController.text.trim();

    final quantity = double.tryParse(
      _quantityController.text.replaceAll(',', '.'),
    );

    final minimumStockText =
        _minimumStockController.text.trim();

    final minimumStock = minimumStockText.isEmpty
        ? null
        : double.tryParse(
            minimumStockText.replaceAll(',', '.'),
          );

    if (name.isEmpty ||
        quantity == null ||
        quantity < 0 ||
        (minimumStockText.isNotEmpty &&
            (minimumStock == null || minimumStock < 0))) {
      return;
    }

    Navigator.pop(
      context,
      widget.product.copyWith(
        name: name,
        category: _category,
        quantity: quantity,
        unit: _unit,
        location: _location,
        expirationDate: _expirationDate,
        minimumStock: minimumStock,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Nessuna data selezionata';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifica prodotto'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // NOME
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome prodotto',
              ),
            ),

            const SizedBox(height: 12),

            // CATEGORIA
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Categoria',
              ),
              items: ProductOptions.categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _category = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // QUANTITÀ
            TextField(
              controller: _quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                    'Quantità (${widget.product.unit})',
              ),
            ),

            const SizedBox(height: 12),

            // UNITÀ
            DropdownButtonFormField<String>(
              initialValue: _unit,
              decoration: const InputDecoration(
                labelText: 'Unità di misura',
              ),
              items: ProductOptions.units.map((unit) {
                return DropdownMenuItem<String>(
                  value: unit,
                  child: Text(unit),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _unit = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // POSIZIONE
            DropdownButtonFormField<String>(
              initialValue: _location,
              decoration: const InputDecoration(
                labelText: 'Posizione',
              ),
              items: ProductOptions.locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  _location = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // SCADENZA
            InkWell(
              onTap: _selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Data di scadenza',
                  prefixIcon:
                      Icon(Icons.calendar_month_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _formatDate(_expirationDate),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // SCORTA MINIMA
            TextField(
              controller: _minimumStockController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Scorta minima',
              ),
            ),

            const SizedBox(height: 12),

            // NOTE
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note',
                hintText: 'Aggiungi una nota...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Salva'),
        ),
      ],
    );
  }
}