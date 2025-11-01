# FlutterAppPOS_K - Ứng dụng Quản lý Nhà hàng

[![Flutter Version](https://img.shields.io/badge/Flutter-^3.9.2-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Ứng dụng quản lý nhà hàng được xây dựng bằng Flutter, cung cấp các tính năng quản lý bàn, đặt món, thanh toán và quản lý đơn hàng.

## 🌟 Tính năng chính

- **Quản lý bàn**
  - Hiển thị trạng thái bàn (trống/có khách)
  - Đặt bàn trước
  - Quản lý số lượng khách

- **Quản lý đơn hàng**
  - Đặt món theo bàn
  - Theo dõi trạng thái món (đã đặt/sẵn sàng)
  - Hiển thị số lượng món đã đặt và món sẵn sàng

- **Thanh toán**
  - Tính tổng tiền tự động
  - Áp dụng VAT
  - In hóa đơn
  - Xử lý thanh toán

## 🚀 Cài đặt

1. **Yêu cầu hệ thống**
   ```bash
   Flutter SDK: ^3.9.2
   Dart SDK: ^3.9.2
   ```

2. **Clone repository**
   ```bash
   git clone https://github.com/cauchuyennhaphen/FlutterAppPOS_K.git
   cd FlutterAppPOS_K
   ```

3. **Cài đặt dependencies**
   ```bash
   flutter pub get
   ```

4. **Chạy ứng dụng**
   ```bash
   flutter run
   ```

## 🛠️ Công nghệ sử dụng

- **Flutter**: Framework UI đa nền tảng
- **Provider**: Quản lý state
- **Hive**: Local storage
- **SharedPreferences**: Lưu trữ cài đặt
- **intl**: Định dạng số và ngày tháng

## 📦 Cấu trúc dự án

```
lib/
├── models/          # Data models
│   ├── cart_model.dart
│   ├── order_item.dart
│   └── reservation_adapter.dart
├── screens/         # UI screens
│   ├── menu_screen.dart
│   ├── order_screen.dart
│   ├── prep_screen.dart
│   └── tables_screen.dart
└── main.dart        # Entry point
```

## 🧪 Testing

Chạy unit tests:
```bash
flutter test
```

## 📱 Nền tảng hỗ trợ

- Android
- iOS
- Web
- Windows
- Linux
- macOS

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng:

1. Fork dự án
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit thay đổi (`git commit -m 'Add some AmazingFeature'`)
4. Push lên branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Phân phối dưới giấy phép MIT. Xem `LICENSE` để biết thêm thông tin.

## 📞 Liên hệ

Tên của bạn - [@cauchuyennhaphen](https://github.com/cauchuyennhaphen)

Link dự án: [https://github.com/cauchuyennhaphen/FlutterAppPOS_K](https://github.com/cauchuyennhaphen/FlutterAppPOS_K)
