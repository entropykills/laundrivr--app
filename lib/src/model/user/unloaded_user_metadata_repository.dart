import 'package:laundrivr/src/model/unloaded_object_repository.dart';
import 'package:laundrivr/src/model/user/unloaded_user_metadata.dart';
import 'package:laundrivr/src/model/user/user_metadata_repository.dart';

class UnloadedUserMetadataRepository extends UserMetadataRepository
    with UnloadedObjectRepository {
  UnloadedUserMetadataRepository() : super(object: UnloadedUserMetadata());
}
