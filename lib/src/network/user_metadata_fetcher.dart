import 'dart:async';
import 'dart:developer';

import 'package:laundrivr/src/model/user/unloaded_user_metadata.dart';
import 'package:laundrivr/src/model/user/user_metadata.dart';

import '../constants.dart';
import '../model/user/user_metadata_constructor.dart';

class UserMetadataFetcher {
  static final UserMetadataFetcher _singleton = UserMetadataFetcher._internal();

  factory UserMetadataFetcher() {
    // fetch metadata
    _singleton.fetchMetadata();
    // return the singleton
    return _singleton;
  }

  UserMetadataFetcher._internal();

  // create a cache of metadata
  UserMetadata _metadata = UnloadedUserMetadata();

  /// Cooldown for fetching metadata
  static const Duration _cooldown = Duration(minutes: 1);

  /// Last time metadata was fetched
  DateTime _lastFetch = DateTime.now().subtract(_cooldown);

  /// Whether the metadata is currently being fetched
  bool _isFetching = false;

  /// The number of times the metadata has been fetched (retry count)
  int _retryCount = 0;

  // create a subscription broadcast stream
  final StreamController<UserMetadata> _streamController =
      StreamController.broadcast();

  /// Fetches the metadata from the database
  Future<UserMetadata> fetchMetadata({bool force = false}) async {
    // check if the cooldown has passed
    if (DateTime.now().difference(_lastFetch) < _cooldown && !force) {
      // return the cached metadata
      return _metadata;
    }

    // check if the metadata is already being fetched
    if (_isFetching) {
      // return the cached metadata
      return _metadata;
    }

    // set the last fetch time
    _lastFetch = DateTime.now();

    // set the fetching state
    _isFetching = true;

    // if the cache is empty, fetch the metadata
    if (_metadata is UnloadedUserMetadata) {
      // fetch the metadata with supabase
      try {
        final data = (await supabase
            .from(Constants.supabaseUserMetadataTableName)
            .select('loads_available')
            .limit(1)
            .single()); // select loads_available column

        // create a new metadata constructor
        UserMetadata constructed =
            const UserMetadataConstructor().construct(data);
        // set the cache to the metadata
        _metadata = constructed;
        // set the retry count to 0
        _retryCount = 0;
      } catch (error) {
        // return an empty list if there is an error
        // reset the cache
        _metadata = UnloadedUserMetadata();

        // retry, but only 3 times
        if (_retryCount < 3) {
          log('Error fetching metadata: $error. Retrying...');
          // wait 1 second
          await Future.delayed(const Duration(seconds: 1));
          // increment the retry count
          _retryCount++;
          // fetch the metadata again
          await fetchMetadata();
        }
      }
    }

    // reset the fetching state
    _isFetching = false;

    // update the subscription
    _streamController.add(_metadata);

    // return the metadata
    return _metadata;
  }

  void updateMetadata(UserMetadata metadata) {
    // update the cache
    _metadata = metadata;
    // update the subscription
    _streamController.add(_metadata);
  }

  /// Clears the cache
  void clearCache() {
    _metadata = UnloadedUserMetadata();
    // update the subscription
    _streamController.add(_metadata);
  }

  /// Returns a stream of metadata
  Stream<UserMetadata> get stream => _streamController.stream;
}
