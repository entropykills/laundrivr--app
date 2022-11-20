import 'package:flutter/material.dart';

import '../theme/laundrivr_theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class PurchaseItem {
  const PurchaseItem({
    required this.name,
    required this.price,
    required this.loadQuantity,
  });

  final String name;
  final double price;
  final int loadQuantity;
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  static const List<PurchaseItem> _purchaseItems = [
    PurchaseItem(name: 'Basic', price: 0.99, loadQuantity: 2),
    PurchaseItem(name: 'Occasional Washer', price: 12.99, loadQuantity: 5),
    PurchaseItem(name: 'Semester Long', price: 19.99, loadQuantity: 30),
    PurchaseItem(name: 'Laundry Lunatic', price: 35.99, loadQuantity: 60),
  ];

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return Center(
        // create a single child scroll view row for the purchase items, with
        // a spacer in between each purchase item
        child: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          for (final purchaseItem in _purchaseItems)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 320,
                      height: 165,
                      decoration: BoxDecoration(
                        color: laundrivrTheme.secondaryOpaqueBackgroundColor,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 20,
                            offset: const Offset(
                                2, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              purchaseItem.name,
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                  fontSize: 25, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '\$${purchaseItem.price}',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: laundrivrTheme.pricingGreen),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20,
                      child: Container(
                        width: 130,
                        height: 50,
                        decoration: BoxDecoration(
                          color: laundrivrTheme.brightBadgeBackgroundColor,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Center(
                          child: Text(
                            '${purchaseItem.loadQuantity} Loads',
                            style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: 25, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ),
                  ]),
            ),
        ],
      ),
    ));
  }
}
