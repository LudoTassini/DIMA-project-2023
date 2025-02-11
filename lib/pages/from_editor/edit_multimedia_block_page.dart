import 'dart:io';

import 'package:bloqo/app_state/application_settings_app_state.dart';
import 'package:bloqo/app_state/user_courses_created_app_state.dart';
import 'package:bloqo/components/forms/bloqo_dropdown.dart';
import 'package:bloqo/components/forms/bloqo_text_field.dart';
import 'package:bloqo/components/multimedia/bloqo_youtube_player.dart';
import 'package:bloqo/components/navigation/bloqo_breadcrumbs.dart';
import 'package:bloqo/model/user_courses/bloqo_user_course_created_data.dart';
import 'package:bloqo/model/courses/bloqo_chapter_data.dart';
import 'package:bloqo/utils/check_device.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../app_state/editor_course_app_state.dart';
import '../../components/buttons/bloqo_filled_button.dart';
import '../../components/containers/bloqo_main_container.dart';
import '../../components/containers/bloqo_seasalt_container.dart';
import '../../components/custom/bloqo_snack_bar.dart';
import '../../components/multimedia/bloqo_audio_player.dart';
import '../../components/multimedia/bloqo_video_player.dart';
import '../../components/popups/bloqo_confirmation_alert.dart';
import '../../components/popups/bloqo_error_alert.dart';
import '../../model/courses/bloqo_block_data.dart';
import '../../model/courses/bloqo_course_data.dart';
import '../../model/courses/bloqo_section_data.dart';
import '../../utils/bloqo_exception.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';
import '../../utils/multimedia_uploader.dart';

class EditMultimediaBlockPage extends StatefulWidget {
  const EditMultimediaBlockPage({
    super.key,
    required this.onPush,
    required this.courseId,
    required this.chapterId,
    required this.sectionId,
    required this.block
  });

  final void Function(Widget) onPush;
  final String courseId;
  final String chapterId;
  final String sectionId;
  final BloqoBlockData block;

  @override
  State<EditMultimediaBlockPage> createState() => _EditMultimediaBlockPageState();
}

class _EditMultimediaBlockPageState extends State<EditMultimediaBlockPage> with AutomaticKeepAliveClientMixin<EditMultimediaBlockPage> {

  bool firstBuild = true;

  final formKeyYouTube = GlobalKey<FormState>();

  late TextEditingController multimediaTypeController;
  late TextEditingController youTubeLinkController;

  bool showEmbedFromYouTube = false;

  @override
  void initState() {
    super.initState();
    multimediaTypeController = TextEditingController();
    youTubeLinkController = TextEditingController();
  }

  void _onMultimediaTypeChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    multimediaTypeController.removeListener(_onMultimediaTypeChanged);
    multimediaTypeController.dispose();
    youTubeLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizedText = getAppLocalizations(context)!;
    bool isTablet = checkDevice(context);

    return Consumer<ApplicationSettingsAppState>(
        builder: (context, applicationSettingsAppState, _) {
          var theme = getAppThemeFromAppState(context: context);
          return BloqoMainContainer(
            alignment: const AlignmentDirectional(-1.0, -1.0),
            child: Consumer<EditorCourseAppState>(
              builder: (context, editorCourseAppState, _) {
                BloqoCourseData course = getEditorCourseFromAppState(
                    context: context)!;
                BloqoChapterData chapter = getEditorCourseChapterFromAppState(
                    context: context, chapterId: widget.chapterId)!;
                BloqoSectionData section = getEditorCourseSectionFromAppState(
                    context: context,
                    chapterId: widget.chapterId,
                    sectionId: widget.sectionId)!;
                BloqoBlockData block = getEditorCourseBlockFromAppState(
                    context: context,
                    sectionId: widget.sectionId,
                    blockId: widget.block.id)!;
                List<DropdownMenuEntry<
                    String>> multimediaTypes = buildMultimediaTypesList(
                    localizedText: localizedText);
                if (firstBuild && block.type != null) {
                  multimediaTypeController.text = multimediaTypes.where((entry) =>
                  entry.label ==
                      BloqoBlockTypeExtension.fromString(block.type!)!
                          .multimediaShortText(
                          localizedText: localizedText)!).first.label;
                }
                if (firstBuild) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    multimediaTypeController.addListener(_onMultimediaTypeChanged);
                  });
                  firstBuild = false;
                }
                bool editable = !course.published;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BloqoBreadcrumbs(breadcrumbs: [
                      course.name,
                      chapter.name,
                      section.name,
                      block.name,
                    ]),
                    Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Padding(
                            padding: !isTablet
                                ? const EdgeInsetsDirectional.all(0)
                                : Constants.tabletPadding,
                            child: Column(
                              children: [
                                if(editable)
                                  BloqoSeasaltContainer(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 20, 20, 0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(20, 20, 20, 0),
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              localizedText.choose_multimedia_type,
                                              style: theme
                                                  .getThemeData()
                                                  .textTheme
                                                  .displayLarge
                                                  ?.copyWith(
                                                color: theme.colors.leadingColor,
                                                fontSize: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Row(
                                            children: [
                                              Expanded(
                                                  child: Padding(
                                                      padding: const EdgeInsetsDirectional
                                                          .fromSTEB(20, 20, 20, 20),
                                                      child: LayoutBuilder(
                                                          builder: (
                                                              BuildContext context,
                                                              BoxConstraints constraints) {
                                                            double availableWidth = constraints
                                                                .maxWidth;
                                                            return Column(
                                                                mainAxisSize: MainAxisSize
                                                                    .max,
                                                                children: [
                                                                  BloqoDropdown(
                                                                      controller: multimediaTypeController,
                                                                      dropdownMenuEntries: multimediaTypes,
                                                                      initialSelection: multimediaTypeController
                                                                          .text ==
                                                                          ""
                                                                          ? multimediaTypes[0]
                                                                          .value
                                                                          : multimediaTypeController
                                                                          .text,
                                                                      width: availableWidth
                                                                  )
                                                                ]
                                                            );
                                                          }
                                                      )
                                                  )
                                              )
                                            ]
                                        ),
                                      ],
                                    ),
                                  ),
                                BloqoSeasaltContainer(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        20, 20, 20, 0),
                                    child: Column(
                                      children: [
                                        if(multimediaTypeController.text ==
                                            BloqoBlockType.multimediaAudio
                                                .multimediaShortText(
                                                localizedText: localizedText) &&
                                            (block.content == "" || block.type !=
                                                BloqoBlockType.multimediaAudio
                                                    .toString()))
                                          Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 20, 20, 0),
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      localizedText.upload_audio,
                                                      style: theme
                                                          .getThemeData()
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(20, 20, 20, 20),
                                                    child: BloqoFilledButton(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: !isTablet
                                                            ? Constants
                                                            .fontSizeNotTablet
                                                            : Constants
                                                            .fontSizeTablet,
                                                        height: !isTablet
                                                            ? Constants
                                                            .heightNotTablet
                                                            : Constants
                                                            .heightTablet,
                                                        onPressed: () async {
                                                          final newUrl = await _askUserForAnAudio(
                                                              context: context,
                                                              localizedText: localizedText,
                                                              courseId: widget
                                                                  .courseId,
                                                              blockId: widget.block
                                                                  .id
                                                          );
                                                          if (newUrl != null) {
                                                            if (!context.mounted) return;
                                                            block.content = newUrl;
                                                            await _saveChanges(
                                                                context: context,
                                                                courseId: widget
                                                                    .courseId,
                                                                sectionId: widget
                                                                    .sectionId,
                                                                block: block,
                                                                blockType: BloqoBlockType
                                                                    .multimediaAudio);
                                                            if (!context.mounted) return;
                                                            updateEditorCourseBlockInAppState(
                                                                context: context,
                                                                sectionId: section
                                                                    .id,
                                                                block: block);
                                                          }
                                                        },
                                                        text: localizedText
                                                            .upload_from_device,
                                                        icon: Icons.upload
                                                    )
                                                ),
                                              ]
                                          ),
                                        if(multimediaTypeController.text ==
                                            BloqoBlockType.multimediaImage
                                                .multimediaShortText(
                                                localizedText: localizedText) &&
                                            (block.content == "" || block.type !=
                                                BloqoBlockType.multimediaImage
                                                    .toString()))
                                          Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 20, 20, 0),
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      localizedText.upload_image,
                                                      style: theme
                                                          .getThemeData()
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(20, 20, 20, 20),
                                                    child: BloqoFilledButton(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: !isTablet
                                                            ? Constants
                                                            .fontSizeNotTablet
                                                            : Constants
                                                            .fontSizeTablet,
                                                        height: !isTablet
                                                            ? Constants
                                                            .heightNotTablet
                                                            : Constants
                                                            .heightTablet,
                                                        onPressed: () async {
                                                          final newUrl = await _askUserForAnImage(
                                                              context: context,
                                                              localizedText: localizedText,
                                                              courseId: widget
                                                                  .courseId,
                                                              blockId: widget.block
                                                                  .id
                                                          );
                                                          if (newUrl != null) {
                                                            if (!context.mounted) return;
                                                            block.content = newUrl;
                                                            await _saveChanges(
                                                                context: context,
                                                                courseId: widget
                                                                    .courseId,
                                                                sectionId: widget
                                                                    .sectionId,
                                                                block: block,
                                                                blockType: BloqoBlockType
                                                                    .multimediaImage);
                                                            if (!context.mounted) return;
                                                            updateEditorCourseBlockInAppState(
                                                                context: context,
                                                                sectionId: section
                                                                    .id,
                                                                block: block);
                                                          }
                                                        },
                                                        text: localizedText
                                                            .upload_from_device,
                                                        icon: Icons.upload
                                                    )
                                                ),
                                              ]
                                          ),
                                        if(multimediaTypeController.text ==
                                            BloqoBlockType.multimediaVideo
                                                .multimediaShortText(
                                                localizedText: localizedText) &&
                                            (block.content == "" || block.type !=
                                                BloqoBlockType.multimediaVideo
                                                    .toString()))
                                          Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 20, 20, 0),
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      localizedText.upload_video,
                                                      style: theme
                                                          .getThemeData()
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(20, 20, 20, 0),
                                                    child: BloqoFilledButton(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: !isTablet
                                                            ? Constants
                                                            .fontSizeNotTablet
                                                            : Constants
                                                            .fontSizeTablet,
                                                        height: !isTablet
                                                            ? Constants
                                                            .heightNotTablet
                                                            : Constants
                                                            .heightTablet,
                                                        onPressed: () async {
                                                          final newUrl = await _askUserForAVideo(
                                                              context: context,
                                                              localizedText: localizedText,
                                                              courseId: widget
                                                                  .courseId,
                                                              blockId: widget.block
                                                                  .id
                                                          );
                                                          if (newUrl != null) {
                                                            if (!context.mounted) return;
                                                            block.content = newUrl;
                                                            await _saveChanges(
                                                                context: context,
                                                                courseId: widget
                                                                    .courseId,
                                                                sectionId: widget
                                                                    .sectionId,
                                                                block: block,
                                                                blockType: BloqoBlockType
                                                                    .multimediaVideo);
                                                            if (!context.mounted) return;
                                                            updateEditorCourseBlockInAppState(
                                                                context: context,
                                                                sectionId: section
                                                                    .id,
                                                                block: block);
                                                          }
                                                        },
                                                        text: localizedText
                                                            .upload_from_device,
                                                        icon: Icons.upload
                                                    )
                                                ),
                                                Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(20, 10, 20, 20),
                                                    child: BloqoFilledButton(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        onPressed: () {
                                                          setState(() {
                                                            showEmbedFromYouTube =
                                                            true;
                                                          });
                                                        },
                                                        text: localizedText
                                                            .embed_from_youtube,
                                                        icon: Icons.link
                                                    )
                                                )
                                              ]
                                          )
                                      ],
                                    )
                                ),
                                if(multimediaTypeController.text == BloqoBlockType
                                    .multimediaVideo.multimediaShortText(
                                    localizedText: localizedText) &&
                                    showEmbedFromYouTube)
                                  BloqoSeasaltContainer(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20, 20, 20, 120),
                                      child: Column(
                                        children: [
                                          Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 20, 20, 0),
                                                  child: Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Text(
                                                      localizedText
                                                          .embed_from_youtube,
                                                      style: theme
                                                          .getThemeData()
                                                          .textTheme
                                                          .displayLarge
                                                          ?.copyWith(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        fontSize: 30,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Form(
                                                    key: formKeyYouTube,
                                                    child: BloqoTextField(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 10),
                                                      formKey: formKeyYouTube,
                                                      controller: youTubeLinkController,
                                                      labelText: localizedText.youtube_link,
                                                      hintText: localizedText.enter_youtube_link,
                                                      maxInputLength: Constants.maxYouTubeLinkLength,
                                                      isDisabled: !editable
                                                    )
                                                ),
                                                Padding(
                                                    padding: const EdgeInsetsDirectional
                                                        .fromSTEB(20, 10, 20, 20),
                                                    child: BloqoFilledButton(
                                                        color: theme.colors
                                                            .leadingColor,
                                                        onPressed: () async {
                                                          await _embedYouTubeVideo(
                                                              context: context,
                                                              localizedText: localizedText,
                                                              videoUrl: youTubeLinkController
                                                                  .text,
                                                              courseId: course.id,
                                                              sectionId: section.id,
                                                              block: widget.block
                                                          );
                                                        },
                                                        text: localizedText.embed,
                                                        icon: Icons.link
                                                    )
                                                )
                                              ]
                                          )
                                        ],
                                      )
                                  ),
                                if(multimediaTypeController.text == BloqoBlockType
                                    .multimediaAudio.multimediaShortText(
                                    localizedText: localizedText) && widget.block
                                    .type == BloqoBlockType.multimediaAudio
                                    .toString())
                                  BloqoSeasaltContainer(
                                      padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 20),
                                      child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(20, 20, 20, 0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  localizedText
                                                      .multimedia_audio_short,
                                                  style: theme
                                                      .getThemeData()
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                    color: theme.colors
                                                        .leadingColor,
                                                    fontSize: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: BloqoAudioPlayer(
                                                    url: widget.block.content
                                                )
                                            ),
                                            if(editable)
                                              Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 0, 20, 20),
                                                  child: BloqoFilledButton(
                                                      color: theme.colors.error,
                                                      onPressed: () {
                                                        showBloqoConfirmationAlert(
                                                            context: context,
                                                            title: localizedText
                                                                .warning,
                                                            description: localizedText
                                                                .delete_file_confirmation,
                                                            confirmationFunction: () async {
                                                              await _tryDeleteFile(
                                                                  context: context,
                                                                  localizedText: localizedText,
                                                                  filePath: 'audios/courses/${course
                                                                      .id}/${block
                                                                      .id}',
                                                                  courseId: course
                                                                      .id,
                                                                  sectionId: section
                                                                      .id,
                                                                  block: block
                                                              );
                                                            },
                                                            backgroundColor: theme
                                                                .colors.error
                                                        );
                                                      },
                                                      text: localizedText
                                                          .delete_file,
                                                      icon: Icons.delete_forever
                                                  )
                                              )
                                          ]
                                      )
                                  ),
                                if(multimediaTypeController.text == BloqoBlockType
                                    .multimediaImage.multimediaShortText(
                                    localizedText: localizedText) && widget.block
                                    .type == BloqoBlockType.multimediaImage
                                    .toString())
                                  BloqoSeasaltContainer(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20, 0, 20, 20),
                                      child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(20, 20, 20, 0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  localizedText
                                                      .multimedia_image_short,
                                                  style: theme
                                                      .getThemeData()
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                    color: theme.colors
                                                        .leadingColor,
                                                    fontSize: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: _getImage(
                                                    url: widget.block.content)
                                            ),
                                            if(editable)
                                              Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 0, 20, 20),
                                                  child: BloqoFilledButton(
                                                      color: theme.colors.error,
                                                      onPressed: () {
                                                        showBloqoConfirmationAlert(
                                                            context: context,
                                                            title: localizedText
                                                                .warning,
                                                            description: localizedText
                                                                .delete_file_confirmation,
                                                            confirmationFunction: () async {
                                                              await _tryDeleteFile(
                                                                  context: context,
                                                                  localizedText: localizedText,
                                                                  filePath: 'images/courses/${course
                                                                      .id}/${block
                                                                      .id}',
                                                                  courseId: course
                                                                      .id,
                                                                  sectionId: section
                                                                      .id,
                                                                  block: block
                                                              );
                                                            },
                                                            backgroundColor: theme
                                                                .colors.error
                                                        );
                                                      },
                                                      text: localizedText
                                                          .delete_file,
                                                      icon: Icons.delete_forever
                                                  )
                                              )
                                          ]
                                      )
                                  ),
                                if(multimediaTypeController.text == BloqoBlockType
                                    .multimediaVideo.multimediaShortText(
                                    localizedText: localizedText) && widget.block
                                    .type == BloqoBlockType.multimediaVideo
                                    .toString())
                                  BloqoSeasaltContainer(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          20, 0, 20, 20),
                                      child: widget.block.content != "" ? Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional
                                                  .fromSTEB(20, 20, 20, 0),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  localizedText
                                                      .multimedia_video_short,
                                                  style: theme
                                                      .getThemeData()
                                                      .textTheme
                                                      .displayLarge
                                                      ?.copyWith(
                                                    color: theme.colors
                                                        .leadingColor,
                                                    fontSize: 30,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            !widget.block.content.startsWith("yt:")
                                                ? BloqoVideoPlayer(
                                                url: widget.block.content
                                            )
                                                : BloqoYouTubePlayer(
                                                url: _getYouTubeUrl(
                                                    str: widget.block.content)),
                                            if(editable)
                                              Padding(
                                                  padding: const EdgeInsetsDirectional
                                                      .fromSTEB(20, 0, 20, 20),
                                                  child: BloqoFilledButton(
                                                      color: theme.colors.error,
                                                      onPressed: () {
                                                        showBloqoConfirmationAlert(
                                                            context: context,
                                                            title: localizedText
                                                                .warning,
                                                            description: localizedText
                                                                .delete_file_confirmation,
                                                            confirmationFunction: () async {
                                                              !widget.block.content
                                                                  .startsWith("yt:")
                                                                  ?
                                                              await _tryDeleteFile(
                                                                  context: context,
                                                                  localizedText: localizedText,
                                                                  filePath: 'videos/courses/${course
                                                                      .id}/${block
                                                                      .id}',
                                                                  courseId: course
                                                                      .id,
                                                                  sectionId: section
                                                                      .id,
                                                                  block: block
                                                              )
                                                                  : await _tryDeleteYouTubeLink(
                                                                  context: context,
                                                                  localizedText: localizedText,
                                                                  courseId: course
                                                                      .id,
                                                                  sectionId: section
                                                                      .id,
                                                                  block: block
                                                              );
                                                            },
                                                            backgroundColor: theme
                                                                .colors.error
                                                        );
                                                      },
                                                      text: localizedText
                                                          .delete_file,
                                                      icon: Icons.delete_forever
                                                  )
                                              )
                                          ]
                                      ) : Container()
                                  ),
                              ],
                            ),
                          ),
                        )
                    ),
                  ],
                );
              },
            ),
          );
        }
    );
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _tryDeleteFile({required BuildContext context, required var localizedText, required String filePath, required String courseId, required String sectionId, required BloqoBlockData block}) async {
    context.loaderOverlay.show();
    try {
      var firestore = getFirestoreFromAppState(context: context);
      var storage = getStorageFromAppState(context: context);

      await deleteFile(storage: storage, localizedText: localizedText, filePath: filePath);

      block.type = null;
      block.name = getNameBasedOnBlockSuperType(localizedText: localizedText,
          superType: BloqoBlockSuperType.multimedia);
      block.content = "";

      await saveBlockChanges(
        firestore: firestore,
        localizedText: localizedText,
        updatedBlock: block,
      );

      if (!context.mounted) return;
      BloqoUserCourseCreatedData userCourseCreated = getUserCoursesCreatedFromAppState(
          context: context)!.where((course) => course.courseId == courseId)
          .first;
      updateEditorCourseBlockInAppState(
          context: context, sectionId: sectionId, block: block);

      await saveUserCourseCreatedChanges(
          firestore: firestore,
          localizedText: localizedText,
          updatedUserCourseCreated: userCourseCreated
      );

      if (!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoSnackBar(context: context, text: localizedText.done);
    } on BloqoException catch (e) {
      if (!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoErrorAlert(
          context: context,
          title: localizedText.error_title,
          description: e.message
      );
    }
  }

  Future<void> _tryDeleteYouTubeLink({required BuildContext context, required var localizedText, required String courseId, required String sectionId, required BloqoBlockData block}) async {
    context.loaderOverlay.show();
    try {

      var firestore = getFirestoreFromAppState(context: context);

      block.name = getNameBasedOnBlockSuperType(localizedText: localizedText,
          superType: BloqoBlockSuperType.multimedia);
      block.content = "";

      await saveBlockChanges(
        firestore: firestore,
        localizedText: localizedText,
        updatedBlock: block,
      );

      if (!context.mounted) return;
      BloqoUserCourseCreatedData userCourseCreated = getUserCoursesCreatedFromAppState(
          context: context)!.where((course) => course.courseId == courseId)
          .first;
      updateEditorCourseBlockInAppState(
          context: context, sectionId: sectionId, block: block);

      await saveUserCourseCreatedChanges(
          firestore: firestore,
          localizedText: localizedText,
          updatedUserCourseCreated: userCourseCreated
      );

      if (!context.mounted) return;
      context.loaderOverlay.hide();
    } on BloqoException catch (e) {
      if (!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoErrorAlert(
          context: context,
          title: localizedText.error_title,
          description: e.message
      );
    }
  }

  Future<void> _saveChanges({required BuildContext context, required String courseId, required String sectionId, required BloqoBlockData block, required BloqoBlockType blockType}) async {
    var localizedText = getAppLocalizations(context)!;

    block.type = blockType.toString();
    block.name = getNameBasedOnBlockType(localizedText: localizedText, type: blockType);

    var firestore = getFirestoreFromAppState(context: context);

    await saveBlockChanges(
      firestore: firestore,
      localizedText: localizedText,
      updatedBlock: block,
    );

    if (!context.mounted) return;
    BloqoUserCourseCreatedData userCourseCreated = getUserCoursesCreatedFromAppState(context: context)!.where((course) => course.courseId == courseId).first;
    updateEditorCourseBlockInAppState(context: context, sectionId: sectionId, block: block);

    await saveUserCourseCreatedChanges(
        firestore: firestore,
        localizedText: localizedText,
        updatedUserCourseCreated: userCourseCreated
    );
  }

  Future<String?> _askUserForAnAudio({
    required BuildContext context,
    required var localizedText,
    required String courseId,
    required String blockId,
  }) async {

    if(getFromTestFromAppState(context: context)){
      return "assets/tests/test.wav";
    }

    final pickedFileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (pickedFileResult != null && pickedFileResult.files.isNotEmpty) {
      final pickedFile = pickedFileResult.files.first;
      if (pickedFile.path != null) {
        if (!context.mounted) return null;
        context.loaderOverlay.show();

        try {

          var firestore = getFirestoreFromAppState(context: context);
          var storage = getStorageFromAppState(context: context);

          final audio = File(pickedFile.path!);
          final url = await uploadBlockAudio(
            firestore: firestore,
            storage: storage,
            localizedText: localizedText,
            audio: audio,
            courseId: courseId,
            blockId: blockId,
          );
          if (!context.mounted) return null;
          context.loaderOverlay.hide();

          showBloqoSnackBar(
              context: context,
              text: localizedText.done
          );
          return url;
        } on BloqoException catch (e) {
          if (!context.mounted) return null;
          context.loaderOverlay.hide();
          showBloqoErrorAlert(
            context: context,
            title: localizedText.error_title,
            description: e.message,
          );
        }
      }
    }
    return null;
  }

  Future<String?> _askUserForAnImage({required BuildContext context, required var localizedText, required String courseId, required String blockId}) async {
    if(getFromTestFromAppState(context: context)){
      return "assets/tests/test.png";
    }

    PermissionStatus permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        if (!context.mounted) return null;
        context.loaderOverlay.show();

        try {
          var firestore = getFirestoreFromAppState(context: context);
          var storage = getStorageFromAppState(context: context);

          final image = File(pickedFile.path);
          final url = await uploadBlockImage(
              firestore: firestore,
              storage: storage,
              localizedText: localizedText,
              image: image,
              courseId: courseId,
              blockId: blockId
          );
          if (!context.mounted) return null;
          context.loaderOverlay.hide();

          showBloqoSnackBar(
              context: context,
              text: localizedText.done
          );
          return url;
        } on BloqoException catch (e) {
          if (!context.mounted) return null;
          context.loaderOverlay.hide();
          showBloqoErrorAlert(
            context: context,
            title: localizedText.error_title,
            description: e.message,
          );
        }
      }
    }
    return null;
  }

  Future<String?> _askUserForAVideo({required BuildContext context, required var localizedText, required String courseId, required String blockId}) async {

    if(getFromTestFromAppState(context: context)){
      return "assets/tests/test.mov";
    }

    PermissionStatus permissionStatus = await Permission.photos.request();

    if (permissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        if (!context.mounted) return null;
        context.loaderOverlay.show();

        try {
          var firestore = getFirestoreFromAppState(context: context);
          var storage = getStorageFromAppState(context: context);

          final video = File(pickedFile.path);
          final url = await uploadBlockVideo(
            firestore: firestore,
            storage: storage,
            localizedText: localizedText,
            video: video,
            courseId: courseId,
            blockId: blockId
          );
          if (!context.mounted) return null;
          context.loaderOverlay.hide();

          showEmbedFromYouTube = false;

          showBloqoSnackBar(context: context, text: localizedText.done);
          return url;
        } on BloqoException catch (e) {
          if (!context.mounted) return null;
          context.loaderOverlay.hide();
          showBloqoErrorAlert(
            context: context,
            title: localizedText.error_title,
            description: e.message,
          );
        }
      }
    }
    return null;
  }

  Future<void> _embedYouTubeVideo({required BuildContext context, required var localizedText, required String videoUrl, required String courseId, required String sectionId, required BloqoBlockData block}) async {
      
    context.loaderOverlay.show();
    
    try {

      var firestore = getFirestoreFromAppState(context: context);

      await saveBlockVideoUrl(
          firestore: firestore,
          localizedText: localizedText,
          videoUrl: "yt:$videoUrl",
          blockId: block.id
      );

      block.content = "yt:$videoUrl";
      block.name = getNameBasedOnBlockType(localizedText: localizedText, type: BloqoBlockType.multimediaVideo);
      block.type = BloqoBlockType.multimediaVideo.toString();

      if (!context.mounted) return;
      BloqoUserCourseCreatedData updatedUserCourseCreated = getUserCoursesCreatedFromAppState(context: context)!.where((course) => course.courseId == courseId).first;
      await saveUserCourseCreatedChanges(
          firestore: firestore,
          localizedText: localizedText,
          updatedUserCourseCreated: updatedUserCourseCreated
      );
      
      if (!context.mounted) return;
      updateEditorCourseBlockInAppState(context: context, sectionId: sectionId, block: block);
      
      context.loaderOverlay.hide();

      showBloqoSnackBar(
          context: context,
          text: localizedText.done
      );
      
    } on BloqoException catch (e) {
      if (!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoErrorAlert(
        context: context,
        title: localizedText.error_title,
        description: e.message,
      );
    }
  }

  Widget _getImage({required String url}){
    return url == "assets/tests/test.png" ?
      Image.asset(url) :
      Image.network(widget.block.content);
  }

  String _getYouTubeUrl({required String str}){
    if(str.startsWith("yt:")){
      return str.substring(3);
    }
    else{
      return str;
    }
  }

}