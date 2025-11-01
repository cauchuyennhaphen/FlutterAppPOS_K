import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_item.dart';
import '../models/cart_model.dart';
import 'order_screen.dart';

class MenuScreen extends StatefulWidget {
  final bool closeOnAdd;
  const MenuScreen({super.key, this.closeOnAdd = false});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late List<OrderItem> products;
  late NumberFormat _numFmt;

  @override
  void initState() {
    super.initState();
    _numFmt = NumberFormat.decimalPattern('en_US');

    products = <OrderItem>[
      OrderItem(id: '1', name: 'sữa cacao', unitPrice: 18000, category: ItemCategory.drink),
      OrderItem(id: '2', name: 'sữa nóng', unitPrice: 15000, category: ItemCategory.drink),
      OrderItem(id: '3', name: 'pepsi lon', unitPrice: 15000, category: ItemCategory.drink),
      OrderItem(id: '5', name: 'dưa hấu ép', unitPrice: 20000, category: ItemCategory.drink),
      OrderItem(id: '6', name: 'phở bò', unitPrice: 60000, category: ItemCategory.food),
      OrderItem(id: '7', name: 'cơm sườn', unitPrice: 50000, category: ItemCategory.food),
      OrderItem(id: '8', name: 'khăn giấy', unitPrice: 2000, category: ItemCategory.other),
    ];

    // Load persisted products (if any)
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = sp.getString('menu_products');
      if (s != null && s.isNotEmpty) {
        final List<dynamic> data = jsonDecode(s);
        final loaded = data.map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e))).toList();
        setState(() {
          products = loaded;
        });
      }
    } catch (e) {
      // ignore and keep defaults
    }
  }

  Future<void> _saveProducts() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final s = jsonEncode(products.map((p) => p.toJson()).toList());
      await sp.setString('menu_products', s);
    } catch (e) {
      // ignore
    }
  }

  List<OrderItem> _filteredForCategory(ItemCategory c) => products.where((p) => p.category == c).toList();

  void _showAddItemDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    ItemCategory selected = ItemCategory.food;
    bool isFormatting = false;

    // Format price input with thousand separators (commas)
    priceCtrl.addListener(() {
      if (isFormatting) return;
      final raw = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (raw.isEmpty) return;
      final v = int.tryParse(raw) ?? 0;
      final formatted = _numFmt.format(v);
      if (formatted != priceCtrl.text) {
        isFormatting = true;
        priceCtrl.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
        isFormatting = false;
      }
    });

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState2) {
          return AlertDialog(
            title: const Text('Thêm món mới'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên')),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Giá (VND)'), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  DropdownButton<ItemCategory>(
                    value: selected,
                    items: const [
                      DropdownMenuItem(value: ItemCategory.food, child: Text('Thức ăn')),
                      DropdownMenuItem(value: ItemCategory.drink, child: Text('Nước uống')),
                      DropdownMenuItem(value: ItemCategory.other, child: Text('Khác')),
                    ],
                    onChanged: (v) => setState2(() => selected = v ?? ItemCategory.other),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final digits = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                  final price = int.tryParse(digits) ?? 0;
                  if (name.isEmpty || price <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên và giá hợp lệ')));
                    return;
                  }
                  final id = DateTime.now().microsecondsSinceEpoch.toString();
                  setState(() {
                    products.add(OrderItem(id: id, name: name, unitPrice: price, category: selected));
                  });
                  _saveProducts();
                  Navigator.of(ctx).pop();
                },
                child: const Text('Thêm'),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Menu đồ ăn'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Thức ăn'),
              Tab(text: 'Nước uống'),
              Tab(text: 'Khác'),
            ],
          ),
          actions: [
            // Table picker
            Consumer<CartModel>(builder: (context, cart, _) {
              return IconButton(
                icon: const Icon(Icons.table_bar),
                tooltip: 'Chọn bàn',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (ctx) {
                      return SizedBox(
                        height: 320,
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Chọn bàn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            Expanded(
                              child: GridView.builder(
                                padding: const EdgeInsets.all(12),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.0),
                                itemCount: 20,
                                itemBuilder: (c, i) {
                                  final table = 'Bàn ${i + 1}';
                                  final selected = cart.selectedTable == table;
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: selected ? Colors.red : Colors.white, foregroundColor: selected ? Colors.white : Colors.black),
                                    onPressed: () {
                                      Provider.of<CartModel>(context, listen: false).setSelectedTable(table);
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chọn $table')));
                                    },
                                    child: Text('B${i + 1}'),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }),

            // Cart icon with badge
            Consumer<CartModel>(builder: (context, cart, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const OrderScreen())),
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                        child: Text(cart.items.length.toString(), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    )
                ],
              );
            })
          ],
        ),
        body: TabBarView(
          children: [
            _buildListViewForCategory(ItemCategory.food),
            _buildListViewForCategory(ItemCategory.drink),
            _buildListViewForCategory(ItemCategory.other),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddItemDialog,
          tooltip: 'Thêm đồ',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildListViewForCategory(ItemCategory c) {
    final list = _filteredForCategory(c);
    if (list.isEmpty) {
      return Center(child: Text('Không có ${c == ItemCategory.food ? 'thức ăn' : c == ItemCategory.drink ? 'nước uống' : 'món khác'}'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (ctx, i) {
        final p = list[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.fastfood, size: 36, color: Colors.red),
                const SizedBox(width: 12),
                Expanded(child: Text(p.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${p.unitPrice} VND', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                            final selected = OrderItem(id: p.id, name: p.name, unitPrice: p.unitPrice, quantity: 1, category: p.category);
                            if (widget.closeOnAdd) {
                              Navigator.of(context).pop(selected);
                            } else {
                              Provider.of<CartModel>(context, listen: false).addItem(selected);
                              final snack = SnackBar(content: Text('${p.name} đã thêm vào giỏ'));
                              ScaffoldMessenger.of(context).showSnackBar(snack);
                            }
                          },
                      child: const Text('Thêm'),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
