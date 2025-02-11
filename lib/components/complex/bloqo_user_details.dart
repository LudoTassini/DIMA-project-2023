import 'package:bloqo/app_state/application_settings_app_state.dart';
import 'package:bloqo/app_state/user_app_state.dart';
import 'package:bloqo/utils/check_device.dart';
import 'package:bloqo/utils/localization.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../model/bloqo_user_data.dart';
import '../../pages/from_any/qr_code_page.dart';
import '../../pages/from_any/user_list_page.dart';
import '../../utils/bloqo_exception.dart';
import '../../utils/bloqo_qr_code_type.dart';
import '../buttons/bloqo_filled_button.dart';
import '../buttons/bloqo_text_button.dart';
import '../containers/bloqo_seasalt_container.dart';
import '../custom/bloqo_snack_bar.dart';
import '../popups/bloqo_error_alert.dart';

class BloqoUserDetails extends StatefulWidget {

  const BloqoUserDetails({
    super.key,
    required this.user,
    required this.isFullNameVisible,
    required this.showFollowingOptions,
    required this.onPush,
    required this.onNavigateToPage,
    this.onReplacePicture,
  });

  final BloqoUserData user;
  final bool isFullNameVisible;
  final bool showFollowingOptions;
  final void Function(Widget) onPush;
  final void Function(int) onNavigateToPage;
  final void Function()? onReplacePicture;

  @override
  State<BloqoUserDetails> createState() => _BloqoUserDetailsState();

}

class _BloqoUserDetailsState extends State<BloqoUserDetails> {

  bool? currentlyFollowing;

  @override
  Widget build(BuildContext context) {
    String? url;
    bool isTablet = checkDevice(context);

    if(widget.user.pictureUrl != "none"){
      url = widget.user.pictureUrl;
    }
    currentlyFollowing ??= getUserFromAppState(context: context)!.following.contains(widget.user.id);
    var localizedText = getAppLocalizations(context)!;
    var theme = getAppThemeFromAppState(context: context);
    return BloqoSeasaltContainer(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 1,
                  child: Stack(
                    alignment: const AlignmentDirectional(0, 1),
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _getProfilePicture(context: context, url: url)
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(1, 1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colors.leadingColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(8),
                              topLeft: Radius.circular(0),
                              topRight: Radius.circular(0),
                            ),
                          ),
                          child: widget.onReplacePicture != null ? IconButton(
                            padding: !isTablet ? EdgeInsets.zero : const EdgeInsets.all(5),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              Icons.camera_alt,
                              color: theme.colors.highContrastColor,
                              size: !isTablet ? 22 : 40,
                            ),
                            onPressed: widget.onReplacePicture
                          ) : Container(),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if(widget.isFullNameVisible)
                                        Text(
                                          widget.user.fullName,
                                          textAlign: TextAlign.start,
                                          style: theme.getThemeData().textTheme.displayMedium?.copyWith(
                                            color: theme.colors.secondaryText,
                                            fontSize: !isTablet ? 16 : 22,
                                            letterSpacing: 0,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      Text(
                                        widget.user.username,
                                        textAlign: TextAlign.start,
                                        style: theme.getThemeData().textTheme.displayMedium?.copyWith(
                                          color: theme.colors.primaryText,
                                          fontSize: !isTablet ? 22 : 30,
                                          letterSpacing: 0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: const AlignmentDirectional(1, 0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colors.inBetweenColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.qr_code_2,
                                      color: theme.colors.highContrastColor,
                                      size: !isTablet ? 32 : 55,
                                    ),
                                    onPressed: () {
                                      _showUserQrCode(
                                        username: widget.user.username,
                                        userId: widget.user.id,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                            child: Wrap(
                              spacing: 15.0,
                              runSpacing: 0.0,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 15, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                          child: BloqoTextButton(
                                              text: localizedText.followers,
                                              color: theme.colors.primaryText,
                                              fontSize: !isTablet ? 18 : 20,
                                              onPressed: () {
                                                widget.onPush(UserListPage(
                                                  reference: widget.user,
                                                  followers: true,
                                                  onPush: widget.onPush,
                                                  onNavigateToPage: widget.onNavigateToPage,
                                                ));
                                              }
                                          )
                                      ),
                                      Text(
                                        widget.user.followers.length.toString(),
                                        style: theme.getThemeData().textTheme.displayMedium?.copyWith(
                                          fontSize: !isTablet ? 18 : 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 15, 0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 5, 0),
                                          child: BloqoTextButton(
                                              text: localizedText.following,
                                              color: theme.colors.primaryText,
                                              fontSize: !isTablet ? 18 : 20,
                                              onPressed: () {
                                                widget.onPush(UserListPage(
                                                  reference: widget.user,
                                                  followers: false,
                                                  onPush: widget.onPush,
                                                  onNavigateToPage: widget.onNavigateToPage,
                                                ));
                                              }
                                          )
                                      ),
                                      Text(
                                        widget.user.following.length.toString(),
                                        style: theme.getThemeData().textTheme.displayMedium?.copyWith(
                                          fontSize: !isTablet ? 18 : 20
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ],
            ),
            if(widget.showFollowingOptions)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
                child: !currentlyFollowing! ? BloqoFilledButton(
                  color: theme.colors.leadingColor,
                  icon: Icons.person_add_alt_1_rounded,
                  text: localizedText.follow,
                  onPressed: () async {
                    await _tryFollow(
                      context: context,
                      localizedText: localizedText
                    );
                  }
                ) : BloqoFilledButton(
                    color: theme.colors.error,
                    icon: Icons.person_remove_alt_1_rounded,
                    text: localizedText.unfollow,
                    onPressed: () async {
                      await _tryUnfollow(
                          context: context,
                          localizedText: localizedText
                      );
                    }
                )
              )
          ]
        )
      ),
    );
  }

  void _showUserQrCode({required String username, required String userId}){
    widget.onPush(QrCodePage(
        qrCodeTitle: username,
        qrCodeContent: "${BloqoQrCodeType.user.name}_$userId"
    ));
  }

  Future<void> _tryFollow({required BuildContext context, required var localizedText}) async {
    context.loaderOverlay.show();
    try{
      var firestore = getFirestoreFromAppState(context: context);
      await followUser(
          firestore: firestore,
          localizedText: localizedText,
          userToFollowId: widget.user.id,
          myUserId: getUserFromAppState(context: context)!.id
      );
      if(!context.mounted) return;
      context.loaderOverlay.hide();
      addFollowingToUserAppState(context: context, newFollowing: widget.user.id);
      showBloqoSnackBar(
          context: context,
          text: localizedText.done
      );
      setState(() {
        widget.user.followers.add(getUserFromAppState(context: context)!.id);
        currentlyFollowing = true;
      });
    }
    on BloqoException catch(e) {
      if(!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoErrorAlert(
        context: context,
        title: localizedText.error_title,
        description: e.message,
      );
    }
  }

  Future<void> _tryUnfollow({required BuildContext context, required var localizedText}) async {
    context.loaderOverlay.show();
    try{
      var firestore = getFirestoreFromAppState(context: context);
      await unfollowUser(
          firestore: firestore,
          localizedText: localizedText,
          userToUnfollowId: widget.user.id,
          myUserId: getUserFromAppState(context: context)!.id
      );
      if(!context.mounted) return;
      context.loaderOverlay.hide();
      removeFollowingFromUserAppState(context: context, oldFollowing: widget.user.id);
      showBloqoSnackBar(
          context: context,
          text: localizedText.done
      );
      setState(() {
        widget.user.followers.remove(getUserFromAppState(context: context)!.id);
        currentlyFollowing = false;
      });
    }
    on BloqoException catch(e) {
      if(!context.mounted) return;
      context.loaderOverlay.hide();
      showBloqoErrorAlert(
        context: context,
        title: localizedText.error_title,
        description: e.message,
      );
    }
  }

  Widget _getProfilePicture({required BuildContext context, required String? url}){
    if(getFromTestFromAppState(context: context) && url == "assets/tests/test.png"){
      return Image.asset(
        "assets/tests/test.png",
        fit: BoxFit.cover,
      );
    }
    return url != null && url != "none"
        ? FadeInImage.assetNetwork(
      placeholder: "assets/images/portrait_placeholder.png",
      image: url,
      fit: BoxFit.cover,
      placeholderFit: BoxFit.cover,
    )
        : Image.asset(
      "assets/images/portrait_placeholder.png",
      fit: BoxFit.cover,
    );
  }

}