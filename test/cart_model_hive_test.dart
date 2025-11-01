import 'dart:io';

import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appquanli/models/reservation_adapter.dart';
import 'package:appquanli/models/cart_model.dart';

void main() {
  late Directory tmpDir;
  setUp(() async {
    tmpDir = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(tmpDir.path);
    Hive.registerAdapter(ReservationAdapter());
    await Hive.openBox('reservations');
    await Hive.openBox('guests');
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (await tmpDir.exists()) {
        await tmpDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  test('save and load reservations and guests', () async {
    final cart = CartModel();
    final res = Reservation(name: 'Nguyen', guests: 3);
    cart.setReservation('Bàn 1', res);
    cart.setGuestsForTable('Bàn 1', 3);

    // simulate a new app instance
    final cart2 = CartModel();
    await cart2.loadPersistentData();

    final loaded = cart2.getReservation('Bàn 1');
    expect(loaded, isNotNull);
    expect(loaded!.name, 'Nguyen');
    expect(cart2.getGuestsForTable('Bàn 1'), 3);
  });
}
