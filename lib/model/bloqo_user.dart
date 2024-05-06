import 'package:bloqo/model/courses/bloqo_course.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'courses/bloqo_chapter.dart';
import 'courses/bloqo_section.dart';

class BloqoUser{
  final String email;
  final String username;
  final String fullName;
  final bool isFullNameVisible;

  String? documentId;
  List<BloqoCourse>? coursesEnrolledIn;
  List<BloqoCourse>? coursesCreated;

  BloqoUser({
    required this.email,
    required this.username,
    required this.fullName,
    required this.isFullNameVisible,
    this.documentId,
    this.coursesEnrolledIn,
    this.coursesCreated,
  });

  factory BloqoUser.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    // Check if courses_enrolled_in is null or not
    List<dynamic>? enrolledCoursesData = data?['courses_enrolled_in'];
    List<BloqoCourse> coursesEnrolledIn = [];

    /*
    if (enrolledCoursesData != null) {
      for (dynamic subDocumentReference in enrolledCoursesData) {
        // Fetch each referenced sub-document from Firestore
        Future<DocumentSnapshot<Map<String, dynamic>>> subDocumentSnapshotFuture = subDocumentReference.get();

        subDocumentSnapshotFuture.then((subDocumentSnapshot) {
          if (subDocumentSnapshot.exists) {
            // Extract the desired variables from each sub-document
            String courseName = subDocumentSnapshot['name'];
            String courseAuthor = subDocumentSnapshot['author_username'];
            List<BloqoChapter> courseChapters = [];

            final course = BloqoCourse(
              name: courseName,
              author: courseAuthor,
              chapters: courseChapters,
            );
            coursesEnrolledIn.add(course);
          } else {
            print('Sub-document does not exist');
            //FIXME
          }
        });
      }
    }

    List<BloqoCourse> coursesCreated = [];
    if (data?['courses_created'] != null) {
      // retrieving courses the user created
      List<dynamic> subDocumentReferences = data?['courses_created'];

      for (dynamic subDocumentReference in subDocumentReferences) {
        //Fetch each referenced sub-document from Firestore
        Future<DocumentSnapshot<Map<String, dynamic>>> subDocumentSnapshotFuture = subDocumentReference.get();

        subDocumentSnapshotFuture.then((subDocumentSnapshot) {
          if (subDocumentSnapshot.exists) {
            //Extract the desired variables from each sub-document
            String courseName = subDocumentSnapshot['name'];
            //TODO: aggiungere parametri per contare numero di capitoli e di sezioni

            final course = BloqoCourse(
              name: courseName,
              author: data?['username'],
            );
            coursesCreated.add(course);
          } else {
            print('Sub-document does not exist');
            // FIXME
          }
        });
      }
    } */

    return BloqoUser(
      documentId: snapshot.id,
      email: data!["email"],
      username: data["username"],
      fullName: data["full_name"],
      isFullNameVisible: data["is_full_name_visible"],
    );
  }

  Map<String, dynamic> toFirestore() {
    List? coursesEnrolledInReferences = coursesEnrolledIn?.map((course) => BloqoCourse.getRef()).toList();
    List? coursesCreatedReferences = coursesCreated?.map((course) => BloqoCourse.getRef()).toList();
    return {
      "email": email,
      "username": username,
      "full_name": fullName,
      "is_full_name_visible": isFullNameVisible,
      "courses_enrolled_in": coursesEnrolledInReferences,
      "courses_created": coursesCreatedReferences,
    };
  }

  static getRef() {
    var db = FirebaseFirestore.instance;
    return db.collection("users").withConverter(
      fromFirestore: BloqoUser.fromFirestore,
      toFirestore: (BloqoUser user, _) => user.toFirestore(),
    );
  }

  void getCoursesEnrolledIn() async {
    coursesEnrolledIn = [];
    try {
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(documentId).get();
      List<dynamic> coursesRef = userSnapshot['courses_enrolled_in'];

      for (dynamic courseRef in coursesRef) {
        DocumentSnapshot courseSnapshot = await courseRef.get();
        BloqoCourse course = BloqoCourse(
          name: courseSnapshot['name'],
          author: courseSnapshot['author_username'],
        );
        coursesEnrolledIn?.add(course);
      }
    } catch (e) {
      print("Error fetching courses: $e");
    }
  }

}