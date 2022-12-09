import 'package:flutter/material.dart';
import 'package:laundrivr/src/network/package_fetcher.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/packages/purchasable_package.dart';
import '../../network/checkout_link_fetcher.dart';
import '../theme/laundrivr_theme.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  // get the package fetcher
  static final PackageFetcher _packageFetcher = PackageFetcher();

  // get the checkout link fetcher
  static final CheckoutLinkFetcher _checkoutLinkFetcher = CheckoutLinkFetcher();

  bool _isLoadingPackages = true;
  late List<PurchasablePackage> _packages = [];

  bool _isLoadingCheckoutLink = false;

  @override
  void initState() {
    super.initState();
    _refresh(false);
  }

  Future<void> _refresh(bool clearCache) async {
    if (clearCache) {
      _packageFetcher.clearCache();
    }

    // set the loading state
    setState(() {
      _isLoadingPackages = true;
    });

    // use the package fetcher to get the packages
    List<PurchasablePackage> data = await _packageFetcher.fetchPackages();
    // sort the packages by price
    data.sort((a, b) => a.price.compareTo(b.price));

    // set the states
    setState(() {
      _isLoadingPackages = false;
      _packages = data;
    });
  }

  void _fetchAndOpenCheckoutLink(PurchasablePackage purchasablePackage) async {
    // show the loading overlay
    context.loaderOverlay.show();
    try {
      // get the checkout link
      String checkoutLink =
          await _checkoutLinkFetcher.fetchCheckoutLink(purchasablePackage);
      // remove any issues with the link and encode it
      String encodedCheckoutLink = Uri.encodeFull(checkoutLink);
      // open the checkout link in the browser
      launchUrl(Uri.parse(encodedCheckoutLink));
    } catch (e) {
      // if there is an error, show a snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 10),
            content: Text("Oops, we couldn't open checkout link!"),
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
      onRefresh: () => _refresh(true),
      child: Center(
          child:
              // if the packages are loading, show a loading indicator
              _isLoadingPackages
                  ? const CircularProgressIndicator()
                  // create a single child scroll view row for the purchase items, with
                  // a spacer in between each purchase item
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          // if there are no packages, show a message
                          if (_packages.isEmpty)
                            Text(
                              'No packages available',
                              style: laundrivrTheme.primaryTextStyle!.copyWith(
                                fontSize: 25,
                              ),
                            )
                          else
                            // sort the packages by price
                            for (final purchasablePackage in _packages)
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
