import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/packages/purchasable_package.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/packages/package_constructor.dart';

class PackageFetcher {
  static final PackageFetcher _singleton = PackageFetcher._internal();

  factory PackageFetcher() {
    // fetch the packages
    _singleton.fetchPackages();
    // return the singleton
    return _singleton;
  }

  PackageFetcher._internal();

  // create a cache of packages
  List<PurchasablePackage> _packages = [];

  /// Fetches the packages from the database
  Future<List<PurchasablePackage>> fetchPackages() async {
    // if the cache is empty, fetch the packages
    if (_packages.isEmpty) {
      // fetch the packages with supabase
      try {
        final data = (await supabase
            .from(Constants.supabasePurchasablePackagesTableName)
            .select('*')); // select all columns

        // create a list of packages from the data
        List<PurchasablePackage> packages = [];

        // loop through the data and create a list of Package objects
        for (final item in data) {
          // create a new package constructor
          PurchasablePackage constructed =
              const PackageConstructor().construct(item);
          packages.add(constructed);
        }

        // set the cache to the packages
        _packages = packages;
      } on PostgrestException catch (_) {
        // return an empty list if there is an error
        // reset the cache
        _packages = [];
      } catch (error) {
        // return an empty list if there is an error
        // reset the cache
        _packages = [];
      }
    }
    // return the packages
    return _packages;
  }

  void clearCache() {
    _packages = [];
  }
}
