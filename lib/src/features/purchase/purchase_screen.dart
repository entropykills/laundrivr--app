import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laundrivr/src/model/packages/unloaded_package_repository.dart';
import 'package:laundrivr/src/network/package_fetcher.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../model/packages/package_repository.dart';
import '../../model/packages/purchasable_package.dart';
import '../../network/checkout_link_fetcher.dart';
import '../theme/laundrivr_theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  /// Create a subscription for the broadcast stream for the packages
  StreamSubscription<PackageRepository>? _packageSubscription;

  /// Package repository
  PackageRepository _packages = UnloadedPackageRepository();

  @override
  void initState() {
    super.initState();

    // subscribe to the broadcast stream for the packages
    _packageSubscription = PackageFetcher().stream.listen((packages) {
      // set the state
      setState(() {
        _packages = packages;
      });
    });

    // initialize the packages
    _initializePackages();
  }

  @override
  void dispose() {
    // cancel the subscription
    _packageSubscription?.cancel();
    super.dispose();
  }

  void _initializePackages() async {
    // fetch the packages
    var packages = await PackageFetcher().fetch();
    // if mounted, set the state
    if (mounted) {
      setState(() {
        _packages = packages;
      });
    }
  }

  Future<void> _refreshPackages() async {
    // refresh the packages
    PackageFetcher().clear();
    await PackageFetcher().fetch(force: true);
  }

  // get the checkout link fetcher
  static final CheckoutLinkFetcher _checkoutLinkFetcher = CheckoutLinkFetcher();

  void _fetchAndOpenCheckoutLink(PurchasablePackage purchasablePackage) async {
    // show the loading overlay
    context.loaderOverlay.show();
    try {
      // get the checkout link
      String checkoutLink =
          await _checkoutLinkFetcher.fetchCheckoutLink(purchasablePackage);
      if (!(await canLaunchUrlString(checkoutLink))) {
        throw Exception('Cannot launch $checkoutLink');
      }
      // open the checkout link in the browser
      await launchUrlString(checkoutLink, mode: LaunchMode.platformDefault);
    } catch (e) {
      // if there is an error, show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 10),
            content:
                Text("Oops, we couldn't open your checkout link! Try again."),
          ),
        );
      }
    }

    // hide the loading state
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final LaundrivrTheme laundrivrTheme =
        Theme.of(context).extension<LaundrivrTheme>()!;
    return RefreshIndicator(
      onRefresh: () => _refreshPackages(),
      child: Center(
          child:
              // if the packages are loading, show a loading indicator
              _packages is UnloadedPackageRepository
                  ? const CircularProgressIndicator()
                  // create a single child scroll view row for the purchase items, with
                  // a spacer in between each purchase item
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          // if there are no packages, show a message
                          if (_packages is UnloadedPackageRepository)
                            Text(
                              'No packages available',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: 25,
                              ),
                            )
                          else
                            // sort the packages by price
                            for (final purchasablePackage in _packages.get())
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.center,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _fetchAndOpenCheckoutLink(
                                              purchasablePackage);
                                        },
                                        child: Container(
                                          width: 320,
                                          height: 165,
                                          decoration: BoxDecoration(
                                            color: laundrivrTheme
                                                .secondaryOpaqueBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                spreadRadius: 2,
                                                blurRadius: 20,
                                                offset: const Offset(2,
                                                    2), // changes position of shadow
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 15),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  purchasablePackage
                                                      .displayName,
                                                  style: laundrivrTheme
                                                      .primaryTextStyle!
                                                      .copyWith(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.w900),
                                                ),
                                                const SizedBox(height: 10),
                                                Text(
                                                  '\$${purchasablePackage.price / 100}',
                                                  style: laundrivrTheme
                                                      .primaryTextStyle!
                                                      .copyWith(
                                                          fontSize: 48,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          color: laundrivrTheme
                                                              .pricingGreen),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -20,
                                        child: Container(
                                          width: 130,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: laundrivrTheme
                                                .brightBadgeBackgroundColor,
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${purchasablePackage.userReceivedLoads} Loads',
                                              style: laundrivrTheme
                                                  .primaryTextStyle!
                                                  .copyWith(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w900),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                        ],
                      ),
                    )),
    );
  }
}
