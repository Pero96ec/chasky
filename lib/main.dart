import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:chasky/src/models/user.dart';
import 'package:chasky/src/pages/client/products/list/client_products_list_page.dart';
import 'package:chasky/src/pages/delivery/orders/list/delivery_orders_list_page.dart';
import 'package:chasky/src/pages/home/home_page.dart';
import 'package:chasky/src/pages/login/login_page.dart';
import 'package:chasky/src/pages/register/register_page.dart';
import 'package:chasky/src/pages/restaurant/orders/list/restaurant_orders_list_page.dart';
import 'package:chasky/src/pages/roles/roles_page.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

User userSession = User.fromJson(GetStorage().read('user') ?? {});

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      onBackground: onIosBackground,
      onForeground: onStart,
    ),
  );

  service.startService();
}

bool onIosBackground(ServiceInstance service) {
  return true;
}

void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Tracking",
      content: "Enviando ubicación...",
    );
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(Duration(minutes: 1), (timer) async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    //await sendLocation(position.latitude, position.longitude);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('Usuario id: ${userSession.id}');

    return GetMaterialApp(
      title: 'Delivery Udemy',
      debugShowCheckedModeBanner: false,
      initialRoute:
          userSession.id != null
              ? userSession.roles!.length > 1
                  ? '/roles'
                  : '/client/products/list'
              : '/',
      getPages: [
        GetPage(name: '/', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/roles', page: () => RolesPage()),
        GetPage(
          name: '/restaurant/orders/list',
          page: () => RestaurantOrdersListPage(),
        ),
        GetPage(
          name: '/delivery/orders/list',
          page: () => DeliveryOrdersListPage(),
        ),
        GetPage(
          name: '/client/products/list',
          page: () => ClientProductsListPage(),
        ),
      ],
      theme: ThemeData(
        primaryColor: Colors.amber,
        colorScheme: ColorScheme(
          primary: Colors.amber,
          secondary: Colors.amberAccent,
          brightness: Brightness.light,
          onBackground: Colors.grey,
          onPrimary: Colors.grey,
          surface: Colors.grey,
          onSurface: Colors.grey,
          error: Colors.grey,
          onError: Colors.grey,
          onSecondary: Colors.grey,
          background: Colors.grey,
        ),
      ),
      navigatorKey: Get.key,
    );
  }
}
