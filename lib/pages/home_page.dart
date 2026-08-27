import 'package:flutter/material.dart';

import '../models/food_product.dart';
import '../models/shopping_item.dart';
import '../services/inventory_repository.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final InventoryRepository _repository = InventoryRepository();

  List<FoodProduct> _expiringProducts = [];
  List<FoodProduct> _lowStockProducts = [];
  List<ShoppingItem> _shoppingItems = [];

  int _totalProducts = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> refresh() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    final products = await _repository.getProducts();
    final expiring = await _repository.getExpiringProducts();
    final lowStock = await _repository.getLowStockProducts();
    final shoppingItems = await _repository.getShoppingItems();

    if (!mounted) return;

    setState(() {
      _totalProducts = products.length;
      _expiringProducts = expiring;
      _lowStockProducts = lowStock;
      _shoppingItems = shoppingItems;
      _isLoading = false;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _expirationLabel(DateTime date) {
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

    final difference = expiration.difference(today).inDays;

    if (difference < 0) {
      return 'Scaduto';
    }

    if (difference == 0) {
      return 'Oggi';
    }

    if (difference == 1) {
      return 'Domani';
    }

    return 'Tra $difference giorni';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          100,
        ),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Inventory Home',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            'Ciao! 👋',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Ecco la situazione della tua dispensa.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  value: '$_totalProducts',
                  label: 'Prodotti',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  icon: Icons.warning_amber_outlined,
                  value: '${_expiringProducts.length}',
                  label: 'In scadenza',
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          if (_expiringProducts.isNotEmpty) ...[
            const _SectionTitle(
              icon: Icons.schedule,
              title: 'Da consumare',
            ),

            const SizedBox(height: 12),

            ..._expiringProducts.map(
              (product) => _ProductExpirationCard(
                product: product,
                expirationLabel: _expirationLabel(
                  product.expirationDate!,
                ),
                formattedDate: _formatDate(
                  product.expirationDate,
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],

          if (_lowStockProducts.isNotEmpty) ...[
            const _SectionTitle(
              icon: Icons.shopping_cart_outlined,
              title: 'Sotto scorta',
            ),

            const SizedBox(height: 12),

            ..._lowStockProducts.map(
              (product) => _LowStockCard(
                product: product,
              ),
            ),

            const SizedBox(height: 28),
          ],

          const _SectionTitle(
            icon: Icons.shopping_cart_outlined,
            title: 'Lista della spesa',
          ),

          const SizedBox(height: 12),

          if (_shoppingItems.isEmpty)
            _EmptyCard(
              text: 'La lista della spesa è vuota.',
            )
          else
            ..._shoppingItems.map(
              (item) => _ShoppingCard(
                item: item,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

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
        Icon(icon, size: 22),
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

class _ProductExpirationCard extends StatelessWidget {
  final FoodProduct product;
  final String expirationLabel;
  final String formattedDate;

  const _ProductExpirationCard({
    required this.product,
    required this.expirationLabel,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = expirationLabel == 'Scaduto';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isExpired
                  ? Colors.red.shade100
                  : Colors.green.shade100,
            ),
            child: Icon(
              Icons.fastfood_outlined,
              color: isExpired
                  ? Colors.red.shade700
                  : Colors.green.shade700,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${product.quantity} ${product.unit}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expirationLabel,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isExpired ? Colors.red : null,
                ),
              ),
              if (expirationLabel != 'Oggi' &&
                  expirationLabel != 'Domani' &&
                  expirationLabel != 'Scaduto')
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LowStockCard extends StatelessWidget {
  final FoodProduct product;

  const _LowStockCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '${product.name} — '
              '${product.quantity} ${product.unit}',
            ),
          ),
          Text(
            'Min. ${product.minimumStock}',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingCard extends StatelessWidget {
  final ShoppingItem item;

  const _ShoppingCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Icon(
            item.purchased
                ? Icons.check_box
                : Icons.check_box_outline_blank,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                decoration: item.purchased
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          if (item.quantity != null)
            Text(
              '${item.quantity} ${item.unit ?? ''}',
            ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({
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