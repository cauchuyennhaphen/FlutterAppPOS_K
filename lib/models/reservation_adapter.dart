import 'package:hive/hive.dart';

import 'cart_model.dart';

class ReservationAdapter extends TypeAdapter<Reservation> {
  @override
  final int typeId = 1;

  @override
  Reservation read(BinaryReader reader) {
    final name = reader.readString();
    final guests = reader.readInt();
    final millis = reader.readInt();
    return Reservation(name: name, guests: guests, createdAt: DateTime.fromMillisecondsSinceEpoch(millis));
  }

  @override
  void write(BinaryWriter writer, Reservation obj) {
    writer.writeString(obj.name);
    writer.writeInt(obj.guests);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
