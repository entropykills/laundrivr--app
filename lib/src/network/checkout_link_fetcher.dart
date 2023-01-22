import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/packages/purchasable_package.dart';

class CheckoutLinkFetcher {
  static final CheckoutLinkFetcher _singleton = CheckoutLinkFetcher._internal();

  factory CheckoutLinkFetcher() {
    return _singleton;
  }

  CheckoutLinkFetcher._internal();

  Future<String> fetchCheckoutLink(
      PurchasablePackage purchasablePackage) async {
    final String handle = purchasablePackage.handle;

    var checkoutLinkFunctionResult = await supabase.functions.invoke(
      'create-checkout-link',
      body: {
        'handle': handle,
      },
    );

    return await checkoutLinkFunctionResult.data['url'];
  }
}
