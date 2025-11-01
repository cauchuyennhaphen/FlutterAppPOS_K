import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_model.dart';

class PrepScreen extends StatelessWidget {
  const PrepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chế biến')),
      body: Consumer<CartModel>(builder: (context, cart, _) {
        final queue = cart.prepQueue;
        if (queue.isEmpty) return const Center(child: Text('Không có món đang chế biến'));
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: queue.length,
          itemBuilder: (ctx, i) {
            final p = queue[i];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Text('${p.name} x${p.quantity}'),
                subtitle: Text('Bàn: ${p.table}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    cart.markPrepDone(p.id);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${p.name} đã chế biến xong')));
                  },
                  child: const Text('Xong'),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
