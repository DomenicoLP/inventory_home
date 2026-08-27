import 'package:flutter/material.dart';

import '../models/food_product.dart';
import '../models/shopping_item.dart';
import '../services/inventory_repository.dart';

class ShoppingPage extends StatefulWidget {
  const ShoppingPage({super.key});

  @override
  State<ShoppingPage> createState() => _ShoppingPageState();
}

class _ShoppingPageState extends State<ShoppingPage> {
  final InventoryRepository _repository = InventoryRepository();

  List<ShoppingItem> _items = [];
  bool _isLoading = true;

  final List<String> _categories = [
    'Frutta e verdura',
    'Latticini',
    'Carne',
    'Pesce',
    'Pasta e cereali',
    'Conserve',
    'Bevande',
    'Surgelati',
    'Snack',
    'Altro',
  ];

  final List<String> _units = [
    'pezzi',
    'g',
    'kg',
    'ml',
    'litri',
    'confezioni',
    'scatolette',
  ];

  final List<String> _locations = [
    'Dispensa',
    'Frigo',
    'Freezer',
  ];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  // ============================================================
  // LOAD
  // ============================================================

  Future<void> _loadItems() async {
    final items = await _repository.getShoppingItems();

    if (!mounted) return;

    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  // ============================================================
  // ADD SHOPPING ITEM
  // ============================================================

  Future<void> _showAddItemDialog() async {
    final nameController = TextEditingController();
    final quantityController = TextEditingController();
    final notesController = TextEditingController();

    String? selectedUnit = 'pezzi';

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Aggiungi prodotto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Prodotto',
                        prefixIcon: Icon(
                          Icons.shopping_basket_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantità',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unità',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUnit = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('ANNULLA'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      return;
                    }

                    final quantityText =
                        quantityController.text.trim();

                    final quantity = quantityText.isEmpty
                        ? null
                        : double.tryParse(
                            quantityText.replaceAll(',', '.'),
                          );

                    final item = ShoppingItem(
                      name: name,
                      quantity: quantity,
                      unit: selectedUnit,
                      notes:
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                    );

                    await _repository.addShoppingItem(item);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('AGGIUNGI'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    quantityController.dispose();
    notesController.dispose();

    if (result == true) {
      await _loadItems();
    }
  }

  // ============================================================
  // EDIT SHOPPING ITEM
  // ============================================================

  Future<void> _showEditItemDialog(
    ShoppingItem item,
  ) async {
    final nameController = TextEditingController(
      text: item.name,
    );

    final quantityController = TextEditingController(
      text: item.quantity?.toString() ?? '',
    );

    final notesController = TextEditingController(
      text: item.notes ?? '',
    );

    String? selectedUnit = item.unit;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifica prodotto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Prodotto',
                        prefixIcon: Icon(
                          Icons.shopping_basket_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantità',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unità',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedUnit = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        prefixIcon: Icon(
                          Icons.notes_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('ANNULLA'),
                ),
                FilledButton(
                  onPressed: () async {
                    final name = nameController.text.trim();

                    if (name.isEmpty) {
                      return;
                    }

                    final quantityText =
                        quantityController.text.trim();

                    final quantity = quantityText.isEmpty
                        ? null
                        : double.tryParse(
                            quantityText.replaceAll(',', '.'),
                          );

                    final updatedItem = item.copyWith(
                      name: name,
                      quantity: quantity,
                      unit: selectedUnit,
                      notes:
                          notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                    );

                    await _repository.updateShoppingItem(
                      updatedItem,
                    );

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('SALVA'),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    quantityController.dispose();
    notesController.dispose();

    if (result == true) {
      await _loadItems();
    }
  }

  // ============================================================
  // ADD PURCHASED ITEM TO PANTRY
  // ============================================================

  Future<void> _showAddToPantryDialog(
    ShoppingItem item,
  ) async {
    final quantityController = TextEditingController(
      text: item.quantity?.toString() ?? '',
    );

    final minimumStockController = TextEditingController();

    String selectedCategory = 'Altro';
    String selectedUnit = item.unit ?? 'pezzi';
    String selectedLocation = 'Dispensa';

    DateTime? expirationDate;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Aggiungi alla dispensa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // NOME
                    TextFormField(
                      initialValue: item.name,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Nome prodotto',
                        prefixIcon: Icon(
                          Icons.inventory_2_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CATEGORIA
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedCategory = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // QUANTITÀ
                    TextField(
                      controller: quantityController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Quantità',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // UNITÀ
                    DropdownButtonFormField<String>(
                      initialValue: selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unità di misura',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedUnit = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // POSIZIONE
                    DropdownButtonFormField<String>(
                      initialValue: selectedLocation,
                      decoration: const InputDecoration(
                        labelText: 'Posizione',
                        prefixIcon: Icon(
                          Icons.location_on_outlined,
                        ),
                      ),
                      items: _locations.map((location) {
                        return DropdownMenuItem(
                          value: location,
                          child: Text(location),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedLocation = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // SCADENZA
                    InkWell(
                      onTap: () async {
                        final selectedDate =
                            await showDatePicker(
                          context: context,
                          initialDate:
                              expirationDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now().add(
                            const Duration(days: 3650),
                          ),
                        );

                        if (selectedDate != null) {
                          setDialogState(() {
                            expirationDate = selectedDate;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data di scadenza',
                          prefixIcon: Icon(
                            Icons.calendar_month_outlined,
                          ),
                        ),
                        child: Text(
                          expirationDate == null
                              ? 'Nessuna data selezionata'
                              : '${expirationDate!.day.toString().padLeft(2, '0')}/'
                                  '${expirationDate!.month.toString().padLeft(2, '0')}/'
                                  '${expirationDate!.year}',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SCORTA MINIMA
                    TextField(
                      controller: minimumStockController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Scorta minima (opzionale)',
                        prefixIcon: Icon(
                          Icons.warning_amber_outlined,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('ANNULLA'),
                ),
                FilledButton(
                  onPressed: () async {
                    final quantity = double.tryParse(
                      quantityController.text
                          .trim()
                          .replaceAll(',', '.'),
                    );

                    if (quantity == null || quantity <= 0) {
                      return;
                    }

                    final minimumStockText =
                        minimumStockController.text.trim();

                    final minimumStock =
                        minimumStockText.isEmpty
                            ? null
                            : double.tryParse(
                                minimumStockText
                                    .replaceAll(',', '.'),
                              );

                    final product = FoodProduct(
                      name: item.name,
                      category: selectedCategory,
                      quantity: quantity,
                      unit: selectedUnit,
                      location: selectedLocation,
                      expirationDate: expirationDate,
                      minimumStock: minimumStock,
                    );

                    await _repository.addProduct(product);

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('AGGIUNGI'),
                ),
              ],
            );
          },
        );
      },
    );

    quantityController.dispose();
    minimumStockController.dispose();

    if (result == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.name} aggiunto alla dispensa.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // TOGGLE PURCHASED
  // ============================================================

  Future<void> _togglePurchased(
    ShoppingItem item,
  ) async {
    final updatedItem = item.copyWith(
      purchased: !item.purchased,
    );

    await _repository.updateShoppingItem(
      updatedItem,
    );

    await _loadItems();
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteItem(
    ShoppingItem item,
  ) async {
    if (item.id == null) {
      return;
    }

    await _repository.deleteShoppingItem(
      item.id!,
    );

    await _loadItems();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final pendingItems = _items
        .where((item) => !item.purchased)
        .toList();

    final purchasedItems = _items
        .where((item) => item.purchased)
        .toList();

    final remaining = pendingItems.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Lista della spesa',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddItemDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Aggiungi prodotto',
          ),
        ],
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadItems,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            children: [
              Text(
                '$remaining prodotti da acquistare',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // DA ACQUISTARE
              // ==================================================

              if (pendingItems.isNotEmpty) ...[
                const _SectionTitle(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Da acquistare',
                ),

                const SizedBox(height: 12),

                ...pendingItems.map(
                  (item) => _ShoppingItemCard(
                    item: item,
                    onToggle: () => _togglePurchased(item),
                    onEdit: () => _showEditItemDialog(item),
                    onDelete: () => _deleteItem(item),
                  ),
                ),

                const SizedBox(height: 28),
              ],

              // ==================================================
              // ACQUISTATI
              // ==================================================

              if (purchasedItems.isNotEmpty) ...[
                const _SectionTitle(
                  icon: Icons.check_circle_outline,
                  title: 'Acquistati',
                ),

                const SizedBox(height: 12),

                ...purchasedItems.map(
                  (item) => _ShoppingItemCard(
                    item: item,
                    onToggle: () => _togglePurchased(item),
                    onEdit: () => _showEditItemDialog(item),
                    onDelete: () => _deleteItem(item),
                    onAddToPantry: () =>
                        _showAddToPantryDialog(item),
                  ),
                ),
              ],

              // ==================================================
              // LISTA VUOTA
              // ==================================================

              if (_items.isEmpty)
                const _EmptyShoppingCard(
                  text: 'La lista della spesa è vuota.',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SHOPPING ITEM CARD
// ============================================================

class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAddToPantry;

  const _ShoppingItemCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onAddToPantry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 8,
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.purchased,
          onChanged: (_) {
            onToggle();
          },
        ),

        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: item.purchased
                ? TextDecoration.lineThrough
                : null,
          ),
        ),

        subtitle: item.quantity != null
            ? Text(
                '${item.quantity} ${item.unit ?? ''}',
              )
            : null,

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.purchased && onAddToPantry != null)
              IconButton(
                onPressed: onAddToPantry,
                icon: const Icon(
                  Icons.add_box_outlined,
                ),
                tooltip: 'Aggiungi alla dispensa',
              ),

            IconButton(
              onPressed: onEdit,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              tooltip: 'Modifica',
            ),

            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline,
              ),
              tooltip: 'Elimina',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY CARD
// ============================================================

class _EmptyShoppingCard extends StatelessWidget {
  final String text;

  const _EmptyShoppingCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}