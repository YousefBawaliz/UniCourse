import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uni_course/core/constants/firebase_constants.dart';
import 'package:uni_course/core/failure.dart';
import 'package:uni_course/core/providers/firebase_providers.dart';
import 'package:uni_course/core/type_defs.dart';
import 'package:uni_course/models/community_model.dart';

//provider of the CommunityRepository
final communityRepositoryProvider = Provider((ref) {
  return CommunityRepository(firestore: ref.watch(fireStoreProvider));
});

class CommunityRepository {
  final FirebaseFirestore _fireStore;
  CommunityRepository({required FirebaseFirestore firestore})
      : _fireStore = firestore;

  //getter for communites collection
  CollectionReference get _communities =>
      _fireStore.collection(FirebaseConstants.communitiesCollection);

  //is of type FutureVoid because there could be some errors when creating a community
  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      //to ensure no 2 communities with the same name exist.
      if (communityDoc.exists) {
        throw 'community with the same name already exists';
      }
      //if no community with such name exists, set it
      //set return futureVoid, so does 'right'
      return right(
        _communities.doc(community.name).set(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /*we went to communities collection, where we found the user id (to get only communities the use is part of), then we got a snapshot (a stream of QuerySnapshots),
  which usually returns a QuerySnapshot (the data we need is a <List<Community>>), then we mapped through the QuerySnapshots, then we user 
  a for loop which goes through every QuerySnapshot, which in itself contains a documnet snapshot (event.docs), where every event.docs is an object containig a map of data,
  and then we're adding that document to List<Community> communities by converting it back into a community.
  - Community.fromMap takes a map and returns a communityModel
  - doc.data() is being returned as an object from FireStore but we know it's a Map, because that's how FireStore saves data.
  - we added cast type 'as Map<String, dynamic>' because .fromMap only takes Map<String, dynamic>
  */
  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map(
      (event) {
        List<Community> communities = [];
        for (var doc in event.docs) {
          communities
              .add(Community.fromMap(doc.data() as Map<String, dynamic>));
        }
        return communities;
      },
    );
  }

  //getter to get community by name
  Stream<Community> getCommunityByName(String name) =>
      _communities.doc(name).snapshots().map(
            (event) => Community.fromMap(event.data() as Map<String, dynamic>),
          );

  //to update the community when updating it
  FutureVoid editCommunity(Community community) async {
    try {
      return right(
        //Updates data on the document. Data will be merged with any existing document data.
        _communities.doc(community.name).update(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  /// Searches for communities based on the provided query.
  /// The function uses the where method on the _communities stream.
  /// The field being filtered is "name" of the community.
  /// isGreaterThanOrEqualTo: This ensures the name starts with a character greater than or equal to the provided query string.
  /// isLessThan: This defines an upper bound for the name to be less than a specific value.
  /// in case of Empty query:
  /// isGreaterThanOrEqualTo: 0: This allows communities with any name since any character is greater than or equal to 0 (ASCII value).
  /// isLessThan: null: No upper bound is specified, so all names are considered valid.
  ///
  /// Lexicographic Order and the Trick:
  /// By adding 1 to the code of the last character, we effectively move to the next character in the character set being used (usually ASCII).
  /// This is because characters are assigned codes in a specific order (alphabetical for letters, numerical for numbers, etc.).
  /// This trick works because Firestore uses lexicographic ordering when comparing strings during queries.
  /// Lexicographic ordering simply means comparing strings character by character, according to their code values.
  ///
  /// For example:
  /// Imagine the query string is "apple".
  /// The code for 'e' (last character) might be 101 (depending on the character set).
  /// Adding 1 to 101 gives 102, which represents the character 'f' in ASCII.
  /// So, the upper bound created becomes "applf" (which doesn't exist as a word but represents all names that start with "appl" and have a last character lexicographically after 'e').

  /// Returns a stream of lists of [Community] objects that match the search query.
  /// Each time the underlying data changes, a new list of communities will be emitted.
  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
        )
        .snapshots()
        .map(
      (event) {
        final List<Community> communities = [];
        for (var community in event.docs) {
          communities.add(
            Community.fromMap(community.data() as Map<String, dynamic>),
          );
        }
        return communities;
      },
    );
  }

  //function to join a community, we used FieldValue.arrayUnion to make sure that we update the value field, not rewrite it
  FutureVoid joinCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayUnion([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  //same as joinCommunity function, but we used FieldValue.arrayRemove instead
  FutureVoid leaveCommunity(String communityName, String userId) async {
    try {
      return right(_communities.doc(communityName).update({
        'members': FieldValue.arrayRemove([userId])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid addMods(String communityName, List<String> uids) async {
    try {
      return right(
        //note that we didn't use FieldValue.arrayUnion here, because we are adding a new whole list.
        _communities.doc(communityName).update({'mods': uids}),
      );
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
