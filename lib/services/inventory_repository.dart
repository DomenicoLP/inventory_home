import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/food_product.dart';
import '../models/shopping_item.dart';

class InventoryRepository {
  static const String _productsKey = 'inventory_products';
  static const String _shoppingItemsKey = 'shopping_items';
  static const String _weeklyPlanKey = 'weekly_plan';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // ==========================================================
  // PRODUCTS
  // ==========================================================

  Future<List<FoodProduct>> getProducts() async {
    final data = await _prefs.getString(_productsKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);

      return decoded
          .map(
            (item) => FoodProduct.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<FoodProduct> addProduct(FoodProduct product) async {
    final products = await getProducts();

    final newId = _nextProductId(products);

    final newProduct = product.copyWith(
      id: newId,
    );

    products.add(newProduct);

    await _saveProducts(products);

    return newProduct;
  }

  Future<void> updateProduct(FoodProduct product) async {
    final products = await getProducts();

    final index = products.indexWhere(
      (item) => item.id == product.id,
    );

    if (index == -1) {
      return;
    }

    products[index] = product;

    await _saveProducts(products);
  }

  Future<void> deleteProduct(int id) async {
    final products = await getProducts();

    products.removeWhere(
      (product) => product.id == id,
    );

    await _saveProducts(products);
  }

  Future<void> _saveProducts(
    List<FoodProduct> products,
  ) async {
    final data = jsonEncode(
      products.map((product) => product.toMap()).toList(),
    );

    await _prefs.setString(
      _productsKey,
      data,
    );
  }

  int _nextProductId(List<FoodProduct> products) {
    if (products.isEmpty) {
      return 1;
    }

    return products
            .map((product) => product.id ?? 0)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  // ==========================================================
  // SHOPPING LIST
  // ==========================================================

  Future<List<ShoppingItem>> getShoppingItems() async {
    final data = await _prefs.getString(_shoppingItemsKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(data);

      return decoded
          .map(
            (item) => ShoppingItem.fromMap(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ShoppingItem> addShoppingItem(
    ShoppingItem item,
  ) async {
    final items = await getShoppingItems();

    final newId = _nextShoppingId(items);

    final newItem = item.copyWith(
      id: newId,
    );

    items.add(newItem);

    await _saveShoppingItems(items);

    return newItem;
  }

  Future<void> updateShoppingItem(
    ShoppingItem item,
  ) async {
    final items = await getShoppingItems();

    final index = items.indexWhere(
      (existing) => existing.id == item.id,
    );

    if (index == -1) {
      return;
    }

    items[index] = item;

    await _saveShoppingItems(items);
  }

  Future<void> deleteShoppingItem(int id) async {
    final items = await getShoppingItems();

    items.removeWhere(
      (item) => item.id == id,
    );

    await _saveShoppingItems(items);
  }

  Future<void> _saveShoppingItems(
    List<ShoppingItem> items,
  ) async {
    final data = jsonEncode(
      items.map((item) => item.toMap()).toList(),
    );

    await _prefs.setString(
      _shoppingItemsKey,
      data,
    );
  }

  int _nextShoppingId(List<ShoppingItem> items) {
    if (items.isEmpty) {
      return 1;
    }

    return items
            .map((item) => item.id ?? 0)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  Future<List<FoodProduct>> getExpiringProducts({
    int days = 7,
  }) async {
    final products = await getProducts();

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final limit = today.add(
      Duration(days: days),
    );

    return products.where((product) {
      final expirationDate = product.expirationDate;

      if (expirationDate == null) {
        return false;
      }

      final expirationDay = DateTime(
        expirationDate.year,
        expirationDate.month,
        expirationDate.day,
      );

      return !expirationDay.isAfter(limit);
    }).toList()
      ..sort((a, b) {
        final dateA = a.expirationDate!;
        final dateB = b.expirationDate!;

        return dateA.compareTo(dateB);
      });
  }

  Future<List<FoodProduct>> getLowStockProducts() async {
    final products = await getProducts();

    return products.where((product) {
      final minimumStock = product.minimumStock;

      if (minimumStock == null) {
        return false;
      }

      return product.quantity <= minimumStock;
    }).toList();
  }

  // ==========================================================
  // WEEKLY PLAN
  // ==========================================================

  Future<Map<String, String>> getDailyPlan(String day) async {
    final data = await _prefs.getString(_weeklyPlanKey);

    if (data == null || data.isEmpty) {
      return {};
    }

    try {
      final decoded = jsonDecode(data);

      if (decoded is! Map) {
        return {};
      }

      final dayData = decoded[day];

      if (dayData is! Map) {
        return {};
      }

      return Map<String, String>.from(dayData);
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDailyPlan({
    required String day,
    required Map<String, String> meals,
  }) async {
    final data = await _prefs.getString(_weeklyPlanKey);

    Map<String, dynamic> weeklyPlan = {};

    if (data != null && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);

        if (decoded is Map) {
          weeklyPlan = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        weeklyPlan = {};
      }
    }

    weeklyPlan[day] = meals;

    await _prefs.setString(
      _weeklyPlanKey,
      jsonEncode(weeklyPlan),
    );
  }
  
}