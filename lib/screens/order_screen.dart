import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously
// ...existing code...
import 'package:provider/provider.dart';
import '../models/cart_model.dart';
import '../models/order_item.dart';
import 'menu_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  double discountPercent = 0.0; // e.g., 0.1 for 10%
  double vatPercent = 0.05; // VAT is 5%
  bool showListedPrice = false;

  String fmt(int v) => v.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ",");

  int get listedPrice {
    final cart = Provider.of<CartModel>(context, listen: false);
    return cart.items.fold(0, (s, i) => s + i.unitPrice * i.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    final items = cart.items;
    final totalRaw = cart.totalRaw;
    final discountAmount = (totalRaw * discountPercent).round();
    final vatAmount = ((totalRaw - discountAmount) * vatPercent).round();
    final totalPayable = totalRaw - discountAmount + vatAmount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng'),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          // top quick-action buttons
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: showListedPrice ? Colors.red : Colors.white,
                        foregroundColor: showListedPrice ? Colors.white : Colors.black,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          showListedPrice = !showListedPrice;
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.price_check, color: Colors.red),
                          const SizedBox(height: 6),
                          Text('Giá niêm yết', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ),
                _quickAction(context, Icons.person, 'Khách'),
                _quickAction(context, Icons.add_box, 'Chọn món'),
              ],
            ),
          ),

          // header: bàn số / vị trí
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(cart.selectedTable ?? 'Chưa chọn bàn', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Text('Vị trí A', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // item list
          Expanded(
            child: items.isEmpty
                ? Center(child: Text('Giỏ hàng trống', style: TextStyle(color: Colors.grey[600])))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (ctx, idx) {
                      final it = items[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: const Color.fromRGBO(128,128,128,0.08), blurRadius: 4)]),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Icon(Icons.local_cafe, color: Colors.grey),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(it.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    Text('${fmt(it.unitPrice)} x ${it.quantity}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(fmt(it.subtotal), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => cart.decreaseQty(it.id)),
                                      Text('${it.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => cart.increaseQty(it.id)),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // totals panel (yellow)
          Container(
            width: double.infinity,
            color: Colors.orange.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Text('Tổng thành tiền'), const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal:6, vertical:2), decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)), child: Text(items.length.toString()))]),
                    Text(fmt(totalRaw), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                if (showListedPrice) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giá niêm yết'),
                      Text(fmt(listedPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng chiết khấu'),
                    Text('- ${fmt(discountAmount)}'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('VAT (5%)'),
                    Text(fmt(vatAmount)),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Khách phải trả', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(fmt(totalPayable), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),

          // bottom action bar
          SafeArea(
            child: Container(
              color: Colors.red,
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, padding: const EdgeInsets.symmetric(vertical: 14)),
                        onPressed: () {
                          // For now this button simply reports the current cart for preparation for the selected table
                          final cart = Provider.of<CartModel>(context, listen: false);
                          if (cart.selectedTable == null) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn bàn trước khi báo chế biến')));
                            return;
                          }
                          if (cart.items.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng rỗng')));
                            return;
                          }
                          cart.reportForPreparation(cart.selectedTable, cart.items);
                          cart.clear();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã báo chế biến')));
                        },
                      child: const Text('BÁO CHẾ BIẾN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () async {
                        final cart = Provider.of<CartModel>(context, listen: false);
                        if (cart.items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Giỏ hàng rỗng')));
                          return;
                        }

                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        showDialog<void>(
                          context: context,
                          barrierDismissible: false,
                          builder: (ctx) => const AlertDialog(
                            content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                          ),
                        );
                        final success = await cart.simulatePayment();
                        if (!mounted) return;
                        navigator.pop();
                        if (success) {
                          // show success dialog
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Thanh toán thành công'),
                              content: const Text('Đã thực hiện thanh toán. Giỏ hàng đã được xoá.'),
                              actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
                            ),
                          );
                        } else {
                          messenger.showSnackBar(const SnackBar(content: Text('Thanh toán thất bại')));
                        }
                      },
                      child: const Text('THANH TOÁN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 1, padding: const EdgeInsets.symmetric(vertical: 12)),
          onPressed: () async {
            final cart = Provider.of<CartModel>(context, listen: false);
            if (label == 'Khách') {
              // show pick table + guest count sheet
              final guestsCtrl = TextEditingController();
              showModalBottomSheet<void>(
                context: context,
                builder: (ctx) {
                  return SizedBox(
                    height: 380,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(controller: guestsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số lượng khách', hintText: 'Nhập số khách')),
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
                                  final guests = int.tryParse(guestsCtrl.text.trim()) ?? 0;
                                  cart.setSelectedTable(table);
                                  if (guests > 0) cart.setGuestsForTable(table, guests);
                                  Navigator.of(ctx).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã chọn $table ${guests > 0 ? ' - $guests khách' : ''}')));
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
            } else if (label == 'Chọn món') {
              // navigate to menu screen to pick items. When opened from Order screen we want the menu to return the selected item.
              final selected = await Navigator.of(context).push<OrderItem>(
                MaterialPageRoute(builder: (ctx) => const MenuScreen(closeOnAdd: true)),
              );
              if (!mounted) return;
              if (selected != null) {
                final cart = Provider.of<CartModel>(context, listen: false);
                cart.addItem(selected);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${selected.name} đã thêm vào giỏ')));
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, color: Colors.red), const SizedBox(height: 6), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12))],
          ),
        ),
      ),
    );
  }
}
