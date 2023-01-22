import 'dart:async';
import 'dart:developer';

import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/packages/package_repository.dart';
import 'package:laundrivr/src/model/packages/purchasable_package.dart';
import 'package:laundrivr/src/model/packages/unloaded_package_repository.dart';
import 'package:laundrivr/src/network/generic_fetcher.dart';

import '../model/packages/package_constructor.dart';

class PackageFetcher extends GenericFetcher<PackageRepository> {
  static final PackageFetcher _singleton = PackageFetcher._internal();

  factory PackageFetcher() {
    return _singleton;
  }

  PackageFetcher._internal()
      : super(const Duration(seconds: 1), UnloadedPackageRepository());

  @override
  Future<PackageRepository> fetchFromDatabase() async {
    log('PackageFetcher: Fetching packages...');
    PackageRepository repository = UnloadedPackageRepository();

    final data = (await supabase
        .from(Constants.supabasePurchasablePackagesTableName)
        .select('*')) as List;

    List<PurchasablePackage> packages = [];

    for (final item in data) {
      PurchasablePackage constructed =
          const PackageConstructor().construct(item);
      packages.add(constructed);
    }

    packages.sort((a, b) => a.price.compareTo(b.price));

    repository = PackageRepository(object: packages);

    log('PackageFetcher: ${repository.object.length} packages fetched');
    return repository;
  }

  @override
  PackageRepository provideUnloadedRepository() {
    return UnloadedPackageRepository();
  }
}
