import 'package:flutter/material.dart';

import 'constants/product_options.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _minimumStockController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'Altro';
  String _unit = 'pezzi';
  String _location = 'Dispensa';
  DateTime? _expirationDate;

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

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final minimumStockText =
        _minimumStockController.text.trim();

    final minimumStock = minimumStockText.isEmpty
        ? null
        : double.parse(
            minimumStockText.replaceAll(',', '.'),
          );

    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'quantity': double.parse(
        _quantityController.text.replaceAll(',', '.'),
      ),
      'unit': _unit,
      'category': _category,
      'location': _location,
      'expirationDate': _expirationDate,
      'minimumStock': minimumStock,
      'notes': _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minimumStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aggiungi prodotto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // NOME
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome prodotto',
                  hintText: 'Es. Latte',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci il nome del prodotto';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // CATEGORIA
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: ProductOptions.categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // QUANTITA
              TextFormField(
                controller: _quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Quantità',
                  hintText: 'Es. 2',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci la quantità';
                  }

                  final quantity = double.tryParse(
                    value.replaceAll(',', '.'),
                  );

                  if (quantity == null || quantity <= 0) {
                    return 'Inserisci una quantità valida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // UNITA
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unità di misura',
                  prefixIcon: Icon(Icons.straighten),
                  border: OutlineInputBorder(),
                ),
                items: ProductOptions.units.map((unit) {
                  return DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _unit = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // POSIZIONE
              DropdownButtonFormField<String>(
                initialValue: _location,
                decoration: const InputDecoration(
                  labelText: 'Posizione',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: ProductOptions.locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _location = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // SCADENZA
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data di scadenza',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _expirationDate == null
                        ? 'Nessuna data selezionata'
                        : '${_expirationDate!.day.toString().padLeft(2, '0')}/'
                          '${_expirationDate!.month.toString().padLeft(2, '0')}/'
                          '${_expirationDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // SCORTA MINIMA
              TextFormField(
                controller: _minimumStockController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Scorta minima',
                  hintText: 'Es. 2',
                  prefixIcon: Icon(Icons.warning_amber_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return null;
                  }

                  final minimumStock = double.tryParse(
                    value.replaceAll(',', '.'),
                  );

                  if (minimumStock == null || minimumStock < 0) {
                    return 'Inserisci una quantità valida';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),              

              // NOTE
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Aggiungi eventuali note...',
                  prefixIcon: Icon(Icons.notes_outlined),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // SALVA
              FilledButton.icon(
                onPressed: _saveProduct,
                icon: const Icon(Icons.add),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'AGGIUNGI PRODOTTO',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}