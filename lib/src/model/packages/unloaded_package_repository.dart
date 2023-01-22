import 'package:laundrivr/src/model/packages/package_repository.dart';

import '../unloaded_object_repository.dart';

class UnloadedPackageRepository extends PackageRepository
    with UnloadedObjectRepository {
  UnloadedPackageRepository() : super(object: []);
}
