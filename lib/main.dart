import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';
import 'screens/tables_screen.dart';
import 'screens/prep_screen.dart';
import 'screens/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/cart_model.dart';
import 'models/reservation_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ReservationAdapter());
  // open boxes used by CartModel
  await Hive.openBox('reservations');
  await Hive.openBox('guests');

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const MenuScreen(),
    const TablesScreen(),
    const PrepScreen(),
    const OrderScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // load persisted reservations/guests after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = Provider.of<CartModel>(context, listen: false);
      cart.loadPersistentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        primaryColor: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: (idx) => setState(() => _selectedIndex = idx),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Menu'),
            BottomNavigationBarItem(icon: Icon(Icons.table_bar), label: 'Bàn ngồi'),
            BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: 'Chế biến'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
          ],
        ),
      ),
    );
  }
}
