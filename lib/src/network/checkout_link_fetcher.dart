import 'dart:developer';

import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/packages/purchasable_package.dart';

class CheckoutLinkFetcher {
  static final CheckoutLinkFetcher _singleton = CheckoutLinkFetcher._internal();

  factory CheckoutLinkFetcher() {
    // return the singleton
    return _singleton;
  }

  CheckoutLinkFetcher._internal();

  /// Fetches the checkout link for a package with the given package
  Future<String> fetchCheckoutLink(
      PurchasablePackage purchasablePackage) async {
    // get the handle of the package
    final String handle = purchasablePackage.handle;

    // use supabase edge functions to get the checkout link
    var result = await supabase.functions.invoke(
      'create-checkout-link',
      body: {
        'handle': handle,
      },
    );

    var url = await result.data['url'];

    log('checkout link: $url');

    return url;
  }
}
