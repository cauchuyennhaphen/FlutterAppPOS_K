import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import 'order_item.dart';

class CartModel extends ChangeNotifier {
  final List<OrderItem> _items = [];
  String? _selectedTable;
  // Orders stored per table
  final Map<String, List<OrderItem>> _tableOrders = {};
  // Number of guests per table (when selected or assigned)
  final Map<String, int> _guestsPerTable = {};

  // Reservations per table
  final Map<String, Reservation> _reservations = {};

  // Preparation queue: each entry represents a chunk to prepare
  final List<PrepEntry> _prepQueue = [];

  // Ready items per table (items that finished preparation and are ready to serve)
  final Map<String, List<OrderItem>> _readyPerTable = {};

  String? get selectedTable => _selectedTable;

  void setSelectedTable(String? table) {
    _selectedTable = table;
    notifyListeners();
  }

  // Table orders
  Map<String, List<OrderItem>> get tableOrders => _tableOrders;

  List<OrderItem> getTableOrders(String table) => List.unmodifiable(_tableOrders[table] ?? []);

  bool isTableOccupied(String table) => (_tableOrders[table]?.isNotEmpty ?? false);

  void assignOrderToTable(String table, List<OrderItem> items) {
  final copy = items.map((i) => OrderItem(id: i.id, name: i.name, unitPrice: i.unitPrice, quantity: i.quantity, category: i.category)).toList();
    _tableOrders.putIfAbsent(table, () => []).addAll(copy);
    notifyListeners();
  }

  // Guests per table API
  int getGuestsForTable(String table) => _guestsPerTable[table] ?? 0;

  void setGuestsForTable(String table, int guests) {
    if (guests <= 0) {
      _guestsPerTable.remove(table);
    } else {
      _guestsPerTable[table] = guests;
    }
    notifyListeners();
    _saveGuestsPerTable();
  }

  // Reservation API
  bool isTableReserved(String table) => _reservations.containsKey(table);

  Reservation? getReservation(String table) => _reservations[table];

  void setReservation(String table, Reservation r) {
    _reservations[table] = r;
    notifyListeners();
    _saveReservations();
  }

  void clearReservation(String table) {
    _reservations.remove(table);
    notifyListeners();
    _saveReservations();
  }

  /// Hive boxes used for persistence
  static const _kReservationsBox = 'reservations';
  static const _kGuestsBox = 'guests';

  /// Load reservations and guests from Hive boxes. Boxes must be opened beforehand.
  Future<void> loadPersistentData() async {
    try {
      if (Hive.isBoxOpen(_kReservationsBox)) {
        final box = Hive.box(_kReservationsBox);
        _reservations.clear();
        for (var key in box.keys) {
          final val = box.get(key);
          if (val is Reservation) {
            _reservations['$key'] = val;
          }
        }
      }

      if (Hive.isBoxOpen(_kGuestsBox)) {
        final gbox = Hive.box(_kGuestsBox);
        _guestsPerTable.clear();
        for (var key in gbox.keys) {
          final v = gbox.get(key);
          _guestsPerTable['$key'] = (v is int) ? v : int.tryParse('$v') ?? 0;
        }
      }
    } catch (_) {
      // ignore
    }
    notifyListeners();
  }

  Future<void> _saveReservations() async {
    if (!Hive.isBoxOpen(_kReservationsBox)) return;
    final box = Hive.box(_kReservationsBox);
    // write each reservation
    for (var entry in _reservations.entries) {
      await box.put(entry.key, entry.value);
    }
  }

  Future<void> _saveGuestsPerTable() async {
    if (!Hive.isBoxOpen(_kGuestsBox)) return;
    final gbox = Hive.box(_kGuestsBox);
    for (var entry in _guestsPerTable.entries) {
      await gbox.put(entry.key, entry.value);
    }
  }

  void clearTable(String table) {
    _tableOrders.remove(table);
    _readyPerTable.remove(table);
    notifyListeners();
  }

  List<OrderItem> get items => List.unmodifiable(_items);

  void addItem(OrderItem item) {
    final existing = _items.indexWhere((i) => i.id == item.id);
    if (existing >= 0) {
      _items[existing].quantity += item.quantity;
    } else {
  _items.add(OrderItem(id: item.id, name: item.name, unitPrice: item.unitPrice, quantity: item.quantity, category: item.category));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void increaseQty(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      _items[idx].quantity++;
      notifyListeners();
    }
  }

  void decreaseQty(String id) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx >= 0) {
      if (_items[idx].quantity > 1) {
        _items[idx].quantity--; 
      } else {
        _items.removeAt(idx);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get totalRaw => _items.fold(0, (s, i) => s + i.subtotal);

  // Preparation queue API
  List<PrepEntry> get prepQueue => List.unmodifiable(_prepQueue);

  List<OrderItem> getReadyItemsForTable(String table) => List.unmodifiable(_readyPerTable[table] ?? []);

  /// Return total quantity of ordered items for a table (all orders assigned)
  int getOrderedCountForTable(String table) => _tableOrders[table]?.fold<int>(0, (s, i) => s + i.quantity) ?? 0;

  /// Return total quantity of ready items for a table
  int getReadyCountForTable(String table) => _readyPerTable[table]?.fold<int>(0, (s, i) => s + i.quantity) ?? 0;

  /// Sum subtotal for a specific table
  int getTableSubtotal(String table) => _tableOrders[table]?.fold<int>(0, (s, i) => s + i.subtotal) ?? 0;

  /// Report current cart items for preparation and assign them to the table's order list.
  void reportForPreparation(String? table, List<OrderItem> items) {
    if (table == null) return;
    if (items.isEmpty) return;

    // Add to table orders
    assignOrderToTable(table, items);

    // Add prep entries
    for (var it in items) {
      final id = DateTime.now().microsecondsSinceEpoch.toString();
      _prepQueue.add(PrepEntry(id: id, table: table, name: it.name, quantity: it.quantity));
    }
    notifyListeners();
  }

  /// Mark a prep entry as done: remove from prepQueue and move to readyPerTable
  void markPrepDone(String prepId) {
    final idx = _prepQueue.indexWhere((p) => p.id == prepId);
    if (idx < 0) return;
    final entry = _prepQueue.removeAt(idx);

    // add to ready list for table
  final readyItem = OrderItem(id: prepId, name: entry.name, unitPrice: 0, quantity: entry.quantity, category: ItemCategory.other);
    _readyPerTable.putIfAbsent(entry.table, () => []).add(readyItem);
    notifyListeners();
  }

  /// Remove a ready item from a table's ready list (when served)
  void removeReadyItem(String table, OrderItem item) {
    final list = _readyPerTable[table];
    if (list == null) return;
    list.removeWhere((i) => i.name == item.name && i.quantity == item.quantity);
    if (list.isEmpty) _readyPerTable.remove(table);
    notifyListeners();
  }

  /// Simulate a payment process. Returns true on success after delay.
  Future<bool> simulatePayment() async {
    // Simulate network / processing delay
    await Future.delayed(const Duration(seconds: 2));
    // For demo we always succeed. In real app, call API here.
    clear();
    return true;
  }
}

class PrepEntry {
  final String id;
  final String table;
  final String name;
  final int quantity;

  PrepEntry({required this.id, required this.table, required this.name, required this.quantity});
}

class Reservation {
  final String name;
  final int guests;
  final DateTime createdAt;

  Reservation({required this.name, required this.guests, DateTime? createdAt}) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'guests': guests,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> map) {
    return Reservation(
      name: map['name'] ?? '',
      guests: (map['guests'] is int) ? map['guests'] as int : int.tryParse('${map['guests']}') ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) ?? DateTime.now() : DateTime.now(),
    );
  }
}
