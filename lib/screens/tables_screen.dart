import 'package:flutter/material.dart';
// ignore_for_file: use_build_context_synchronously
import 'package:provider/provider.dart';
import '../models/cart_model.dart';


class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bàn ngồi')),
      body: Consumer<CartModel>(builder: (context, cart, _) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.2),
            itemCount: 20,
            itemBuilder: (ctx, idx) {
              final tableName = 'Bàn ${idx + 1}';
              final occupied = cart.isTableOccupied(tableName);
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (bsCtx) => _buildTableDetails(bsCtx, cart, tableName),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: occupied ? Colors.red : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    children: [
                      Center(
                        child: Text('B${idx + 1}', style: TextStyle(color: occupied ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                      ),
                      // reservation indicator top-left
                      Positioned(
                        top: 4,
                        left: 4,
                        child: cart.isTableReserved(tableName) ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(12)),
                          child: const Text('Đặt', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ) : const SizedBox.shrink(),
                      ),
                      // badges: top-right small circle showing ready count, bottom-right small badge showing ordered count
                      Positioned(
                        top: 4,
                        right: 4,
                        child: cart.getReadyCountForTable(tableName) > 0 ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)),
                          child: Text('${cart.getReadyCountForTable(tableName)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ) : const SizedBox.shrink(),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: cart.getOrderedCountForTable(tableName) > 0 ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                          child: Text('${cart.getOrderedCountForTable(tableName)}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ) : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildTableDetails(BuildContext context, CartModel cart, String table) {
    final orders = cart.getTableOrders(table);
    final ready = cart.getReadyItemsForTable(table);
    final reservation = cart.getReservation(table);
    final guests = cart.getGuestsForTable(table);
    return SizedBox(
      height: 360,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(table, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(cart.isTableOccupied(table) ? 'Đang ngồi' : 'Trống', style: TextStyle(color: cart.isTableOccupied(table) ? Colors.red : Colors.green)),
                    if (guests > 0) Text('$guests khách', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    if (reservation != null) Text('Đặt trước: ${reservation.name}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Món đã đặt', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Expanded(
              child: orders.isEmpty ? const Text('Chưa có món') : ListView.builder(
                itemCount: orders.length,
                itemBuilder: (ctx, i) {
                  final it = orders[i];
                  return ListTile(
                    title: Text('${it.name} x${it.quantity}'),
                    trailing: Text(it.subtotal.toString()),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            const Text('Món sẵn sàng', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            ready.isEmpty ? const Text('Không có món sẵn sàng') : Column(
              children: ready.map((r) => ListTile(
                title: Text('${r.name} x${r.quantity}'),
                trailing: ElevatedButton(onPressed: () { cart.removeReadyItem(table, r); }, child: const Text('Lấy món')),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ElevatedButton(onPressed: () { cart.clearTable(table); Navigator.of(context).pop(); }, child: const Text('Dọn bàn')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { _showReservationDialog(context, cart, table); }, child: const Text('Đặt trước')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { _showBill(context, cart, table); }, child: const Text('Thanh toán')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: () { Navigator.of(context).pop(); }, child: const Text('Đóng')),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showReservationDialog(BuildContext context, CartModel cart, String table) {
    final nameCtrl = TextEditingController(text: cart.getReservation(table)?.name ?? '');
    final guestsCtrl = TextEditingController(text: cart.getGuestsForTable(table) > 0 ? cart.getGuestsForTable(table).toString() : '');
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Đặt trước - $table'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên người đặt')),
              TextField(controller: guestsCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Số khách')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(onPressed: () {
              final name = nameCtrl.text.trim();
              final guests = int.tryParse(guestsCtrl.text.trim()) ?? 0;
              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên người đặt')));
                return;
              }
              final existing = cart.getReservation(table);
              void doSave() {
                cart.setReservation(table, Reservation(name: name, guests: guests));
                if (guests > 0) cart.setGuestsForTable(table, guests);
                Navigator.of(ctx).pop();
                navigator.pop(); // close bottom sheet
                messenger.showSnackBar(const SnackBar(content: Text('Đã đặt trước')));
              }

              if (existing != null && (existing.name != name || existing.guests != guests)) {
                // confirm overwrite
                showDialog<bool>(
                  context: context,
                  builder: (confirmCtx) {
                    return AlertDialog(
                      title: const Text('Ghi đè đặt trước?'),
                      content: const Text('Bàn này đã có đặt trước. Bạn có muốn ghi đè thông tin đặt trước không?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(confirmCtx).pop(false), child: const Text('Hủy')),
                        ElevatedButton(onPressed: () => Navigator.of(confirmCtx).pop(true), child: const Text('Ghi đè')),
                      ],
                    );
                  }
                ).then((confirmed) {
                  if (confirmed == true) {
                    doSave();
                  }
                });
              } else {
                doSave();
              }
            }, child: const Text('Lưu')),
          ],
        );
      }
    );
  }

  void _showBill(BuildContext context, CartModel cart, String table) {
  final orders = cart.getTableOrders(table);
  final subtotal = cart.getTableSubtotal(table);
    final discount = 0;
    final vat = ((subtotal - discount) * 0.05).round();
    final total = subtotal - discount + vat;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Hóa đơn - $table'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header row for columns
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(children: const [
                    Expanded(child: Text('Món', style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    SizedBox(width: 60, child: Text('Giá', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                    SizedBox(width: 8),
                    SizedBox(width: 60, child: Text('Tổng', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold))),
                  ]),
                ),
                const Divider(),
                ...orders.map((o) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Expanded(child: Text('${o.name} x${o.quantity}')),
                      const SizedBox(width: 8),
                        SizedBox(width: 60, child: Text(o.unitPrice.toString(), textAlign: TextAlign.right)),
                      const SizedBox(width: 8),
                        SizedBox(width: 60, child: Text(o.subtotal.toString(), textAlign: TextAlign.right)),
                    ],
                  ),
                )),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tạm tính'), Text(_formatCurrency(subtotal))]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('VAT (5%)'), Text(_formatCurrency(vat))]),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tổng', style: TextStyle(fontWeight: FontWeight.bold)), Text(_formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold))]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                // Ask whether user wants to print the receipt before finalizing
                final wantPrint = await showDialog<bool>(
                  context: context,
                  builder: (printCtx) {
                    return AlertDialog(
                      title: const Text('In hóa đơn'),
                      content: const Text('Bạn có muốn in hóa đơn sau khi thanh toán không?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(printCtx).pop(false), child: const Text('Không in')),
                        ElevatedButton(onPressed: () => Navigator.of(printCtx).pop(true), child: const Text('In hóa đơn')),
                      ],
                    );
                  },
                );

                if (wantPrint == null) {
                  // user dismissed the print dialog -> do nothing
                  return;
                }

                if (wantPrint == true) {
                  // simulate printing with a small progress dialog
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (pCtx) => const AlertDialog(
                      content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                    ),
                  );
                  // simulate short printing delay
                  await Future.delayed(const Duration(seconds: 1));
                  // close the printing dialog
                  navigator.pop();
                  messenger.showSnackBar(const SnackBar(content: Text('Hóa đơn đã được in')));
                }

                // finalize payment: clear table orders and ready items
                cart.clearTable(table);
                Navigator.of(ctx).pop();
                navigator.pop(); // close bottom sheet
                messenger.showSnackBar(const SnackBar(content: Text('Thanh toán xong')));
              },
              child: const Text('Xác nhận thanh toán'),
            )
          ],
        );
      }
    );
  }
}

String _formatCurrency(int amount) {
  // Simple formatting: thousand separators
  final s = amount.toString();
  final buffer = StringBuffer();
  var count = 0;
  for (var i = s.length - 1; i >= 0; i--) {
    buffer.write(s[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write('.');
      count = 0;
    }
  }
  return '${buffer.toString().split('').reversed.join()} đ';
}
