import 'dart:async';

import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/packages/package_repository.dart';
import 'package:laundrivr/src/model/packages/purchasable_package.dart';
import 'package:laundrivr/src/model/packages/unloaded_package_repository.dart';
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
  PackageRepository _packages = UnloadedPackageRepository();

  /// Cooldown for fetching packages
  static const Duration _cooldown = Duration(minutes: 1);

  /// Last time packages were fetched
  DateTime _lastFetch = DateTime.now().subtract(_cooldown);

  /// Whether the packages are currently being fetched
  bool _isFetching = false;

  // create a subscription broadcast stream
  final StreamController<PackageRepository> _streamController =
      StreamController.broadcast();

  /// Fetches the packages from the database
  Future<PackageRepository> fetchPackages({bool force = false}) async {
    // check if the cooldown has passed
    if (DateTime.now().difference(_lastFetch) < _cooldown && !force) {
      // return the cached packages
      return _packages;
    }

    // check if the packages are already being fetched
    if (_isFetching && !force) {
      // return the cached packages
      return _packages;
    }

    // set the last fetch time
    _lastFetch = DateTime.now();

    // set the fetching state
    _isFetching = true;

    // if the cache is empty, fetch the packages
    if (_packages is UnloadedPackageRepository) {
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

        // sort the packages by price
        packages.sort((a, b) => a.price.compareTo(b.price));

        // set the cache to the packages
        _packages = PackageRepository(packages: packages);
      } on PostgrestException catch (_) {
        // return an empty list if there is an error
        // reset the cache
        _packages = UnloadedPackageRepository();
      } catch (error) {
        // return an empty list if there is an error
        // reset the cache
        _packages = UnloadedPackageRepository();
      }
    }

    // reset the fetching state
    _isFetching = false;

    // add the packages to the stream
    _streamController.add(_packages);

    // return the packages
    return _packages;
  }

  /// Clears the cache
  void clearCache() {
    _packages = UnloadedPackageRepository();
    // update the subscription
    _streamController.add(_packages);
  }

  /// Returns a stream of package repositories
  Stream<PackageRepository> get stream => _streamController.stream;
}
