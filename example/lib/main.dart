import 'package:flutter/material.dart';
import 'package:flutter_poolakey/flutter_poolakey.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivial Example for Flutter-Poolakey',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(title: 'Trivial Example for Flutter-Poolakey'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dynamicPriceTokenController = TextEditingController();
  final productIdController = TextEditingController();
  bool connected = false;
  String status = "";
  bool consume = true;

  @override
  void initState() {
    _initShop();
    super.initState();
  }

  Future<void> _initShop() async {
    var rsaKey =
        "MIHNMA0GCSqGSIb3DQEBAQUAA4G7ADCBtwKBrwDbY/p0EgtJZHE6t9nVZ6QyzcR7e2O5RalVJx6Y+6Dc7n40FqdxAjHBYlptyZsdTg9r77JCS7UjEPXNuCHG5NCBLq/u7DWQQmh8otzMK6/P6nzsJUYvCqyNEu7cecaXmh5DgKlfRFpzNXBzBd4K3Xon8hBJjez/qdzvMtmHVFpdCSApUC0WTmT/kq1tDKLU1lDAEt10K83xZbi6lJWcAK20VUn+9KSVFxsr5WuXuWcCAwEAAQ==";
    try {
      connected = await FlutterPoolakey.connect(
        rsaKey,
        onDisconnected: () => showSnackBar("Poolakey disconnected!"),
      );
    } on Exception catch (e) {
      showSnackBar(e.toString());
      setState(() {
        status = "Service: Failed to Connect";
      });
    }

    setState(() {
      if (!connected) {
        status = "Service: Not Connected";
      } else {
        status = "Service: Connected";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status),
              const SizedBox(height: 8),
              TextField(
                controller: productIdController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Product id',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: dynamicPriceTokenController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Dynamic price token',
                ),
              ),
              Row(
                children: [
                  Text('Consume Purchase'),
                  Spacer(),
                  Switch(
                      value: consume,
                      onChanged: (checked) {
                        setState(() {
                          consume = checked;
                        });
                      }),
                ],
              ),
              FilledButton(
                  onPressed: () {
                    purchaseProduct(
                      productIdController.text,
                      "purchasePayload",
                      dynamicPriceTokenController.text,
                    );
                  },
                  child: Text('Purchase')),
              FilledButton(
                  onPressed: () {
                    subscribeProduct(
                      productIdController.text,
                      "subscribePayload",
                      dynamicPriceTokenController.text,
                    );
                  },
                  child: Text('Subscribe')),
              FilledButton(
                  onPressed: checkUserPurchasedItem,
                  child: Text('Check if user purchased this item')),
              FilledButton(
                  onPressed: checkUserSubscribedItem,
                  child: Text('Check if user subscribed this item')),
              FilledButton(
                  onPressed: () {
                    getSkuDetailOfInAppItem(productIdController.text);
                  },
                  child: Text('Get Sku detail of in-app item')),
              FilledButton(
                  onPressed: () {
                    getSkuDetailOfSubscriptionItem(productIdController.text);
                  },
                  child: Text('Get Sku detail of subscription item')),
              FilledButton(
                  onPressed: checkTrialSubscription,
                  child: Text('Check Trial subscription'))
            ],
          ),
        ),
      ),
    );
  }

  Future<void> subscribeProduct(
    String productId,
    String payload,
    String? dynamicPriceToken,
  ) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      PurchaseInfo? response = await FlutterPoolakey.subscribe(productId,
          payload: payload, dynamicPriceToken: dynamicPriceToken ?? "");
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> purchaseProduct(
    String productId,
    String payload,
    String? dynamicPriceToken,
  ) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }
    try {
      PurchaseInfo? response = await FlutterPoolakey.purchase(productId,
          payload: payload, dynamicPriceToken: dynamicPriceToken ?? "");
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> checkUserSubscribedItem() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<PurchaseInfo>? response =
          await FlutterPoolakey.getAllSubscribedProducts();
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> checkUserPurchasedItem() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<PurchaseInfo>? response =
          await FlutterPoolakey.getAllPurchasedProducts();
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> getSkuDetailOfSubscriptionItem(String skuValueInput) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<SkuDetails>? response =
          await FlutterPoolakey.getSubscriptionSkuDetails([skuValueInput]);
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> getSkuDetailOfInAppItem(String skuValueInput) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      List<SkuDetails>? response =
          await FlutterPoolakey.getInAppSkuDetails([skuValueInput]);
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> checkTrialSubscription() async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      Map response = await FlutterPoolakey.checkTrialSubscription();
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  Future<void> consumePurchasedItem(String purchaseToken) async {
    if (!connected) {
      showSnackBar('Service: Not Connected');
      return;
    }

    try {
      bool? response = await FlutterPoolakey.consume(purchaseToken);
    } catch (e) {
      showSnackBar(e.toString());
      return;
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    dynamicPriceTokenController.dispose();
    productIdController.dispose();
    super.dispose();
  }
}
