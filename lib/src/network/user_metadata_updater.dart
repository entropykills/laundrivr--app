import 'package:laundrivr/src/constants.dart';
import 'package:laundrivr/src/model/user/user_metadata.dart';
import 'package:laundrivr/src/network/user_metadata_fetcher.dart';

class UserMetadataUpdater {
  static final UserMetadataUpdater _singleton = UserMetadataUpdater._internal();

  factory UserMetadataUpdater() {
    // return the singleton
    return _singleton;
  }

  UserMetadataUpdater._internal();

  /// Cooldown for updating user metadata
  static const Duration _cooldown = Duration(seconds: 1);

  /// Last time user metadata was updated
  DateTime _lastFetch = DateTime.now().subtract(_cooldown);

  /// Whether the user metadata is currently being updated
  bool _isFetching = false;

  Future<void> subtractOneLoad() async {
    // check if the cooldown has passed
    if (DateTime.now().difference(_lastFetch) < _cooldown) {
      // return
      return;
    }

    // check if the user metadata is already being updated
    if (_isFetching) {
      // return
      return;
    }

    // set the last fetch time
    _lastFetch = DateTime.now();

    // set the fetching state
    _isFetching = true;

    // get the current number of loads
    UserMetadata metadata = await UserMetadataFetcher().fetchMetadata();
    if (metadata.loadsAvailable <= 0) {
      return;
    }

    // subtract one load
    metadata.loadsAvailable -= 1;
    UserMetadataFetcher().updateMetadata(metadata);

    // get the current user
    final user = supabase.auth.currentUser!;

    // update the metadata with supabase
    await supabase.functions.invoke("use-load", body: {
      "user_id": user.id,
    });

    // set the fetching state
    _isFetching = false;
  }
}
