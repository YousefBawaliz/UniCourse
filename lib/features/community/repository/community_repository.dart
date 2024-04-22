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

  //to return results of a search.
  //query is whatever the user is typing
  // i truly don't understand this query algorithm, i just snatched it from a youtube tutorial, but it works
  // Stream<List<Community>> searchCommunity(String query) {
  //   return _communities
  //       .where(
  //         'name',
  //         isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
  //         isLessThan: query.isEmpty
  //             ? null
  //             : query.substring(0, query.length - 1) +
  //                 String.fromCharCode(query.codeUnitAt(query.length - 1) + 1),
  //       )
  //       .snapshots()
  //       .map(
  //     (event) {
  //       final List<Community> communities = [];
  //       for (var community in event.docs) {
  //         communities.add(
  //           Community.fromMap(community.data() as Map<String, dynamic>),
  //         );
  //       }
  //       return communities;
  //     },
  //   );
  // }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query,
          isLessThan: query + 'z',
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
