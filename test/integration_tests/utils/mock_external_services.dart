import 'package:bloqo/model/bloqo_notification_data.dart';
import 'package:bloqo/model/bloqo_user_data.dart';
import 'package:bloqo/model/user_courses/bloqo_user_course_created_data.dart';
import 'package:bloqo/model/user_courses/bloqo_user_course_enrolled_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

class MockExternalServices {
  final FakeFirebaseFirestore fakeFirestore;
  final MockFirebaseAuth mockFirebaseAuth;
  final MockFirebaseStorage mockFirebaseStorage;

  final BloqoUserData testUser;
  final BloqoUserCourseCreatedData testCourseCreated;
  final BloqoUserCourseEnrolledData testCourseEnrolled;
  final BloqoNotificationData testNotification;

  MockExternalServices()
      : fakeFirestore = FakeFirebaseFirestore(),
        mockFirebaseStorage = MockFirebaseStorage(),
        testUser = BloqoUserData(
          id: "test",
          email: "test@bloqo.com",
          username: "test",
          fullName: "test",
          isFullNameVisible: false,
          pictureUrl: "none",
          followers: [],
          following: [],
        ),
        testCourseCreated = BloqoUserCourseCreatedData(
          courseId: "test",
          courseName: "test",
          numSectionsCreated: 1,
          numChaptersCreated: 1,
          authorId: "test",
          published: false,
          lastUpdated: Timestamp.now(),
        ),
        testCourseEnrolled = BloqoUserCourseEnrolledData(
          courseId: "test",
          publishedCourseId: "test",
          courseAuthor: "test",
          enrolledUserId: "test",
          courseName: "test",
          sectionsCompleted: [],
          chaptersCompleted: [],
          totNumSections: 1,
          authorId: "test",
          lastUpdated: Timestamp.now(),
          enrollmentDate: Timestamp.now(),
          isRated: false,
          isCompleted: false,
        ),
        testNotification = BloqoNotificationData(
          id: "test",
          userId: "test",
          type: BloqoNotificationType.courseEnrollmentRequest.toString(),
          timestamp: Timestamp.now(),
          privatePublishedCourseId: "test",
          applicantId: "test",
        ),

        mockFirebaseAuth = MockFirebaseAuth(
          mockUser: MockUser(
            isAnonymous: false,
            uid: 'test',
            email: 'test@bloqo.com',
            displayName: 'test',
          ),
        );

  Future<void> prepare() async {
    await fakeFirestore.collection('users').doc('test').set(testUser.toFirestore());
    await fakeFirestore.collection('user_course_created').doc('test').set(testCourseCreated.toFirestore());
    await fakeFirestore.collection('user_course_enrolled').doc('test').set(testCourseEnrolled.toFirestore());
    await fakeFirestore.collection('notifications').doc('test').set(testNotification.toFirestore());
  }
}