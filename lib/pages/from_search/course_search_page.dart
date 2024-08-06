import 'package:bloqo/components/buttons/bloqo_text_button.dart';
import 'package:bloqo/components/containers/bloqo_main_container.dart';
import 'package:bloqo/components/containers/bloqo_seasalt_container.dart';
import 'package:bloqo/model/bloqo_review.dart';
import 'package:bloqo/model/courses/bloqo_chapter.dart';
import 'package:bloqo/model/courses/bloqo_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../app_state/user_courses_enrolled_app_state.dart';
import '../../components/buttons/bloqo_filled_button.dart';
import '../../components/complex/bloqo_course_section.dart';
import '../../model/bloqo_user.dart';
import '../../model/bloqo_user_course_enrolled.dart';
import '../../model/courses/bloqo_course.dart';
import '../../style/bloqo_colors.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';
import 'package:intl/intl.dart';

class CourseSearchPage extends StatefulWidget {

  const CourseSearchPage({
    super.key,
    required this.onPush,
    required this.course,
    required this.chapters,
    required this.sections,
    required this.courseAuthor,
    required this.rating
  });

  final void Function(Widget) onPush;
  final BloqoCourse course;
  final List<BloqoChapter> chapters;
  final Map<String, List<BloqoSection>> sections;
  final BloqoUser courseAuthor;
  final double rating;

  @override
  State<CourseSearchPage> createState() => _CourseSearchPageState();
}

class _CourseSearchPageState extends State<CourseSearchPage> with AutomaticKeepAliveClientMixin<CourseSearchPage> {

  bool isEnrolled = false;
  BloqoUserCourseEnrolled? enrolledCourse;

  final Map<String, bool> _showSectionsMap = {};
  bool isInitializedSectionMap = false;

  int _reviewsDisplayed = Constants.reviewsToShowAtFirst;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizedText = getAppLocalizations(context)!;

    void initializeSectionsToShowMap(List<BloqoChapter> chapters) {
      _showSectionsMap[chapters[0].id] = true;
      isInitializedSectionMap = true;
    }

    void loadCompletedSections(String chapterId) {
      setState(() {
        _showSectionsMap[chapterId] = true;
      });
    }

    void hideSections(String chapterId) {
      setState(() {
        _showSectionsMap.remove(chapterId);
      });
    }

    if(!isInitializedSectionMap) {
      initializeSectionsToShowMap(widget.chapters);
    }

    void loadMorePublishedCourses() {
      setState(() {
        _reviewsDisplayed += Constants.reviewsToFurtherLoadAtRequest;
      });
    }

    return BloqoMainContainer(
      alignment: const AlignmentDirectional(-1.0, -1.0),
      child: Consumer<UserCoursesEnrolledAppState>(
        builder: (context, userCoursesEnrolledAppState, _) {
          List<BloqoUserCourseEnrolled> userCoursesEnrolled = getUserCoursesEnrolledFromAppState(context: context) ?? [];

          if(userCoursesEnrolled.any((enrolledCourse) => enrolledCourse.courseId == widget.course.id)) {
            isEnrolled = true;
            enrolledCourse = userCoursesEnrolled.firstWhere(
                (enrolledCourse) => enrolledCourse.courseId == widget.course.id);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      widget.course.name,
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BloqoColors.seasalt,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
              ),
          ],
              ),

              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Text(
                            localizedText.by,
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: BloqoColors.seasalt,
                              fontSize: 16,
                            ),
                          ),
                          BloqoTextButton(
                            text: widget.courseAuthor.username,
                            color: BloqoColors.seasalt,
                            onPressed: () async {
                              // TODO
                            },
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                    RatingBarIndicator(
                      rating: widget.rating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: BloqoColors.tertiary,
                      ),
                      itemCount: 5,
                      itemSize: 24,
                      direction: Axis.horizontal,
                    ),
                  ],
                )
              ),

              Expanded(
                child:SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 4, 0, 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            localizedText.description,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                              color: BloqoColors.seasalt,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 12),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: widget.course.description != ''
                                ? Text(
                              widget.course.description!,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: BloqoColors.seasalt,
                                fontSize: 16,
                              ),
                            )
                                : const SizedBox.shrink(), // This will take up no space
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(20, 5, 20, 0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            localizedText.content,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(
                              color: BloqoColors.seasalt,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ...List.generate(
                                widget.chapters.length,
                                    (chapterIndex) {
                                  var chapter = widget.chapters[chapterIndex];

                                  return BloqoSeasaltContainer(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${localizedText.chapter} ${chapterIndex+1}',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .displayMedium
                                                    ?.copyWith(
                                                  color: BloqoColors.russianViolet,
                                                  fontSize: 18,
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(15, 5, 15, 0),
                                          child: Row(
                                            children: [
                                              Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  chapter.name,
                                                  style: Theme
                                                      .of(context)
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                    color: BloqoColors.russianViolet,
                                                    fontSize: 24,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                                          child: chapter.description != ''
                                              ? Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(15, 5, 15, 10),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Flexible(
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      chapter.description!,
                                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                                        color: BloqoColors.russianViolet,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                              : const SizedBox.shrink(), // This will take up no space
                                        ),

                                        ... (_showSectionsMap[chapter.id] == true
                                            ? [
                                          ...List.generate(
                                            widget.sections[chapter.id]!.length,
                                                (sectionIndex) {
                                              var section = widget.sections[chapter.id]![sectionIndex];
                                              return BloqoCourseSection(
                                                section: section,
                                                index: sectionIndex,
                                                isInLearnPage: false,
                                                onPressed: () async {
                                                  // TODO
                                                },
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 5),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Opacity(
                                                  opacity: 0.9,
                                                  child: Align(
                                                    alignment: const AlignmentDirectional(1, 0),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        hideSections(chapter.id);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            localizedText.collapse,
                                                            style: const TextStyle(
                                                              color: BloqoColors.secondaryText,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const Icon(
                                                            Icons.keyboard_arrow_up_sharp,
                                                            color: BloqoColors.secondaryText,
                                                            size: 25,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        ]

                                            : [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 5),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Opacity(
                                                  opacity: 0.9,
                                                  child: Align(
                                                    alignment: const AlignmentDirectional(1, 0),
                                                    child: TextButton(
                                                      onPressed: () {
                                                        loadCompletedSections(chapter.id);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            localizedText.view_more,
                                                            style: const TextStyle(
                                                              color: BloqoColors.secondaryText,
                                                              fontSize: 14,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const Icon(
                                                            Icons.keyboard_arrow_right_sharp,
                                                            color: BloqoColors.secondaryText,
                                                            size: 25,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(20, 15, 20, 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        localizedText.reviews,
                                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          color: BloqoColors.seasalt,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ),
                                    const Spacer(), // This will create space between the first Text and the rest of the Row
                                    Row(
                                      children: [
                                        Text(
                                          widget.rating.toDouble().toString(),
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            color: BloqoColors.seasalt,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),

                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                                          child: RatingBarIndicator(
                                            rating: widget.rating,
                                            itemBuilder: (context, index) => const Icon(
                                              Icons.star,
                                              color: BloqoColors.tertiary,
                                            ),
                                            itemCount: 5,
                                            itemSize: 24,
                                            direction: Axis.horizontal,
                                          ),
                                        ),
                                        Text(
                                          '(${widget.course.reviews?.length.toString() ?? '0'})',
                                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            color: BloqoColors.seasalt,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              BloqoSeasaltContainer(
                                  child:
                                    widget.course.reviews == null ?
                                    Text(
                                      localizedText.no_reviews_yet,
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        color: BloqoColors.russianViolet,
                                        fontSize: 15,
                                      ),
                                    )
                                  : Column(
                                      children: List.generate(
                                      _reviewsDisplayed > widget.course.reviews!.length ?
                                      widget.course.reviews!.length : _reviewsDisplayed,
                                          (index) {

                                        BloqoReview review = widget.publishedCourses[index];
                                        return BloqoSearchResultCourse(
                                          review: review,
                                        );
                                      },
                                    ),
                              ),

                              ),

                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20, 0, 20, 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child:
                                      isEnrolled ?
                                        Text(
                                          localizedText.enrolled_on +
                                              DateFormat('dd/MM/yyyy').format(enrolledCourse!.enrollmentDate.toDate()),
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                            color: BloqoColors.seasalt,
                                            fontSize: 16,
                                          ),
                                        )
                                      : Text(
                                        localizedText.published_on +
                                            DateFormat('dd/MM/yyyy').format(widget.course.publicationDate!.toDate()),
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .displaySmall
                                            ?.copyWith(
                                          color: BloqoColors.seasalt,
                                          fontSize: 16,
                                        ),
                                      )

                                    ),

                                    if(isEnrolled)
                                      Flexible(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 0, 0), //24, 0, 24, 0
                                          child: BloqoFilledButton(
                                            color: BloqoColors.error,
                                            onPressed: () async {
                                              //TODO
                                            },
                                            text: localizedText.delete,
                                            icon: Icons.close_sharp,
                                          ),
                                        ),
                                      ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.start,
                direction: Axis.horizontal,
                runAlignment: WrapAlignment.start,
                verticalDirection: VerticalDirection.down,
                children: [
                  !isEnrolled?
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20, 10, 20, 10),
                      child: BloqoFilledButton(
                        onPressed: () =>
                            () async {
                          // TODO
                          //widget.onNavigateToPage(3),
                        },
                        height: 60,
                        color: BloqoColors.russianViolet,
                        text: localizedText.enroll_in,
                        icon: Icons.add,
                        fontSize: 24,
                      ),
                    )
                  : Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        20, 10, 20, 10),
                    child: BloqoFilledButton(
                      onPressed: () =>
                          () async {
                        // TODO
                        //widget.onNavigateToPage(3),
                      },
                      height: 60,
                      color: BloqoColors.error,
                      text: localizedText.unenroll,
                      fontSize: 24,
                    ),
                  )
                ],
              ),
            ],
          );

        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}