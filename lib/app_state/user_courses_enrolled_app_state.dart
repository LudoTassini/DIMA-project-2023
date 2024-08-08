import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/bloqo_user_course_enrolled.dart';

class UserCoursesEnrolledAppState with ChangeNotifier{

  List<BloqoUserCourseEnrolled>? _userCourses;

  List<BloqoUserCourseEnrolled>? _get() {
    return _userCourses;
  }

  void _set(List<BloqoUserCourseEnrolled> userCourses){
    _userCourses = userCourses;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

  void _deleteUserCourseEnrolled(BloqoUserCourseEnrolled userCourseEnrolled){
    if (_userCourses != null) {
      _userCourses!.remove(userCourseEnrolled);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _updateCourse(BloqoUserCourseEnrolled userCourse) {
    _userCourses?.removeWhere((x) => x.courseId == userCourse.courseId &&
        x.enrolledUserId == userCourse.enrolledUserId);

    _userCourses?.add(userCourse);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }

}

void saveUserCoursesEnrolledToAppState({required BuildContext context, required List<BloqoUserCourseEnrolled> courses}){
  Provider.of<UserCoursesEnrolledAppState>(context, listen: false)._set(courses);
}

void updateUserCoursesEnrolledToAppState({required BuildContext context, required BloqoUserCourseEnrolled userCourseEnrolled}){
  Provider.of<UserCoursesEnrolledAppState>(context, listen: false)._updateCourse(userCourseEnrolled);
}

List<BloqoUserCourseEnrolled>? getUserCoursesEnrolledFromAppState({required BuildContext context}){
  return Provider.of<UserCoursesEnrolledAppState>(context, listen: false)._get();
}

void deleteUserCourseEnrolledFromAppState({required BuildContext context, required BloqoUserCourseEnrolled userCourseEnrolled}){
  Provider.of<UserCoursesEnrolledAppState>(context, listen: false)._deleteUserCourseEnrolled(userCourseEnrolled);
}