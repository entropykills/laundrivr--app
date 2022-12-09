import 'package:laundrivr/src/model/packages/purchasable_package.dart';

import '../object_constructor.dart';

class PackageConstructor
    implements ObjectConstructor<PurchasablePackage, Map<String, dynamic>> {
  const PackageConstructor();

  @override
  PurchasablePackage construct(Map<String, dynamic> data) {
    return PurchasablePackage(
      displayName: data['display_name'],
      price: data['price'],
      userReceivedLoads: data['user_received_loads'],
      handle: data['handle'],
    );
  }
}
