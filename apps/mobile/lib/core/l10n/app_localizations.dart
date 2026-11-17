import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Atarah'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'CREATE · CONNECT · GROW'**
  String get tagline;

  /// No description provided for @soonPhase.
  ///
  /// In en, this message translates to:
  /// **'Soon · P{phase}'**
  String soonPhase(int phase);

  /// No description provided for @soonLater.
  ///
  /// In en, this message translates to:
  /// **'Soon · Later'**
  String get soonLater;

  /// No description provided for @futureTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get futureTitle;

  /// No description provided for @futureBody.
  ///
  /// In en, this message translates to:
  /// **'We\'re building this part of Atarah. It will open up as the app grows.'**
  String get futureBody;

  /// No description provided for @futureBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get futureBack;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Saved content is still available.'**
  String get offlineBanner;

  /// No description provided for @needsConnection.
  ///
  /// In en, this message translates to:
  /// **'Needs a connection'**
  String get needsConnection;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @grpYourGroups.
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get grpYourGroups;

  /// No description provided for @grpYourGroupsEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t joined a group yet. Find one below.'**
  String get grpYourGroupsEmpty;

  /// No description provided for @grpDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover groups'**
  String get grpDiscover;

  /// No description provided for @grpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search groups'**
  String get grpSearchHint;

  /// No description provided for @grpSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get grpSearchClear;

  /// No description provided for @grpFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get grpFilterAll;

  /// No description provided for @grpTypeDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get grpTypeDiscipline;

  /// No description provided for @grpTypeLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get grpTypeLocation;

  /// No description provided for @grpTypeInterest.
  ///
  /// In en, this message translates to:
  /// **'Interest'**
  String get grpTypeInterest;

  /// No description provided for @grpTypeProgramme.
  ///
  /// In en, this message translates to:
  /// **'Programme'**
  String get grpTypeProgramme;

  /// No description provided for @grpMembers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 member} other{{count} members}}'**
  String grpMembers(int count);

  /// No description provided for @grpDiscoverEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groups to show'**
  String get grpDiscoverEmpty;

  /// No description provided for @grpDiscoverEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try another type or search, or check back soon.'**
  String get grpDiscoverEmptyBody;

  /// No description provided for @grpLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Show more groups'**
  String get grpLoadMore;

  /// No description provided for @grpLeaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave {name}?'**
  String grpLeaveTitle(String name);

  /// No description provided for @grpLeaveBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stop seeing its discussions. You can join again any time.'**
  String get grpLeaveBody;

  /// No description provided for @grpLeaveConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave group'**
  String get grpLeaveConfirm;

  /// No description provided for @grpStay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get grpStay;

  /// No description provided for @grpJoinedToast.
  ///
  /// In en, this message translates to:
  /// **'You joined {name}'**
  String grpJoinedToast(String name);

  /// No description provided for @grpLeftToast.
  ///
  /// In en, this message translates to:
  /// **'You left {name}'**
  String grpLeftToast(String name);

  /// No description provided for @grpOwnerCantLeave.
  ///
  /// In en, this message translates to:
  /// **'You own this group, so you can\'t leave it. Ask the Atarah team to hand it over first.'**
  String get grpOwnerCantLeave;

  /// No description provided for @grpErrRestricted.
  ///
  /// In en, this message translates to:
  /// **'Your account is restricted right now, so you can\'t join or post in groups.'**
  String get grpErrRestricted;

  /// No description provided for @grpErrVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify your email or phone number to join groups and post in them.'**
  String get grpErrVerify;

  /// No description provided for @grpErrRate.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing that a lot. Give it a moment and try again.'**
  String get grpErrRate;

  /// No description provided for @grpErrPrivate.
  ///
  /// In en, this message translates to:
  /// **'This group is private. Members are added by invitation.'**
  String get grpErrPrivate;

  /// No description provided for @grpJoinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get grpJoinGroup;

  /// No description provided for @grpShare.
  ///
  /// In en, this message translates to:
  /// **'Share group'**
  String get grpShare;

  /// No description provided for @grpShareText.
  ///
  /// In en, this message translates to:
  /// **'Join {name} on Atarah'**
  String grpShareText(String name);

  /// No description provided for @grpTypePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get grpTypePrivate;

  /// No description provided for @grpOfficial.
  ///
  /// In en, this message translates to:
  /// **'Official'**
  String get grpOfficial;

  /// No description provided for @grpPinned.
  ///
  /// In en, this message translates to:
  /// **'Pinned announcement'**
  String get grpPinned;

  /// No description provided for @grpRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent discussions'**
  String get grpRecent;

  /// No description provided for @grpNoDiscussions.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet'**
  String get grpNoDiscussions;

  /// No description provided for @grpNoDiscussionsBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to start one.'**
  String get grpNoDiscussionsBody;

  /// No description provided for @grpStartDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Start a discussion'**
  String get grpStartDiscussion;

  /// No description provided for @grpJoinToPost.
  ///
  /// In en, this message translates to:
  /// **'Join this group to post'**
  String get grpJoinToPost;

  /// No description provided for @grpPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Private group. Members are added by invitation.'**
  String get grpPrivateNote;

  /// No description provided for @grpGone.
  ///
  /// In en, this message translates to:
  /// **'This group isn\'t available'**
  String get grpGone;

  /// No description provided for @grpGoneBody.
  ///
  /// In en, this message translates to:
  /// **'It may be private, archived or no longer exist.'**
  String get grpGoneBody;

  /// No description provided for @grpPostsFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the discussions'**
  String get grpPostsFailed;

  /// No description provided for @grpMoreDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Show more discussions'**
  String get grpMoreDiscussions;

  /// No description provided for @grpReplies.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 reply} other{{count} replies}}'**
  String grpReplies(int count);

  /// No description provided for @grpMeta.
  ///
  /// In en, this message translates to:
  /// **'{type} · {members}'**
  String grpMeta(String type, String members);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @verifiedByAtarah.
  ///
  /// In en, this message translates to:
  /// **'Verified by Atarah'**
  String get verifiedByAtarah;

  /// No description provided for @selfDeclared.
  ///
  /// In en, this message translates to:
  /// **'Self-declared'**
  String get selfDeclared;

  /// No description provided for @verificationRejected.
  ///
  /// In en, this message translates to:
  /// **'Not verified'**
  String get verificationRejected;

  /// No description provided for @verificationExpired.
  ///
  /// In en, this message translates to:
  /// **'Verification expired'**
  String get verificationExpired;

  /// No description provided for @verificationRevoked.
  ///
  /// In en, this message translates to:
  /// **'Verification revoked'**
  String get verificationRevoked;

  /// No description provided for @underReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get underReview;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @codeDigit.
  ///
  /// In en, this message translates to:
  /// **'Digit {position} of {total}'**
  String codeDigit(int position, int total);

  /// No description provided for @passwordStrengthWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak — use 8+ characters with a number'**
  String get passwordStrengthWeak;

  /// No description provided for @passwordStrengthOk.
  ///
  /// In en, this message translates to:
  /// **'Almost — add a number'**
  String get passwordStrengthOk;

  /// No description provided for @passwordStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong — 8+ characters with a number'**
  String get passwordStrengthStrong;

  /// No description provided for @premiumGateTitle.
  ///
  /// In en, this message translates to:
  /// **'{feature} is part of Pro'**
  String premiumGateTitle(String feature);

  /// No description provided for @premiumWhatItDoes.
  ///
  /// In en, this message translates to:
  /// **'What it does'**
  String get premiumWhatItDoes;

  /// No description provided for @premiumWhyItMatters.
  ///
  /// In en, this message translates to:
  /// **'Why it matters'**
  String get premiumWhyItMatters;

  /// No description provided for @premiumHowToGet.
  ///
  /// In en, this message translates to:
  /// **'How to get it'**
  String get premiumHowToGet;

  /// No description provided for @premiumSeePro.
  ///
  /// In en, this message translates to:
  /// **'See Pro · {price}'**
  String premiumSeePro(String price);

  /// No description provided for @premiumScholarship.
  ///
  /// In en, this message translates to:
  /// **'Check scholarship eligibility'**
  String get premiumScholarship;

  /// No description provided for @errorAtarahTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our side'**
  String get errorAtarahTitle;

  /// No description provided for @errorAtarahBody.
  ///
  /// In en, this message translates to:
  /// **'Your work is safe. Try again in a moment.'**
  String get errorAtarahBody;

  /// No description provided for @errorExternalTitle.
  ///
  /// In en, this message translates to:
  /// **'That site isn\'t responding'**
  String get errorExternalTitle;

  /// No description provided for @errorExternalBody.
  ///
  /// In en, this message translates to:
  /// **'Atarah is working normally. The other site may be down.'**
  String get errorExternalBody;

  /// No description provided for @errorInvalidLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'This link no longer works'**
  String get errorInvalidLinkTitle;

  /// No description provided for @errorInvalidLinkBody.
  ///
  /// In en, this message translates to:
  /// **'It may have moved or expired.'**
  String get errorInvalidLinkBody;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get emptyTitle;

  /// No description provided for @leavingTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re leaving Atarah'**
  String get leavingTitle;

  /// No description provided for @leavingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re going to {domain}. Atarah doesn\'t receive or process this application.'**
  String leavingBody(String domain);

  /// No description provided for @leavingTrack.
  ///
  /// In en, this message translates to:
  /// **'Track this as applied in Activity'**
  String get leavingTrack;

  /// No description provided for @leavingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to website'**
  String get leavingContinue;

  /// No description provided for @leavingStay.
  ///
  /// In en, this message translates to:
  /// **'Stay on Atarah'**
  String get leavingStay;

  /// No description provided for @aiAssisted.
  ///
  /// In en, this message translates to:
  /// **'AI-assisted'**
  String get aiAssisted;

  /// No description provided for @aiTestMode.
  ///
  /// In en, this message translates to:
  /// **'AI preview (test mode)'**
  String get aiTestMode;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Check facts and names before applying — you\'re responsible for what you publish.'**
  String get aiDisclaimer;

  /// No description provided for @aiDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get aiDiscard;

  /// No description provided for @aiApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get aiApply;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get tabExplore;

  /// No description provided for @tabCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get tabCommunity;

  /// No description provided for @tabOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get tabOpportunities;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @uploadDrop.
  ///
  /// In en, this message translates to:
  /// **'Tap to add files'**
  String get uploadDrop;

  /// No description provided for @uploadRetry.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Tap to retry.'**
  String get uploadRetry;

  /// No description provided for @uploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading {percent}%'**
  String uploading(int percent);

  /// No description provided for @featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get featured;

  /// No description provided for @sourceConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Source confirmed'**
  String get sourceConfirmed;

  /// No description provided for @externalSource.
  ///
  /// In en, this message translates to:
  /// **'External source'**
  String get externalSource;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @saveItem.
  ///
  /// In en, this message translates to:
  /// **'Save {title}'**
  String saveItem(String title);

  /// No description provided for @unsaveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved: {title}'**
  String unsaveItem(String title);

  /// No description provided for @likeAction.
  ///
  /// In en, this message translates to:
  /// **'Like, {count} likes'**
  String likeAction(int count);

  /// No description provided for @unlikeAction.
  ///
  /// In en, this message translates to:
  /// **'Unlike, {count} likes'**
  String unlikeAction(int count);

  /// No description provided for @repliesAction.
  ///
  /// In en, this message translates to:
  /// **'Replies, {count}'**
  String repliesAction(int count);

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @savePost.
  ///
  /// In en, this message translates to:
  /// **'Save post'**
  String get savePost;

  /// No description provided for @unsavePost.
  ///
  /// In en, this message translates to:
  /// **'Unsave post'**
  String get unsavePost;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @cfdTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get cfdTitle;

  /// No description provided for @cfdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask, share and build with Kenya\'s creatives.'**
  String get cfdSubtitle;

  /// No description provided for @cfdNewPost.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get cfdNewPost;

  /// No description provided for @cfdTabFeed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get cfdTabFeed;

  /// No description provided for @cfdTabDiscussions.
  ///
  /// In en, this message translates to:
  /// **'Discussions'**
  String get cfdTabDiscussions;

  /// No description provided for @cfdTabGroups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get cfdTabGroups;

  /// No description provided for @cfdTabPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get cfdTabPeople;

  /// No description provided for @cfdComposerPrompt.
  ///
  /// In en, this message translates to:
  /// **'Share an update or ask a question…'**
  String get cfdComposerPrompt;

  /// No description provided for @cfdFeedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get cfdFeedEmpty;

  /// No description provided for @cfdFeedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share an update or ask a question.'**
  String get cfdFeedEmptyBody;

  /// No description provided for @cfdDiscussionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No discussions yet'**
  String get cfdDiscussionsEmpty;

  /// No description provided for @cfdDiscussionsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Start one and ask the community what they think.'**
  String get cfdDiscussionsEmptyBody;

  /// No description provided for @cfdWritePost.
  ///
  /// In en, this message translates to:
  /// **'Write a post'**
  String get cfdWritePost;

  /// No description provided for @cfdFeedFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the feed'**
  String get cfdFeedFailed;

  /// No description provided for @cfdOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get cfdOfflineTitle;

  /// No description provided for @cfdOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Reconnect to see the latest posts.'**
  String get cfdOfflineBody;

  /// No description provided for @cfdLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load more posts.'**
  String get cfdLoadMoreFailed;

  /// No description provided for @cfdTypeUpdate.
  ///
  /// In en, this message translates to:
  /// **'Creative update'**
  String get cfdTypeUpdate;

  /// No description provided for @cfdTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get cfdTypeQuestion;

  /// No description provided for @cfdTypeDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get cfdTypeDiscussion;

  /// No description provided for @cfdTypeCollaboration.
  ///
  /// In en, this message translates to:
  /// **'Collaboration'**
  String get cfdTypeCollaboration;

  /// No description provided for @cfdTypeAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get cfdTypeAnnouncement;

  /// No description provided for @cfdChipUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get cfdChipUpdate;

  /// No description provided for @cfdAuthorTeam.
  ///
  /// In en, this message translates to:
  /// **'Atarah Team'**
  String get cfdAuthorTeam;

  /// No description provided for @cfdNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get cfdNow;

  /// No description provided for @cfdMinutes.
  ///
  /// In en, this message translates to:
  /// **'{n}m'**
  String cfdMinutes(int n);

  /// No description provided for @cfdHours.
  ///
  /// In en, this message translates to:
  /// **'{n}h'**
  String cfdHours(int n);

  /// No description provided for @cfdDays.
  ///
  /// In en, this message translates to:
  /// **'{n}d'**
  String cfdDays(int n);

  /// No description provided for @cfdEdited.
  ///
  /// In en, this message translates to:
  /// **'edited'**
  String get cfdEdited;

  /// No description provided for @cfdShareText.
  ///
  /// In en, this message translates to:
  /// **'{name} on Atarah: {excerpt}\n{url}'**
  String cfdShareText(String name, String excerpt, String url);

  /// No description provided for @cfdOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open link: {title}'**
  String cfdOpenLink(String title);

  /// No description provided for @cfdVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get cfdVideo;

  /// No description provided for @cfdPhotoOf.
  ///
  /// In en, this message translates to:
  /// **'Photo by {name}'**
  String cfdPhotoOf(String name);

  /// No description provided for @cfdSavedPost.
  ///
  /// In en, this message translates to:
  /// **'Saved to your saved items.'**
  String get cfdSavedPost;

  /// No description provided for @cfdUnsavedPost.
  ///
  /// In en, this message translates to:
  /// **'Removed from your saved items.'**
  String get cfdUnsavedPost;

  /// No description provided for @cfdReplyCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No replies yet} =1{1 reply} other{{count} replies}}'**
  String cfdReplyCount(int count);

  /// No description provided for @cfdReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get cfdReplyHint;

  /// No description provided for @cfdReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String cfdReplyingTo(String name);

  /// No description provided for @cfdCancelReply.
  ///
  /// In en, this message translates to:
  /// **'Cancel reply'**
  String get cfdCancelReply;

  /// No description provided for @cfdSendReply.
  ///
  /// In en, this message translates to:
  /// **'Send reply'**
  String get cfdSendReply;

  /// No description provided for @cfdReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get cfdReply;

  /// No description provided for @cfdNoReplies.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get cfdNoReplies;

  /// No description provided for @cfdNoRepliesBody.
  ///
  /// In en, this message translates to:
  /// **'Be the first to reply.'**
  String get cfdNoRepliesBody;

  /// No description provided for @cfdMoreReplies.
  ///
  /// In en, this message translates to:
  /// **'Show more replies'**
  String get cfdMoreReplies;

  /// No description provided for @cfdMenuSave.
  ///
  /// In en, this message translates to:
  /// **'Save discussion'**
  String get cfdMenuSave;

  /// No description provided for @cfdMenuUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get cfdMenuUnsave;

  /// No description provided for @cfdMenuMute.
  ///
  /// In en, this message translates to:
  /// **'Mute thread'**
  String get cfdMenuMute;

  /// No description provided for @cfdMenuUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute thread'**
  String get cfdMenuUnmute;

  /// No description provided for @cfdMenuBlock.
  ///
  /// In en, this message translates to:
  /// **'Block author'**
  String get cfdMenuBlock;

  /// No description provided for @cfdMenuReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get cfdMenuReport;

  /// No description provided for @cfdMenuEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get cfdMenuEdit;

  /// No description provided for @cfdMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cfdMenuDelete;

  /// No description provided for @cfdMuted.
  ///
  /// In en, this message translates to:
  /// **'Thread muted. You won\'t be notified about it.'**
  String get cfdMuted;

  /// No description provided for @cfdUnmuted.
  ///
  /// In en, this message translates to:
  /// **'Thread unmuted.'**
  String get cfdUnmuted;

  /// No description provided for @cfdEditPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit post'**
  String get cfdEditPostTitle;

  /// No description provided for @cfdEditReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit reply'**
  String get cfdEditReplyTitle;

  /// No description provided for @cfdSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get cfdSaveChanges;

  /// No description provided for @cfdCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cfdCancel;

  /// No description provided for @cfdDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get cfdDone;

  /// No description provided for @cfdDeletePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this post?'**
  String get cfdDeletePostTitle;

  /// No description provided for @cfdDeletePostBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed for everyone, including the replies. This can\'t be undone.'**
  String get cfdDeletePostBody;

  /// No description provided for @cfdDeleteReplyTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this reply?'**
  String get cfdDeleteReplyTitle;

  /// No description provided for @cfdDeleteReplyBody.
  ///
  /// In en, this message translates to:
  /// **'It will be removed for everyone. This can\'t be undone.'**
  String get cfdDeleteReplyBody;

  /// No description provided for @cfdDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cfdDelete;

  /// No description provided for @cfdPostGone.
  ///
  /// In en, this message translates to:
  /// **'This post isn\'t available'**
  String get cfdPostGone;

  /// No description provided for @cfdPostGoneBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed, or you can no longer see it.'**
  String get cfdPostGoneBody;

  /// No description provided for @cfdReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get cfdReportTitle;

  /// No description provided for @cfdReportIntro.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this? The person won\'t be told it was you.'**
  String get cfdReportIntro;

  /// No description provided for @cfdReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or offensive'**
  String get cfdReasonInappropriate;

  /// No description provided for @cfdReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get cfdReasonHarassment;

  /// No description provided for @cfdReasonScam.
  ///
  /// In en, this message translates to:
  /// **'Scam or spam'**
  String get cfdReasonScam;

  /// No description provided for @cfdReasonMisleading.
  ///
  /// In en, this message translates to:
  /// **'Misleading or false'**
  String get cfdReasonMisleading;

  /// No description provided for @cfdReasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Pretending to be someone else'**
  String get cfdReasonImpersonation;

  /// No description provided for @cfdReasonIp.
  ///
  /// In en, this message translates to:
  /// **'Copied or stolen work'**
  String get cfdReasonIp;

  /// No description provided for @cfdReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Something else'**
  String get cfdReasonOther;

  /// No description provided for @cfdReportNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get cfdReportNoteLabel;

  /// No description provided for @cfdReportNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us what we should look at'**
  String get cfdReportNoteHint;

  /// No description provided for @cfdReportSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get cfdReportSubmit;

  /// No description provided for @cfdReportDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks for telling us'**
  String get cfdReportDoneTitle;

  /// No description provided for @cfdReportDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Our team will review this report. When a decision is made you\'ll get a notification with the outcome. We don\'t share details about other members, and the person won\'t know it was you.'**
  String get cfdReportDoneBody;

  /// No description provided for @cfdBlockTitle.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String cfdBlockTitle(String name);

  /// No description provided for @cfdBlockBody.
  ///
  /// In en, this message translates to:
  /// **'You won\'t see each other\'s posts, replies or profiles, and neither of you can connect with or reply to the other. They won\'t be told.'**
  String get cfdBlockBody;

  /// No description provided for @cfdBlockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get cfdBlockConfirm;

  /// No description provided for @cfdBlockedTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} is blocked'**
  String cfdBlockedTitle(String name);

  /// No description provided for @cfdBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Their posts and replies are now hidden from you.'**
  String get cfdBlockedBody;

  /// No description provided for @cfdUndoBlock.
  ///
  /// In en, this message translates to:
  /// **'Undo block'**
  String get cfdUndoBlock;

  /// No description provided for @cfdUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} is unblocked.'**
  String cfdUnblocked(String name);

  /// No description provided for @cfdComposeTitle.
  ///
  /// In en, this message translates to:
  /// **'New post'**
  String get cfdComposeTitle;

  /// No description provided for @cfdPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get cfdPost;

  /// No description provided for @cfdBodyHint.
  ///
  /// In en, this message translates to:
  /// **'What would you like to share?'**
  String get cfdBodyHint;

  /// No description provided for @cfdCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max}'**
  String cfdCharCount(int count, int max);

  /// No description provided for @cfdDraftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved automatically'**
  String get cfdDraftSaved;

  /// No description provided for @cfdAttachPhoto.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get cfdAttachPhoto;

  /// No description provided for @cfdAttachVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get cfdAttachVideo;

  /// No description provided for @cfdAttachLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get cfdAttachLink;

  /// No description provided for @cfdAttachOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Opportunity'**
  String get cfdAttachOpportunity;

  /// No description provided for @cfdAudience.
  ///
  /// In en, this message translates to:
  /// **'Audience'**
  String get cfdAudience;

  /// No description provided for @cfdAudMembers.
  ///
  /// In en, this message translates to:
  /// **'Atarah members'**
  String get cfdAudMembers;

  /// No description provided for @cfdAudMembersBody.
  ///
  /// In en, this message translates to:
  /// **'Everyone signed in to Atarah'**
  String get cfdAudMembersBody;

  /// No description provided for @cfdAudPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get cfdAudPublic;

  /// No description provided for @cfdAudPublicBody.
  ///
  /// In en, this message translates to:
  /// **'Anyone, including people outside Atarah'**
  String get cfdAudPublicBody;

  /// No description provided for @cfdAudConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get cfdAudConnections;

  /// No description provided for @cfdAudConnectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Only people you\'re connected with'**
  String get cfdAudConnectionsBody;

  /// No description provided for @cfdAudGroups.
  ///
  /// In en, this message translates to:
  /// **'Your groups'**
  String get cfdAudGroups;

  /// No description provided for @cfdAudGroupBody.
  ///
  /// In en, this message translates to:
  /// **'Members of this group'**
  String get cfdAudGroupBody;

  /// No description provided for @cfdAudGroupsFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your groups.'**
  String get cfdAudGroupsFailed;

  /// No description provided for @cfdLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get cfdLinkTitle;

  /// No description provided for @cfdLinkHint.
  ///
  /// In en, this message translates to:
  /// **'https://'**
  String get cfdLinkHint;

  /// No description provided for @cfdLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a full web address that starts with http:// or https://'**
  String get cfdLinkInvalid;

  /// No description provided for @cfdLinkNote.
  ///
  /// In en, this message translates to:
  /// **'A preview appears on the post a moment after you share it.'**
  String get cfdLinkNote;

  /// No description provided for @cfdLinkAdd.
  ///
  /// In en, this message translates to:
  /// **'Add link'**
  String get cfdLinkAdd;

  /// No description provided for @cfdLinkRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get cfdLinkRemove;

  /// No description provided for @cfdMediaFull.
  ///
  /// In en, this message translates to:
  /// **'A post can have up to 10 photos or videos.'**
  String get cfdMediaFull;

  /// No description provided for @cfdPickFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open your files. Try again.'**
  String get cfdPickFailed;

  /// No description provided for @cfdNeedsContent.
  ///
  /// In en, this message translates to:
  /// **'Write something, or add a photo, video or link.'**
  String get cfdNeedsContent;

  /// No description provided for @cfdTooLong.
  ///
  /// In en, this message translates to:
  /// **'Posts can be up to {max} characters.'**
  String cfdTooLong(int max);

  /// No description provided for @cfdUploadsPending.
  ///
  /// In en, this message translates to:
  /// **'Wait for your files to finish uploading, or remove them.'**
  String get cfdUploadsPending;

  /// No description provided for @cfdPostedToast.
  ///
  /// In en, this message translates to:
  /// **'Posted.'**
  String get cfdPostedToast;

  /// No description provided for @cfdErrVerification.
  ///
  /// In en, this message translates to:
  /// **'Verify your email or phone number first, then try again.'**
  String get cfdErrVerification;

  /// No description provided for @cfdErrRestricted.
  ///
  /// In en, this message translates to:
  /// **'Your account is restricted right now, so you can\'t do this. If you think that\'s a mistake, contact support.'**
  String get cfdErrRestricted;

  /// No description provided for @cfdErrNotMember.
  ///
  /// In en, this message translates to:
  /// **'Join this group first, then try again.'**
  String get cfdErrNotMember;

  /// No description provided for @cfdErrNotFound.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t available any more.'**
  String get cfdErrNotFound;

  /// No description provided for @cfdErrRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You\'re going a little fast. Please wait a while and try again.'**
  String get cfdErrRateLimited;

  /// No description provided for @improveSkill.
  ///
  /// In en, this message translates to:
  /// **'Improve this skill'**
  String get improveSkill;

  /// No description provided for @findOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Find opportunities'**
  String get findOpportunities;

  /// No description provided for @verifyAction.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyAction;

  /// No description provided for @joinAction.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinAction;

  /// No description provided for @joinedAction.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedAction;

  /// No description provided for @creativePassport.
  ///
  /// In en, this message translates to:
  /// **'CREATIVE PASSPORT'**
  String get creativePassport;

  /// No description provided for @unreadPrefix.
  ///
  /// In en, this message translates to:
  /// **'Unread.'**
  String get unreadPrefix;

  /// No description provided for @welcomeHeadline.
  ///
  /// In en, this message translates to:
  /// **'One creative identity. Many connected possibilities.'**
  String get welcomeHeadline;

  /// No description provided for @welcomeCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get welcomeCreateAccount;

  /// No description provided for @welcomeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get welcomeSignIn;

  /// No description provided for @emailOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Email or phone number'**
  String get emailOrPhone;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out'**
  String get signingOut;

  /// No description provided for @splashCheckingTitle.
  ///
  /// In en, this message translates to:
  /// **'Checking your session'**
  String get splashCheckingTitle;

  /// No description provided for @splashOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach Atarah'**
  String get splashOfflineTitle;

  /// No description provided for @splashOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t check your session. Your saved content is still on this device.'**
  String get splashOfflineBody;

  /// No description provided for @profileMembershipFree.
  ///
  /// In en, this message translates to:
  /// **'Free plan'**
  String get profileMembershipFree;

  /// No description provided for @profileMembershipPro.
  ///
  /// In en, this message translates to:
  /// **'Atarah Pro'**
  String get profileMembershipPro;

  /// No description provided for @profileCreativePassport.
  ///
  /// In en, this message translates to:
  /// **'Creative Passport'**
  String get profileCreativePassport;

  /// No description provided for @profileActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get profileActivity;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profileSettings;

  /// No description provided for @profileMembership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get profileMembership;

  /// No description provided for @featureHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get featureHome;

  /// No description provided for @featureExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get featureExplore;

  /// No description provided for @featureCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get featureCommunity;

  /// No description provided for @featureOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get featureOpportunities;

  /// No description provided for @featureNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get featureNotifications;

  /// No description provided for @featureCreativeProfile.
  ///
  /// In en, this message translates to:
  /// **'Creative profile'**
  String get featureCreativeProfile;

  /// No description provided for @featureProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get featureProject;

  /// No description provided for @featureCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get featureCourse;

  /// No description provided for @featureLesson.
  ///
  /// In en, this message translates to:
  /// **'Lesson'**
  String get featureLesson;

  /// No description provided for @featureListing.
  ///
  /// In en, this message translates to:
  /// **'Marketplace listing'**
  String get featureListing;

  /// No description provided for @featureMentor.
  ///
  /// In en, this message translates to:
  /// **'Mentor'**
  String get featureMentor;

  /// No description provided for @featureArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get featureArticle;

  /// No description provided for @featureGroup.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get featureGroup;

  /// No description provided for @featurePost.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get featurePost;

  /// No description provided for @welcomeSubhead.
  ///
  /// In en, this message translates to:
  /// **'Learn, connect, discover opportunities and grow your career — from one profile that works everywhere in Atarah.'**
  String get welcomeSubhead;

  /// No description provided for @pillarIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get pillarIdentity;

  /// No description provided for @pillarLearn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get pillarLearn;

  /// No description provided for @pillarConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get pillarConnect;

  /// No description provided for @pillarEarn.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get pillarEarn;

  /// No description provided for @welcomeTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get welcomeTerms;

  /// No description provided for @welcomePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get welcomePrivacy;

  /// No description provided for @legalDraftBanner.
  ///
  /// In en, this message translates to:
  /// **'This is a draft that has not been reviewed yet. It is not the final text.'**
  String get legalDraftBanner;

  /// No description provided for @legalUnavailable.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this document.'**
  String get legalUnavailable;

  /// No description provided for @legalTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get legalTermsTitle;

  /// No description provided for @legalPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get legalPrivacyTitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Takes under a minute. You\'ll set up your creative profile next.'**
  String get signupSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name.'**
  String get fullNameError;

  /// No description provided for @identifierError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address or phone number.'**
  String get identifierError;

  /// No description provided for @identifierHintPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone numbers starting with 0 or 7 are treated as Kenyan (+254).'**
  String get identifierHintPhone;

  /// No description provided for @passwordRuleError.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, including a letter and a number.'**
  String get passwordRuleError;

  /// No description provided for @consentPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get consentPrefix;

  /// No description provided for @consentAnd.
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get consentAnd;

  /// No description provided for @consentTermsLink.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get consentTermsLink;

  /// No description provided for @consentPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get consentPrivacyLink;

  /// No description provided for @consentRequired.
  ///
  /// In en, this message translates to:
  /// **'You need to accept the Terms and Privacy Policy to continue.'**
  String get consentRequired;

  /// No description provided for @signupAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get signupAction;

  /// No description provided for @googleContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get googleContinue;

  /// No description provided for @alreadyMember.
  ///
  /// In en, this message translates to:
  /// **'Already a member?'**
  String get alreadyMember;

  /// No description provided for @newToAtarah.
  ///
  /// In en, this message translates to:
  /// **'New to Atarah?'**
  String get newToAtarah;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @signInInstead.
  ///
  /// In en, this message translates to:
  /// **'Sign in instead'**
  String get signInInstead;

  /// No description provided for @verifyTitleEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyTitleEmail;

  /// No description provided for @verifyTitlePhone.
  ///
  /// In en, this message translates to:
  /// **'Verify your phone number'**
  String get verifyTitlePhone;

  /// No description provided for @verifyBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code we sent to'**
  String get verifyBody;

  /// No description provided for @verifyDidntGet.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get it?'**
  String get verifyDidntGet;

  /// No description provided for @verifyResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String verifyResendIn(String time);

  /// No description provided for @verifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get verifyResend;

  /// No description provided for @verifyResent.
  ///
  /// In en, this message translates to:
  /// **'New code sent.'**
  String get verifyResent;

  /// No description provided for @verifyWhyLead.
  ///
  /// In en, this message translates to:
  /// **'Why we verify:'**
  String get verifyWhyLead;

  /// No description provided for @verifyWhyBody.
  ///
  /// In en, this message translates to:
  /// **' it protects your creative identity and is needed before you message, apply or book.'**
  String get verifyWhyBody;

  /// No description provided for @verifyNextLead.
  ///
  /// In en, this message translates to:
  /// **'What\'s next:'**
  String get verifyNextLead;

  /// No description provided for @verifyNextBody.
  ///
  /// In en, this message translates to:
  /// **' four short steps to set up your creative profile.'**
  String get verifyNextBody;

  /// No description provided for @verifyCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification code'**
  String get verifyCodeLabel;

  /// No description provided for @signInTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your creative journey.'**
  String get signInSubtitle;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPasswordLink;

  /// No description provided for @signInLockedHint.
  ///
  /// In en, this message translates to:
  /// **'You can also reset your password to sign in right away.'**
  String get signInLockedHint;

  /// No description provided for @forgotTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotTitle;

  /// No description provided for @forgotBody.
  ///
  /// In en, this message translates to:
  /// **'Enter the email or phone on your account and we\'ll send a recovery code.'**
  String get forgotBody;

  /// No description provided for @forgotSent.
  ///
  /// In en, this message translates to:
  /// **'Code sent. It expires in 10 minutes.'**
  String get forgotSent;

  /// No description provided for @forgotAction.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get forgotAction;

  /// No description provided for @resetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetTitle;

  /// No description provided for @resetBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be signed out of other devices.'**
  String get resetBody;

  /// No description provided for @recoveryCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery code'**
  String get recoveryCodeLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmPasswordLabel;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In en, this message translates to:
  /// **'The passwords don\'t match.'**
  String get passwordsDontMatch;

  /// No description provided for @resetAction.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetAction;

  /// No description provided for @resetDone.
  ///
  /// In en, this message translates to:
  /// **'Password updated. You were signed out of your other devices.'**
  String get resetDone;

  /// No description provided for @codeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Enter all 6 digits.'**
  String get codeIncomplete;

  /// No description provided for @obSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get obSkip;

  /// No description provided for @obStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String obStepOf(int n, int total);

  /// No description provided for @obGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'Getting started'**
  String get obGettingStarted;

  /// No description provided for @obProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Setup progress'**
  String get obProgressLabel;

  /// No description provided for @obGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get obGetStarted;

  /// No description provided for @obContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get obContinue;

  /// No description provided for @obFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get obFinish;

  /// No description provided for @obIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your creative identity'**
  String get obIntroTitle;

  /// No description provided for @obIntroBody.
  ///
  /// In en, this message translates to:
  /// **'Four short steps. Each one makes the opportunities, people and learning you see more relevant.'**
  String get obIntroBody;

  /// No description provided for @obIntroDisciplineTitle.
  ///
  /// In en, this message translates to:
  /// **'Your discipline'**
  String get obIntroDisciplineTitle;

  /// No description provided for @obIntroDisciplineBody.
  ///
  /// In en, this message translates to:
  /// **'What you create and your specialization'**
  String get obIntroDisciplineBody;

  /// No description provided for @obIntroSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills & interests'**
  String get obIntroSkillsTitle;

  /// No description provided for @obIntroSkillsBody.
  ///
  /// In en, this message translates to:
  /// **'What you’re good at and want to grow'**
  String get obIntroSkillsBody;

  /// No description provided for @obIntroLocationTitle.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get obIntroLocationTitle;

  /// No description provided for @obIntroLocationBody.
  ///
  /// In en, this message translates to:
  /// **'For local people, events and opportunities'**
  String get obIntroLocationBody;

  /// No description provided for @obIntroBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile basics'**
  String get obIntroBasicsTitle;

  /// No description provided for @obIntroBasicsBody.
  ///
  /// In en, this message translates to:
  /// **'Your name, a short bio and a photo'**
  String get obIntroBasicsBody;

  /// No description provided for @obDisciplineTitle.
  ///
  /// In en, this message translates to:
  /// **'What do you create?'**
  String get obDisciplineTitle;

  /// No description provided for @obDisciplineBody.
  ///
  /// In en, this message translates to:
  /// **'Your discipline helps us show you more relevant opportunities, people and learning.'**
  String get obDisciplineBody;

  /// No description provided for @obDisciplineRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose what you create, or skip this step.'**
  String get obDisciplineRequired;

  /// No description provided for @obSpecTitle.
  ///
  /// In en, this message translates to:
  /// **'Your specialization'**
  String get obSpecTitle;

  /// No description provided for @obSpecBodyPrefix.
  ///
  /// In en, this message translates to:
  /// **'Within '**
  String get obSpecBodyPrefix;

  /// No description provided for @obSpecBodySuffix.
  ///
  /// In en, this message translates to:
  /// **' — pick any that describe your practice.'**
  String get obSpecBodySuffix;

  /// No description provided for @obSpecNeedDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Choose your discipline first, then come back to pick your specialization.'**
  String get obSpecNeedDiscipline;

  /// No description provided for @obSuggest.
  ///
  /// In en, this message translates to:
  /// **'Suggest a specialization'**
  String get obSuggest;

  /// No description provided for @obSuggestTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a specialization'**
  String get obSuggestTitle;

  /// No description provided for @obSuggestBody.
  ///
  /// In en, this message translates to:
  /// **'Tell us what is missing from the {discipline} list. We review every suggestion.'**
  String obSuggestBody(String discipline);

  /// No description provided for @obSuggestLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialization name'**
  String get obSuggestLabel;

  /// No description provided for @obSuggestSend.
  ///
  /// In en, this message translates to:
  /// **'Send suggestion'**
  String get obSuggestSend;

  /// No description provided for @obSuggestEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the specialization.'**
  String get obSuggestEmpty;

  /// No description provided for @obSuggestThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks, we\'ll take a look'**
  String get obSuggestThanksTitle;

  /// No description provided for @obSuggestThanksBody.
  ///
  /// In en, this message translates to:
  /// **'We\'ll tell you when “{name}” is added or merged. You can carry on meanwhile.'**
  String obSuggestThanksBody(String name);

  /// No description provided for @obSuggestDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get obSuggestDone;

  /// No description provided for @obSkillsTitle.
  ///
  /// In en, this message translates to:
  /// **'Skills & interests'**
  String get obSkillsTitle;

  /// No description provided for @obSkillsBody.
  ///
  /// In en, this message translates to:
  /// **'These power your learning recommendations, discovery and opportunity matches.'**
  String get obSkillsBody;

  /// No description provided for @obGroupSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get obGroupSkills;

  /// No description provided for @obGroupInterests.
  ///
  /// In en, this message translates to:
  /// **'Interests'**
  String get obGroupInterests;

  /// No description provided for @obGroupGrow.
  ///
  /// In en, this message translates to:
  /// **'Areas to develop'**
  String get obGroupGrow;

  /// No description provided for @obSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String obSelectedCount(int count);

  /// No description provided for @obLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You can pick up to {max}.'**
  String obLimitReached(int max);

  /// No description provided for @obLocTitle.
  ///
  /// In en, this message translates to:
  /// **'Where are you based?'**
  String get obLocTitle;

  /// No description provided for @obLocBody.
  ///
  /// In en, this message translates to:
  /// **'For local discovery, regional opportunities and your county\'s creative community.'**
  String get obLocBody;

  /// No description provided for @obCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get obCountry;

  /// No description provided for @obCounty.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get obCounty;

  /// No description provided for @obTown.
  ///
  /// In en, this message translates to:
  /// **'Town or neighbourhood (optional)'**
  String get obTown;

  /// No description provided for @obSelectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get obSelectPlaceholder;

  /// No description provided for @obUseLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get obUseLocation;

  /// No description provided for @obLocating.
  ///
  /// In en, this message translates to:
  /// **'Finding your county…'**
  String get obLocating;

  /// No description provided for @obLocationFound.
  ///
  /// In en, this message translates to:
  /// **'We set your county to {county}.'**
  String obLocationFound(String county);

  /// No description provided for @obLocationNoMatch.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t match your location to a county. Choose it from the list.'**
  String get obLocationNoMatch;

  /// No description provided for @obLocationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is off. Choose your county from the list.'**
  String get obLocationDenied;

  /// No description provided for @obLocationDeniedForever.
  ///
  /// In en, this message translates to:
  /// **'Location is blocked for Atarah in your phone settings. Choose your county from the list.'**
  String get obLocationDeniedForever;

  /// No description provided for @obLocationServicesOff.
  ///
  /// In en, this message translates to:
  /// **'Location is switched off on this phone. Choose your county from the list.'**
  String get obLocationServicesOff;

  /// No description provided for @obLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get your location. Choose your county from the list.'**
  String get obLocationFailed;

  /// No description provided for @obCountyRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your county, or skip this step.'**
  String get obCountyRequired;

  /// No description provided for @obChooseCounty.
  ///
  /// In en, this message translates to:
  /// **'Choose a county'**
  String get obChooseCounty;

  /// No description provided for @obChooseCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get obChooseCountry;

  /// No description provided for @obSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get obSearch;

  /// No description provided for @obNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that.'**
  String get obNoResults;

  /// No description provided for @obWhoSees.
  ///
  /// In en, this message translates to:
  /// **'Who can see your location?'**
  String get obWhoSees;

  /// No description provided for @obVisPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get obVisPublic;

  /// No description provided for @obVisMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get obVisMembers;

  /// No description provided for @obVisPrivate.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get obVisPrivate;

  /// No description provided for @obVisPublicNote.
  ///
  /// In en, this message translates to:
  /// **'Anyone, including people outside Atarah, can see your county.'**
  String get obVisPublicNote;

  /// No description provided for @obVisMembersNote.
  ///
  /// In en, this message translates to:
  /// **'Only signed-in Atarah members can see your county.'**
  String get obVisMembersNote;

  /// No description provided for @obVisPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Hidden from everyone. Still used to personalise what you see.'**
  String get obVisPrivateNote;

  /// No description provided for @obBasicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Introduce yourself'**
  String get obBasicsTitle;

  /// No description provided for @obBasicsBody.
  ///
  /// In en, this message translates to:
  /// **'A name and a line or two — you can expand this into your Creative Passport later.'**
  String get obBasicsBody;

  /// No description provided for @obDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get obDisplayName;

  /// No description provided for @obDisplayNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter the name you want people to see.'**
  String get obDisplayNameError;

  /// No description provided for @obProfileLink.
  ///
  /// In en, this message translates to:
  /// **'Profile link'**
  String get obProfileLink;

  /// No description provided for @obHandleChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get obHandleChecking;

  /// No description provided for @obHandleAvailable.
  ///
  /// In en, this message translates to:
  /// **'{handle} is available.'**
  String obHandleAvailable(String handle);

  /// No description provided for @obHandleTaken.
  ///
  /// In en, this message translates to:
  /// **'That profile link is taken.'**
  String get obHandleTaken;

  /// No description provided for @obHandleReserved.
  ///
  /// In en, this message translates to:
  /// **'That link is reserved. Try another.'**
  String get obHandleReserved;

  /// No description provided for @obHandleInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use 3 to 30 letters, numbers or underscores.'**
  String get obHandleInvalid;

  /// No description provided for @obHandleTry.
  ///
  /// In en, this message translates to:
  /// **'Try one of these'**
  String get obHandleTry;

  /// No description provided for @obHandleRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose your profile link.'**
  String get obHandleRequired;

  /// No description provided for @obShortBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get obShortBio;

  /// No description provided for @obHelpWrite.
  ///
  /// In en, this message translates to:
  /// **'Help me write this'**
  String get obHelpWrite;

  /// No description provided for @obBioCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / 160'**
  String obBioCount(int count);

  /// No description provided for @obPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a profile photo'**
  String get obPhotoTitle;

  /// No description provided for @obPhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Profiles with a clear photo get more connection requests and mentor replies.'**
  String get obPhotoBody;

  /// No description provided for @obGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get obGallery;

  /// No description provided for @obTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get obTakePhoto;

  /// No description provided for @obPhotoSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get obPhotoSkip;

  /// No description provided for @obPhotoUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading your photo…'**
  String get obPhotoUploading;

  /// No description provided for @obPhotoAdded.
  ///
  /// In en, this message translates to:
  /// **'Photo added.'**
  String get obPhotoAdded;

  /// No description provided for @obPhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get obPhotoRemove;

  /// No description provided for @obPhotoPreview.
  ///
  /// In en, this message translates to:
  /// **'Profile photo preview'**
  String get obPhotoPreview;

  /// No description provided for @obPhotoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open that photo. Try another.'**
  String get obPhotoPickFailed;

  /// No description provided for @obCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop your photo'**
  String get obCropTitle;

  /// No description provided for @obCropUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get obCropUse;

  /// No description provided for @obCropCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get obCropCancel;

  /// No description provided for @obDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Your creative journey starts here.'**
  String get obDoneTitle;

  /// No description provided for @obDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your Creative Passport is live. Complete it at your own pace — Atarah gets more useful as it grows.'**
  String get obDoneBody;

  /// No description provided for @obPassportLabel.
  ///
  /// In en, this message translates to:
  /// **'CREATIVE PASSPORT'**
  String get obPassportLabel;

  /// No description provided for @obSpecNotSet.
  ///
  /// In en, this message translates to:
  /// **'Specialization not set'**
  String get obSpecNotSet;

  /// No description provided for @obLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get obLocationNotSet;

  /// No description provided for @obCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get obCompletion;

  /// No description provided for @obGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get obGoHome;

  /// No description provided for @obLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your setup'**
  String get obLoadFailedTitle;

  /// No description provided for @obHandleSuggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Available alternatives'**
  String get obHandleSuggestionsLabel;

  /// No description provided for @pfPublicView.
  ///
  /// In en, this message translates to:
  /// **'Public view'**
  String get pfPublicView;

  /// No description provided for @pfEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get pfEditProfile;

  /// No description provided for @pfImproveBio.
  ///
  /// In en, this message translates to:
  /// **'Improve my bio'**
  String get pfImproveBio;

  /// No description provided for @pfAddHeadline.
  ///
  /// In en, this message translates to:
  /// **'Add a headline'**
  String get pfAddHeadline;

  /// No description provided for @pfLocationNotSet.
  ///
  /// In en, this message translates to:
  /// **'Location not set'**
  String get pfLocationNotSet;

  /// No description provided for @pfLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your profile'**
  String get pfLoadFailed;

  /// No description provided for @pfPassportCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Passport'**
  String get pfPassportCardTitle;

  /// No description provided for @pfNextBestAction.
  ///
  /// In en, this message translates to:
  /// **'Next best step'**
  String get pfNextBestAction;

  /// No description provided for @pfCompletionPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String pfCompletionPercent(int percent);

  /// No description provided for @pfAllDone.
  ///
  /// In en, this message translates to:
  /// **'Your profile is complete. Nice work.'**
  String get pfAllDone;

  /// No description provided for @pfYourTools.
  ///
  /// In en, this message translates to:
  /// **'Your tools'**
  String get pfYourTools;

  /// No description provided for @pfMentorTools.
  ///
  /// In en, this message translates to:
  /// **'Mentor tools'**
  String get pfMentorTools;

  /// No description provided for @pfSellerTools.
  ///
  /// In en, this message translates to:
  /// **'Seller tools'**
  String get pfSellerTools;

  /// No description provided for @pfMyIdentity.
  ///
  /// In en, this message translates to:
  /// **'My creative identity'**
  String get pfMyIdentity;

  /// No description provided for @pfPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get pfPortfolio;

  /// No description provided for @pfSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get pfSkills;

  /// No description provided for @pfExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get pfExperience;

  /// No description provided for @pfAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get pfAchievements;

  /// No description provided for @pfServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get pfServices;

  /// No description provided for @pfConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get pfConnections;

  /// No description provided for @pfSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get pfSaved;

  /// No description provided for @pfCount.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String pfCount(int count);

  /// No description provided for @pfPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String pfPendingRequests(int count);

  /// No description provided for @epTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get epTitle;

  /// No description provided for @epDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get epDisplayName;

  /// No description provided for @epHeadline.
  ///
  /// In en, this message translates to:
  /// **'Headline'**
  String get epHeadline;

  /// No description provided for @epHeadlineHint.
  ///
  /// In en, this message translates to:
  /// **'For example: Character animator in Nairobi'**
  String get epHeadlineHint;

  /// No description provided for @epBio.
  ///
  /// In en, this message translates to:
  /// **'Short bio'**
  String get epBio;

  /// No description provided for @epLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get epLinks;

  /// No description provided for @epLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get epLinkLabel;

  /// No description provided for @epLinkUrl.
  ///
  /// In en, this message translates to:
  /// **'Address (https://)'**
  String get epLinkUrl;

  /// No description provided for @epAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get epAddLink;

  /// No description provided for @epRemoveLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get epRemoveLink;

  /// No description provided for @epLinksLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {max} links.'**
  String epLinksLimit(int max);

  /// No description provided for @epLinkInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a web address that starts with https://'**
  String get epLinkInvalid;

  /// No description provided for @epLinkLabelMissing.
  ///
  /// In en, this message translates to:
  /// **'Give the link a label.'**
  String get epLinkLabelMissing;

  /// No description provided for @epContactPrefs.
  ///
  /// In en, this message translates to:
  /// **'Contact and availability'**
  String get epContactPrefs;

  /// No description provided for @epOpenToCommissions.
  ///
  /// In en, this message translates to:
  /// **'Open to commissions'**
  String get epOpenToCommissions;

  /// No description provided for @epShowEmail.
  ///
  /// In en, this message translates to:
  /// **'Show my email when my contact details are visible'**
  String get epShowEmail;

  /// No description provided for @epShowPhone.
  ///
  /// In en, this message translates to:
  /// **'Show my phone number when my contact details are visible'**
  String get epShowPhone;

  /// No description provided for @epContactForConnections.
  ///
  /// In en, this message translates to:
  /// **'My connections can see my contact details'**
  String get epContactForConnections;

  /// No description provided for @epAcceptConnections.
  ///
  /// In en, this message translates to:
  /// **'Accept connection requests'**
  String get epAcceptConnections;

  /// No description provided for @epSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get epSave;

  /// No description provided for @epSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated.'**
  String get epSaved;

  /// No description provided for @epNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter the name you want people to see.'**
  String get epNameError;

  /// No description provided for @ppTitle.
  ///
  /// In en, this message translates to:
  /// **'Creative Passport'**
  String get ppTitle;

  /// No description provided for @ppMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String ppMemberSince(String date);

  /// No description provided for @ppGrowth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get ppGrowth;

  /// No description provided for @ppStrengthEarly.
  ///
  /// In en, this message translates to:
  /// **'Early'**
  String get ppStrengthEarly;

  /// No description provided for @ppStrengthGrowing.
  ///
  /// In en, this message translates to:
  /// **'Growing'**
  String get ppStrengthGrowing;

  /// No description provided for @ppStrengthActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get ppStrengthActive;

  /// No description provided for @ppStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get ppStrengthStrong;

  /// No description provided for @ppGrowthIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get ppGrowthIdentity;

  /// No description provided for @ppGrowthPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get ppGrowthPortfolio;

  /// No description provided for @ppGrowthSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get ppGrowthSkills;

  /// No description provided for @ppGrowthLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get ppGrowthLearning;

  /// No description provided for @ppGrowthConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get ppGrowthConnections;

  /// No description provided for @ppGrowthProfessionalisation.
  ///
  /// In en, this message translates to:
  /// **'Professionalisation'**
  String get ppGrowthProfessionalisation;

  /// No description provided for @ppSections.
  ///
  /// In en, this message translates to:
  /// **'Sections & visibility'**
  String get ppSections;

  /// No description provided for @ppSectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Choose who can see each part of your profile. Changes apply straight away.'**
  String get ppSectionsBody;

  /// No description provided for @ppCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get ppCopyLink;

  /// No description provided for @ppLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied.'**
  String get ppLinkCopied;

  /// No description provided for @ppCreateCv.
  ///
  /// In en, this message translates to:
  /// **'Create CV / EPK'**
  String get ppCreateCv;

  /// No description provided for @ppVisibilityFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t change that. Try again.'**
  String get ppVisibilityFailed;

  /// No description provided for @ppChooseAudience.
  ///
  /// In en, this message translates to:
  /// **'Who can see {section}?'**
  String ppChooseAudience(String section);

  /// No description provided for @vsPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get vsPublic;

  /// No description provided for @vsMembers.
  ///
  /// In en, this message translates to:
  /// **'Members only'**
  String get vsMembers;

  /// No description provided for @vsPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get vsPrivate;

  /// No description provided for @vsPublicNote.
  ///
  /// In en, this message translates to:
  /// **'Anyone, including people outside Atarah.'**
  String get vsPublicNote;

  /// No description provided for @vsMembersNote.
  ///
  /// In en, this message translates to:
  /// **'Signed-in Atarah members.'**
  String get vsMembersNote;

  /// No description provided for @vsPrivateNote.
  ///
  /// In en, this message translates to:
  /// **'Only you (and connections, for contact details, if you allow it).'**
  String get vsPrivateNote;

  /// No description provided for @secBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get secBio;

  /// No description provided for @secLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get secLocation;

  /// No description provided for @secPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get secPortfolio;

  /// No description provided for @secSkills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get secSkills;

  /// No description provided for @secExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get secExperience;

  /// No description provided for @secServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get secServices;

  /// No description provided for @secLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get secLinks;

  /// No description provided for @secContact.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get secContact;

  /// No description provided for @cpAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get cpAbout;

  /// No description provided for @cpPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get cpPortfolio;

  /// No description provided for @cpServices.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get cpServices;

  /// No description provided for @cpShare.
  ///
  /// In en, this message translates to:
  /// **'Share profile'**
  String get cpShare;

  /// No description provided for @cpShareText.
  ///
  /// In en, this message translates to:
  /// **'{name} on Atarah'**
  String cpShareText(String name);

  /// No description provided for @cpOpenToCommissions.
  ///
  /// In en, this message translates to:
  /// **'Open to commissions'**
  String get cpOpenToCommissions;

  /// No description provided for @cpConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get cpConnect;

  /// No description provided for @cpMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get cpMessage;

  /// No description provided for @cpRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get cpRequestSent;

  /// No description provided for @cpCancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cpCancelRequest;

  /// No description provided for @cpAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get cpAccept;

  /// No description provided for @cpDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get cpDecline;

  /// No description provided for @cpConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get cpConnected;

  /// No description provided for @cpRemoveConnection.
  ///
  /// In en, this message translates to:
  /// **'Remove connection'**
  String get cpRemoveConnection;

  /// No description provided for @cpRemoveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this connection?'**
  String get cpRemoveConfirmTitle;

  /// No description provided for @cpRemoveConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stop being connected. You can send a new request later.'**
  String get cpRemoveConfirmBody;

  /// No description provided for @cpNotAccepting.
  ///
  /// In en, this message translates to:
  /// **'Not accepting requests'**
  String get cpNotAccepting;

  /// No description provided for @cpAskLater.
  ///
  /// In en, this message translates to:
  /// **'You can ask again later'**
  String get cpAskLater;

  /// No description provided for @cpConnectionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} connections'**
  String cpConnectionsCount(int count);

  /// No description provided for @cpPreviewBanner.
  ///
  /// In en, this message translates to:
  /// **'This is how your profile looks to others.'**
  String get cpPreviewBanner;

  /// No description provided for @cpPreviewPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get cpPreviewPublic;

  /// No description provided for @cpPreviewMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get cpPreviewMembers;

  /// No description provided for @cpBioLocked.
  ///
  /// In en, this message translates to:
  /// **'The bio is not shared with you.'**
  String get cpBioLocked;

  /// No description provided for @cpHidden.
  ///
  /// In en, this message translates to:
  /// **'{section} is hidden.'**
  String cpHidden(String section);

  /// No description provided for @cpSkillsHeading.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get cpSkillsHeading;

  /// No description provided for @cpSpecialisationsHeading.
  ///
  /// In en, this message translates to:
  /// **'Specialisations'**
  String get cpSpecialisationsHeading;

  /// No description provided for @cpLinksHeading.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get cpLinksHeading;

  /// No description provided for @cpContactHeading.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get cpContactHeading;

  /// No description provided for @cpNoBio.
  ///
  /// In en, this message translates to:
  /// **'No bio yet.'**
  String get cpNoBio;

  /// No description provided for @cpNoPortfolio.
  ///
  /// In en, this message translates to:
  /// **'No projects yet.'**
  String get cpNoPortfolio;

  /// No description provided for @cpNoServices.
  ///
  /// In en, this message translates to:
  /// **'No services yet.'**
  String get cpNoServices;

  /// No description provided for @cpNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that creative'**
  String get cpNotFoundTitle;

  /// No description provided for @cpActionFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Try again.'**
  String get cpActionFailed;

  /// No description provided for @cpMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String cpMemberSince(String date);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @skAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a skill'**
  String get skAddTitle;

  /// No description provided for @skEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No skills yet'**
  String get skEmptyTitle;

  /// No description provided for @skEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'List what you do well so people can find you and see what you can offer.'**
  String get skEmptyBody;

  /// No description provided for @skLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get skLevelLabel;

  /// No description provided for @skLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get skLevelBeginner;

  /// No description provided for @skLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get skLevelIntermediate;

  /// No description provided for @skLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get skLevelAdvanced;

  /// No description provided for @skLevelExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get skLevelExpert;

  /// No description provided for @skLevelUnrated.
  ///
  /// In en, this message translates to:
  /// **'Not rated'**
  String get skLevelUnrated;

  /// No description provided for @skSourceSelf.
  ///
  /// In en, this message translates to:
  /// **'Self-declared'**
  String get skSourceSelf;

  /// No description provided for @skSourceLearning.
  ///
  /// In en, this message translates to:
  /// **'From learning'**
  String get skSourceLearning;

  /// No description provided for @skSourceVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get skSourceVerified;

  /// No description provided for @skUsedIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Not used in a project yet} =1{Used in 1 project} other{Used in {count} projects}}'**
  String skUsedIn(int count);

  /// No description provided for @skImprove.
  ///
  /// In en, this message translates to:
  /// **'Improve this skill'**
  String get skImprove;

  /// No description provided for @skFindOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Find opportunities'**
  String get skFindOpportunities;

  /// No description provided for @skVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get skVerify;

  /// No description provided for @skChangeLevel.
  ///
  /// In en, this message translates to:
  /// **'Change level'**
  String get skChangeLevel;

  /// No description provided for @skSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search skills'**
  String get skSearchLabel;

  /// No description provided for @skNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No skills match. Try a different word.'**
  String get skNoMatches;

  /// No description provided for @skRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove skill'**
  String get skRemove;

  /// No description provided for @skRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String skRemoveTitle(String name);

  /// No description provided for @skRemoveBody.
  ///
  /// In en, this message translates to:
  /// **'It leaves your profile. Projects that used it keep their own list.'**
  String get skRemoveBody;

  /// No description provided for @xpAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add experience'**
  String get xpAddTitle;

  /// No description provided for @xpEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit experience'**
  String get xpEditTitle;

  /// No description provided for @xpEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No experience yet'**
  String get xpEmptyTitle;

  /// No description provided for @xpEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Add the studios, clients and roles that shaped your work.'**
  String get xpEmptyBody;

  /// No description provided for @xpPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get xpPresent;

  /// No description provided for @xpTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get xpTitleLabel;

  /// No description provided for @xpOrgLabel.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get xpOrgLabel;

  /// No description provided for @xpOrgHint.
  ///
  /// In en, this message translates to:
  /// **'Company, studio, school or Freelance'**
  String get xpOrgHint;

  /// No description provided for @xpLocationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location (optional)'**
  String get xpLocationLabel;

  /// No description provided for @xpStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get xpStartLabel;

  /// No description provided for @xpEndLabel.
  ///
  /// In en, this message translates to:
  /// **'Ended'**
  String get xpEndLabel;

  /// No description provided for @xpCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'I work here now'**
  String get xpCurrentLabel;

  /// No description provided for @xpDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What you did (optional)'**
  String get xpDescriptionLabel;

  /// No description provided for @xpTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter your role.'**
  String get xpTitleError;

  /// No description provided for @xpOrgError.
  ///
  /// In en, this message translates to:
  /// **'Enter where you worked.'**
  String get xpOrgError;

  /// No description provided for @xpStartError.
  ///
  /// In en, this message translates to:
  /// **'Choose when you started.'**
  String get xpStartError;

  /// No description provided for @xpEndRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose when you left, or switch on “I work here now”.'**
  String get xpEndRequired;

  /// No description provided for @xpEndBeforeStart.
  ///
  /// In en, this message translates to:
  /// **'The end date cannot be before the start date.'**
  String get xpEndBeforeStart;

  /// No description provided for @xpDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete experience'**
  String get xpDelete;

  /// No description provided for @xpDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this experience?'**
  String get xpDeleteTitle;

  /// No description provided for @xpDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed from your profile.'**
  String get xpDeleteBody;

  /// No description provided for @acAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add achievement'**
  String get acAddTitle;

  /// No description provided for @acEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit achievement'**
  String get acEditTitle;

  /// No description provided for @acEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get acEmptyTitle;

  /// No description provided for @acEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Awards, certificates, features and selections build trust in your work.'**
  String get acEmptyBody;

  /// No description provided for @acTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get acTypeLabel;

  /// No description provided for @acTypeAward.
  ///
  /// In en, this message translates to:
  /// **'Award'**
  String get acTypeAward;

  /// No description provided for @acTypeCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate'**
  String get acTypeCertificate;

  /// No description provided for @acTypeFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get acTypeFeature;

  /// No description provided for @acTypeSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get acTypeSelection;

  /// No description provided for @acTypeNomination.
  ///
  /// In en, this message translates to:
  /// **'Nomination'**
  String get acTypeNomination;

  /// No description provided for @acTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get acTitleLabel;

  /// No description provided for @acIssuerLabel.
  ///
  /// In en, this message translates to:
  /// **'Given by (optional)'**
  String get acIssuerLabel;

  /// No description provided for @acDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date (optional)'**
  String get acDateLabel;

  /// No description provided for @acUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Link (optional)'**
  String get acUrlLabel;

  /// No description provided for @acDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Details (optional)'**
  String get acDescriptionLabel;

  /// No description provided for @acTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter a title.'**
  String get acTitleError;

  /// No description provided for @acUrlError.
  ///
  /// In en, this message translates to:
  /// **'Links must start with https://'**
  String get acUrlError;

  /// No description provided for @acByAtarah.
  ///
  /// In en, this message translates to:
  /// **'Added by Atarah'**
  String get acByAtarah;

  /// No description provided for @acDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete achievement'**
  String get acDelete;

  /// No description provided for @acDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this achievement?'**
  String get acDeleteTitle;

  /// No description provided for @acDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed from your profile.'**
  String get acDeleteBody;

  /// No description provided for @svAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a service'**
  String get svAddTitle;

  /// No description provided for @svEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit service'**
  String get svEditTitle;

  /// No description provided for @svEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No services yet'**
  String get svEmptyTitle;

  /// No description provided for @svEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tell people what you can do for them and roughly what it costs.'**
  String get svEmptyBody;

  /// No description provided for @svTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get svTitleLabel;

  /// No description provided for @svDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What is included (optional)'**
  String get svDescriptionLabel;

  /// No description provided for @svPriceTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get svPriceTypeLabel;

  /// No description provided for @svTypeFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed'**
  String get svTypeFixed;

  /// No description provided for @svTypeRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get svTypeRange;

  /// No description provided for @svTypeOnRequest.
  ///
  /// In en, this message translates to:
  /// **'On request'**
  String get svTypeOnRequest;

  /// No description provided for @svPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get svPriceLabel;

  /// No description provided for @svMinLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get svMinLabel;

  /// No description provided for @svMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get svMaxLabel;

  /// No description provided for @svTitleError.
  ///
  /// In en, this message translates to:
  /// **'Enter the name of the service.'**
  String get svTitleError;

  /// No description provided for @svPriceError.
  ///
  /// In en, this message translates to:
  /// **'Enter a price in Kenya shillings.'**
  String get svPriceError;

  /// No description provided for @svMaxError.
  ///
  /// In en, this message translates to:
  /// **'The highest price must be at least the lowest.'**
  String get svMaxError;

  /// No description provided for @svPriceFixed.
  ///
  /// In en, this message translates to:
  /// **'KES {amount}'**
  String svPriceFixed(String amount);

  /// No description provided for @svPriceRange.
  ///
  /// In en, this message translates to:
  /// **'KES {min} to {max}'**
  String svPriceRange(String min, String max);

  /// No description provided for @svPriceOnRequest.
  ///
  /// In en, this message translates to:
  /// **'Price on request'**
  String get svPriceOnRequest;

  /// No description provided for @svProfileOnly.
  ///
  /// In en, this message translates to:
  /// **'Profile only'**
  String get svProfileOnly;

  /// No description provided for @svOnMarketplace.
  ///
  /// In en, this message translates to:
  /// **'On the marketplace'**
  String get svOnMarketplace;

  /// No description provided for @svPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish to marketplace'**
  String get svPublish;

  /// No description provided for @svViewListing.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get svViewListing;

  /// No description provided for @svEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get svEdit;

  /// No description provided for @svDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete service'**
  String get svDelete;

  /// No description provided for @svDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this service?'**
  String get svDeleteTitle;

  /// No description provided for @svDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed from your profile.'**
  String get svDeleteBody;

  /// No description provided for @pjAdd.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get pjAdd;

  /// No description provided for @pjAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a project'**
  String get pjAddTitle;

  /// No description provided for @pjEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get pjEditTitle;

  /// No description provided for @pjAddZone.
  ///
  /// In en, this message translates to:
  /// **'Add project'**
  String get pjAddZone;

  /// No description provided for @pjAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get pjAll;

  /// No description provided for @pjFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get pjFeatured;

  /// No description provided for @pjCatProjects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get pjCatProjects;

  /// No description provided for @pjCatMediaPlural.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get pjCatMediaPlural;

  /// No description provided for @pjCatPublications.
  ///
  /// In en, this message translates to:
  /// **'Publications'**
  String get pjCatPublications;

  /// No description provided for @pjCatPerformances.
  ///
  /// In en, this message translates to:
  /// **'Performances'**
  String get pjCatPerformances;

  /// No description provided for @pjCatProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get pjCatProject;

  /// No description provided for @pjCatMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get pjCatMedia;

  /// No description provided for @pjCatPublication.
  ///
  /// In en, this message translates to:
  /// **'Publication'**
  String get pjCatPublication;

  /// No description provided for @pjCatPerformance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get pjCatPerformance;

  /// No description provided for @pjEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Show your best work. Add a project to start your portfolio.'**
  String get pjEmptyBody;

  /// No description provided for @pjNothingInFilter.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get pjNothingInFilter;

  /// No description provided for @pjDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get pjDrafts;

  /// No description provided for @pjDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get pjDraft;

  /// No description provided for @pjHidden.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get pjHidden;

  /// No description provided for @pjUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled project'**
  String get pjUntitled;

  /// No description provided for @pjInviteTitle.
  ///
  /// In en, this message translates to:
  /// **'{owner} tagged you on “{project}”'**
  String pjInviteTitle(String owner, String project);

  /// No description provided for @pjInviteRole.
  ///
  /// In en, this message translates to:
  /// **'As {role}'**
  String pjInviteRole(String role);

  /// No description provided for @pjInviteAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get pjInviteAccept;

  /// No description provided for @pjInviteDecline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get pjInviteDecline;

  /// No description provided for @pjIntro.
  ///
  /// In en, this message translates to:
  /// **'Tell the story of your work. Your changes are saved as a draft while you type, and nobody sees it until you publish.'**
  String get pjIntro;

  /// No description provided for @pjSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get pjSaved;

  /// No description provided for @pjSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get pjSaving;

  /// No description provided for @pjSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save yet. Check your connection; we will try again as you type.'**
  String get pjSaveFailed;

  /// No description provided for @pjSaveFirst.
  ///
  /// In en, this message translates to:
  /// **'Save the project first, then add collaborators.'**
  String get pjSaveFirst;

  /// No description provided for @pjFilesHeading.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get pjFilesHeading;

  /// No description provided for @pjAddFiles.
  ///
  /// In en, this message translates to:
  /// **'Add files'**
  String get pjAddFiles;

  /// No description provided for @pjFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Photos, video or audio. Up to {max} files.'**
  String pjFilesHint(int max);

  /// No description provided for @pjFileAlt.
  ///
  /// In en, this message translates to:
  /// **'Project file'**
  String get pjFileAlt;

  /// No description provided for @pjPickPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get pjPickPhotos;

  /// No description provided for @pjPickVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get pjPickVideo;

  /// No description provided for @pjPickAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get pjPickAudio;

  /// No description provided for @pjPickFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not open your files. Try again.'**
  String get pjPickFailed;

  /// No description provided for @pjTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get pjTitleLabel;

  /// No description provided for @pjRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get pjRoleLabel;

  /// No description provided for @pjClientLabel.
  ///
  /// In en, this message translates to:
  /// **'Client (optional)'**
  String get pjClientLabel;

  /// No description provided for @pjDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of the work'**
  String get pjDateLabel;

  /// No description provided for @pjDateNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get pjDateNotSet;

  /// No description provided for @pjDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get pjDateClear;

  /// No description provided for @pjCategoryHeading.
  ///
  /// In en, this message translates to:
  /// **'Type of work'**
  String get pjCategoryHeading;

  /// No description provided for @pjDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get pjDescriptionLabel;

  /// No description provided for @pjHelpDescribe.
  ///
  /// In en, this message translates to:
  /// **'Help me describe this'**
  String get pjHelpDescribe;

  /// No description provided for @pjOutcomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Outcome (optional)'**
  String get pjOutcomeLabel;

  /// No description provided for @pjOutcomeHint.
  ///
  /// In en, this message translates to:
  /// **'What did the work achieve?'**
  String get pjOutcomeHint;

  /// No description provided for @pjSkillsHeading.
  ///
  /// In en, this message translates to:
  /// **'Skills used'**
  String get pjSkillsHeading;

  /// No description provided for @pjAddSkill.
  ///
  /// In en, this message translates to:
  /// **'Add a skill'**
  String get pjAddSkill;

  /// No description provided for @pjRemoveNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}'**
  String pjRemoveNamed(String name);

  /// No description provided for @pjCollaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get pjCollaborators;

  /// No description provided for @pjAddCollaborator.
  ///
  /// In en, this message translates to:
  /// **'Add a collaborator'**
  String get pjAddCollaborator;

  /// No description provided for @pjCollabMember.
  ///
  /// In en, this message translates to:
  /// **'Atarah member'**
  String get pjCollabMember;

  /// No description provided for @pjCollabName.
  ///
  /// In en, this message translates to:
  /// **'Someone else'**
  String get pjCollabName;

  /// No description provided for @pjCollabRole.
  ///
  /// In en, this message translates to:
  /// **'Their role (optional)'**
  String get pjCollabRole;

  /// No description provided for @pjCollabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name or @handle'**
  String get pjCollabSearch;

  /// No description provided for @pjCollabNoMembers.
  ///
  /// In en, this message translates to:
  /// **'No members found.'**
  String get pjCollabNoMembers;

  /// No description provided for @pjCollabNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Their name'**
  String get pjCollabNameLabel;

  /// No description provided for @pjCollabAddName.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get pjCollabAddName;

  /// No description provided for @pjCollabNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter their name.'**
  String get pjCollabNameError;

  /// No description provided for @pjCollabPending.
  ///
  /// In en, this message translates to:
  /// **'Waiting to accept'**
  String get pjCollabPending;

  /// No description provided for @pjLinks.
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get pjLinks;

  /// No description provided for @pjAddLink.
  ///
  /// In en, this message translates to:
  /// **'Add a link'**
  String get pjAddLink;

  /// No description provided for @pjLinkLabel.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get pjLinkLabel;

  /// No description provided for @pjLinkUrl.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get pjLinkUrl;

  /// No description provided for @pjLinkError.
  ///
  /// In en, this message translates to:
  /// **'Enter an address starting with https://'**
  String get pjLinkError;

  /// No description provided for @pjRemoveLink.
  ///
  /// In en, this message translates to:
  /// **'Remove link'**
  String get pjRemoveLink;

  /// No description provided for @pjVisibilityHeading.
  ///
  /// In en, this message translates to:
  /// **'Who can see it'**
  String get pjVisibilityHeading;

  /// No description provided for @pjVisibilityNote.
  ///
  /// In en, this message translates to:
  /// **'Your Portfolio setting in the Creative Passport also applies.'**
  String get pjVisibilityNote;

  /// No description provided for @pjFeaturedToggle.
  ///
  /// In en, this message translates to:
  /// **'Feature this project (up to 3)'**
  String get pjFeaturedToggle;

  /// No description provided for @pjPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get pjPublish;

  /// No description provided for @pjSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get pjSaveChanges;

  /// No description provided for @pjSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get pjSaveDraft;

  /// No description provided for @pjPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview project'**
  String get pjPreview;

  /// No description provided for @pjDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete project'**
  String get pjDelete;

  /// No description provided for @pjDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this project?'**
  String get pjDeleteTitle;

  /// No description provided for @pjDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It is removed from your portfolio and profile.'**
  String get pjDeleteBody;

  /// No description provided for @pjTitleError.
  ///
  /// In en, this message translates to:
  /// **'Give your project a title.'**
  String get pjTitleError;

  /// No description provided for @pjShare.
  ///
  /// In en, this message translates to:
  /// **'Share project'**
  String get pjShare;

  /// No description provided for @pjEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit project'**
  String get pjEdit;

  /// No description provided for @pjShareText.
  ///
  /// In en, this message translates to:
  /// **'{title} on Atarah'**
  String pjShareText(String title);

  /// No description provided for @pjNotFound.
  ///
  /// In en, this message translates to:
  /// **'This project is not available'**
  String get pjNotFound;

  /// No description provided for @pjHiddenNotice.
  ///
  /// In en, this message translates to:
  /// **'A moderator hid this project: {reason}'**
  String pjHiddenNotice(String reason);

  /// No description provided for @pjDraftNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a draft. Only you can see it.'**
  String get pjDraftNotice;

  /// No description provided for @pjSkillsUsed.
  ///
  /// In en, this message translates to:
  /// **'Skills used'**
  String get pjSkillsUsed;

  /// No description provided for @pjOutcome.
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get pjOutcome;

  /// No description provided for @pjMediaProcessing.
  ///
  /// In en, this message translates to:
  /// **'This file is still being prepared.'**
  String get pjMediaProcessing;

  /// No description provided for @pjMediaFailed.
  ///
  /// In en, this message translates to:
  /// **'We could not play this file.'**
  String get pjMediaFailed;

  /// No description provided for @pjImageAlt.
  ///
  /// In en, this message translates to:
  /// **'Project image'**
  String get pjImageAlt;

  /// No description provided for @pjPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get pjPlay;

  /// No description provided for @pjPause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pjPause;

  /// No description provided for @leavingOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open that link.'**
  String get leavingOpenFailed;

  /// No description provided for @dcWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dcWelcome(String name);

  /// No description provided for @dcWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Your creative journey matters. Let\'s build what\'s next.'**
  String get dcWelcomeBody;

  /// No description provided for @dcNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get dcNotifications;

  /// No description provided for @dcNotificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Notifications, 1 unread} other{Notifications, {count} unread}}'**
  String dcNotificationsUnread(int count);

  /// No description provided for @dcYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get dcYourProfile;

  /// No description provided for @dcCompletion.
  ///
  /// In en, this message translates to:
  /// **'Profile completion'**
  String get dcCompletion;

  /// No description provided for @dcCompletionBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile to unlock more opportunities and get better recommendations.'**
  String get dcCompletionBody;

  /// No description provided for @dcCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile completion, {percent} percent'**
  String dcCompletionLabel(int percent);

  /// No description provided for @dcViewProfile.
  ///
  /// In en, this message translates to:
  /// **'View profile'**
  String get dcViewProfile;

  /// No description provided for @dcQuickAccess.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get dcQuickAccess;

  /// No description provided for @dcSkillLabs.
  ///
  /// In en, this message translates to:
  /// **'Skill Labs'**
  String get dcSkillLabs;

  /// No description provided for @dcSkillLabsBody.
  ///
  /// In en, this message translates to:
  /// **'Short courses for working creatives'**
  String get dcSkillLabsBody;

  /// No description provided for @dcPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get dcPortfolio;

  /// No description provided for @dcPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get dcPassport;

  /// No description provided for @dcRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get dcRecommended;

  /// No description provided for @dcCreativesToMeet.
  ///
  /// In en, this message translates to:
  /// **'Creatives to meet'**
  String get dcCreativesToMeet;

  /// No description provided for @dcMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get dcMarketplace;

  /// No description provided for @dcMarketplaceBody.
  ///
  /// In en, this message translates to:
  /// **'Hire creatives or sell your services'**
  String get dcMarketplaceBody;

  /// No description provided for @dcMentorship.
  ///
  /// In en, this message translates to:
  /// **'Mentorship'**
  String get dcMentorship;

  /// No description provided for @dcMentorshipBody.
  ///
  /// In en, this message translates to:
  /// **'Book time with industry mentors'**
  String get dcMentorshipBody;

  /// No description provided for @dcGrowCareer.
  ///
  /// In en, this message translates to:
  /// **'Grow your creative career'**
  String get dcGrowCareer;

  /// No description provided for @dcOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get dcOpen;

  /// No description provided for @dcLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this'**
  String get dcLoadFailed;

  /// No description provided for @dcExploreTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore creatives'**
  String get dcExploreTitle;

  /// No description provided for @dcExploreBody.
  ///
  /// In en, this message translates to:
  /// **'Discover amazing talent, connect and be inspired.'**
  String get dcExploreBody;

  /// No description provided for @dcSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search creatives, articles'**
  String get dcSearchHint;

  /// No description provided for @dcFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get dcFilters;

  /// No description provided for @dcAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dcAll;

  /// No description provided for @dcRemoveFilter.
  ///
  /// In en, this message translates to:
  /// **'Remove filter {name}'**
  String dcRemoveFilter(String name);

  /// No description provided for @dcOpenToCommissions.
  ///
  /// In en, this message translates to:
  /// **'Open to commissions'**
  String get dcOpenToCommissions;

  /// No description provided for @dcVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified by Atarah'**
  String get dcVerified;

  /// No description provided for @dcVerifiedOnly.
  ///
  /// In en, this message translates to:
  /// **'Verified only'**
  String get dcVerifiedOnly;

  /// No description provided for @dcVerifiedOnlyBody.
  ///
  /// In en, this message translates to:
  /// **'Identity or skills verified by Atarah'**
  String get dcVerifiedOnlyBody;

  /// No description provided for @dcCreativesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 creative} other{{count} creatives}}'**
  String dcCreativesCount(int count);

  /// No description provided for @dcNoCreativesNearby.
  ///
  /// In en, this message translates to:
  /// **'No creatives in this discipline yet nearby.'**
  String get dcNoCreativesNearby;

  /// No description provided for @dcShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get dcShowAll;

  /// No description provided for @dcNoCreativesYet.
  ///
  /// In en, this message translates to:
  /// **'No creatives to show yet'**
  String get dcNoCreativesYet;

  /// No description provided for @dcNoCreativesYetBody.
  ///
  /// In en, this message translates to:
  /// **'People appear here when they finish setting up their profile.'**
  String get dcNoCreativesYetBody;

  /// No description provided for @dcMoreToExplore.
  ///
  /// In en, this message translates to:
  /// **'More to explore'**
  String get dcMoreToExplore;

  /// No description provided for @dcOpportunitiesBody.
  ///
  /// In en, this message translates to:
  /// **'Grants, calls and jobs'**
  String get dcOpportunitiesBody;

  /// No description provided for @dcArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get dcArticles;

  /// No description provided for @dcArticlesBody.
  ///
  /// In en, this message translates to:
  /// **'Stories and advice for creatives'**
  String get dcArticlesBody;

  /// No description provided for @dcCreativeEconomy.
  ///
  /// In en, this message translates to:
  /// **'Creative economy'**
  String get dcCreativeEconomy;

  /// No description provided for @dcCreativeEconomyBody.
  ///
  /// In en, this message translates to:
  /// **'See where creative work is happening across Kenya'**
  String get dcCreativeEconomyBody;

  /// No description provided for @dcDiscoveredTitle.
  ///
  /// In en, this message translates to:
  /// **'Want to be discovered?'**
  String get dcDiscoveredTitle;

  /// No description provided for @dcDiscoveredBody.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile and showcase your work to the Atarah community.'**
  String get dcDiscoveredBody;

  /// No description provided for @dcReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get dcReset;

  /// No description provided for @dcDiscipline.
  ///
  /// In en, this message translates to:
  /// **'Discipline'**
  String get dcDiscipline;

  /// No description provided for @dcLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get dcLocation;

  /// No description provided for @dcCounty.
  ///
  /// In en, this message translates to:
  /// **'County'**
  String get dcCounty;

  /// No description provided for @dcAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Anywhere'**
  String get dcAnywhere;

  /// No description provided for @dcChooseCounty.
  ///
  /// In en, this message translates to:
  /// **'Choose county'**
  String get dcChooseCounty;

  /// No description provided for @dcAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get dcAvailability;

  /// No description provided for @dcSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get dcSortBy;

  /// No description provided for @dcSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Best match'**
  String get dcSortRelevance;

  /// No description provided for @dcSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get dcSortRecent;

  /// No description provided for @dcShowResults.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 result} other{Show {count} results}}'**
  String dcShowResults(int count);

  /// No description provided for @dcShowResultsLoading.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get dcShowResultsLoading;

  /// No description provided for @dcClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get dcClearSearch;

  /// No description provided for @dcRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get dcRecent;

  /// No description provided for @dcClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get dcClearAll;

  /// No description provided for @dcRemoveRecent.
  ///
  /// In en, this message translates to:
  /// **'Remove recent search {query}'**
  String dcRemoveRecent(String query);

  /// No description provided for @dcSearchEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Search Atarah'**
  String get dcSearchEmptyTitle;

  /// No description provided for @dcSearchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Find creatives by name, field or skill, and articles by topic.'**
  String get dcSearchEmptyBody;

  /// No description provided for @dcSearchTooShort.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters.'**
  String get dcSearchTooShort;

  /// No description provided for @dcNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String dcNoResults(String query);

  /// No description provided for @dcNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Check the spelling or try a different word.'**
  String get dcNoResultsBody;

  /// No description provided for @dcCreatives.
  ///
  /// In en, this message translates to:
  /// **'Creatives'**
  String get dcCreatives;

  /// No description provided for @dcAllCount.
  ///
  /// In en, this message translates to:
  /// **'All ({count})'**
  String dcAllCount(int count);

  /// No description provided for @dcCreativesTab.
  ///
  /// In en, this message translates to:
  /// **'Creatives ({count})'**
  String dcCreativesTab(int count);

  /// No description provided for @dcArticlesTab.
  ///
  /// In en, this message translates to:
  /// **'Articles ({count})'**
  String dcArticlesTab(int count);

  /// No description provided for @dcSeeAllCount.
  ///
  /// In en, this message translates to:
  /// **'See all {count}'**
  String dcSeeAllCount(int count);

  /// No description provided for @dcSourceAtarah.
  ///
  /// In en, this message translates to:
  /// **'Atarah Editorial'**
  String get dcSourceAtarah;

  /// No description provided for @dcSourcePartner.
  ///
  /// In en, this message translates to:
  /// **'Partner'**
  String get dcSourcePartner;

  /// No description provided for @dcSourceExternal.
  ///
  /// In en, this message translates to:
  /// **'External source'**
  String get dcSourceExternal;

  /// No description provided for @dcReadMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} min read'**
  String dcReadMinutes(int count);

  /// No description provided for @dcShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get dcShare;

  /// No description provided for @dcSave.
  ///
  /// In en, this message translates to:
  /// **'Save article'**
  String get dcSave;

  /// No description provided for @dcUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get dcUnsave;

  /// No description provided for @dcSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save that. Try again.'**
  String get dcSaveFailed;

  /// No description provided for @dcRuleOfThumb.
  ///
  /// In en, this message translates to:
  /// **'Rule of thumb'**
  String get dcRuleOfThumb;

  /// No description provided for @dcArticleGone.
  ///
  /// In en, this message translates to:
  /// **'This article is not available'**
  String get dcArticleGone;

  /// No description provided for @dcArticleGoneBody.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed or not published yet.'**
  String get dcArticleGoneBody;

  /// No description provided for @dcNoArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles yet'**
  String get dcNoArticles;

  /// No description provided for @dcNoArticlesBody.
  ///
  /// In en, this message translates to:
  /// **'New stories and advice will appear here.'**
  String get dcNoArticlesBody;

  /// No description provided for @proPillLabel.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get proPillLabel;

  /// No description provided for @appearanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceLabel;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @settingsGroupAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsGroupAccount;

  /// No description provided for @settingsGroupSupport.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settingsGroupSupport;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & visibility'**
  String get settingsPrivacy;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People to meet'**
  String get peopleTitle;

  /// No description provided for @peopleBody.
  ///
  /// In en, this message translates to:
  /// **'Creatives who work like you, near you or in what you do.'**
  String get peopleBody;

  /// No description provided for @peopleOpenToWork.
  ///
  /// In en, this message translates to:
  /// **'Open to work'**
  String get peopleOpenToWork;

  /// No description provided for @peopleAnyDiscipline.
  ///
  /// In en, this message translates to:
  /// **'All disciplines'**
  String get peopleAnyDiscipline;

  /// No description provided for @peopleAnyCounty.
  ///
  /// In en, this message translates to:
  /// **'All counties'**
  String get peopleAnyCounty;

  /// No description provided for @peopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}}'**
  String peopleCount(int count);

  /// No description provided for @peopleRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get peopleRequested;

  /// No description provided for @peopleConnectWith.
  ///
  /// In en, this message translates to:
  /// **'Connect with {name}'**
  String peopleConnectWith(String name);

  /// No description provided for @peopleRespond.
  ///
  /// In en, this message translates to:
  /// **'Respond'**
  String get peopleRespond;

  /// No description provided for @peopleSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get peopleSave;

  /// No description provided for @peopleSaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Save {name}'**
  String peopleSaveLabel(String name);

  /// No description provided for @peopleSaveFeature.
  ///
  /// In en, this message translates to:
  /// **'Saving people'**
  String get peopleSaveFeature;

  /// No description provided for @peopleConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get peopleConnections;

  /// No description provided for @peopleRequests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get peopleRequests;

  /// No description provided for @peopleRequestsWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 request waiting} other{{count} requests waiting}}'**
  String peopleRequestsWaiting(int count);

  /// No description provided for @peopleConnectionsBody.
  ///
  /// In en, this message translates to:
  /// **'The people you are connected with and the requests going back and forth.'**
  String get peopleConnectionsBody;

  /// No description provided for @peopleListConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get peopleListConnected;

  /// No description provided for @peopleListReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get peopleListReceived;

  /// No description provided for @peopleListSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get peopleListSent;

  /// No description provided for @peopleMore.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get peopleMore;

  /// No description provided for @peopleBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get peopleBlocked;

  /// No description provided for @peopleBlockedBody.
  ///
  /// In en, this message translates to:
  /// **'Blocking hides posts both ways and stops requests, comments and mentions.'**
  String get peopleBlockedBody;

  /// No description provided for @peopleBlockedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You have not blocked anyone'**
  String get peopleBlockedEmptyTitle;

  /// No description provided for @peopleBlockedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'People you block will be listed here, and you can unblock them at any time.'**
  String get peopleBlockedEmptyBody;

  /// No description provided for @peopleUnblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get peopleUnblock;

  /// No description provided for @peopleUnblockLabel.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}'**
  String peopleUnblockLabel(String name);

  /// No description provided for @peopleBlockedSince.
  ///
  /// In en, this message translates to:
  /// **'Blocked {date}'**
  String peopleBlockedSince(String date);

  /// No description provided for @peopleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No one to suggest yet'**
  String get peopleEmptyTitle;

  /// No description provided for @peopleEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'As more creatives join and your profile fills in, people you may want to meet will appear here.'**
  String get peopleEmptyBody;

  /// No description provided for @peopleEmptyFilteredTitle.
  ///
  /// In en, this message translates to:
  /// **'No one matches those filters'**
  String get peopleEmptyFilteredTitle;

  /// No description provided for @peopleEmptyFilteredBody.
  ///
  /// In en, this message translates to:
  /// **'Try fewer filters or a different county.'**
  String get peopleEmptyFilteredBody;

  /// No description provided for @peopleClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get peopleClearFilters;

  /// No description provided for @peopleConnectedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No connections yet'**
  String get peopleConnectedEmptyTitle;

  /// No description provided for @peopleConnectedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Connect with people you meet on Atarah and they will be listed here.'**
  String get peopleConnectedEmptyBody;

  /// No description provided for @peopleReceivedEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests waiting'**
  String get peopleReceivedEmptyTitle;

  /// No description provided for @peopleReceivedEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When someone asks to connect, you can accept or decline here.'**
  String get peopleReceivedEmptyBody;

  /// No description provided for @peopleSentEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get peopleSentEmptyTitle;

  /// No description provided for @peopleSentEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Requests you have sent that have not been answered yet are listed here.'**
  String get peopleSentEmptyBody;

  /// No description provided for @peopleSince.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String peopleSince(String date);

  /// No description provided for @peopleRequestedOn.
  ///
  /// In en, this message translates to:
  /// **'Requested {date}'**
  String peopleRequestedOn(String date);

  /// No description provided for @peopleSentCancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdraw request to {name}'**
  String peopleSentCancelLabel(String name);

  /// No description provided for @peopleAcceptLabel.
  ///
  /// In en, this message translates to:
  /// **'Accept {name}'**
  String peopleAcceptLabel(String name);

  /// No description provided for @peopleDeclineLabel.
  ///
  /// In en, this message translates to:
  /// **'Decline {name}'**
  String peopleDeclineLabel(String name);

  /// No description provided for @peopleErrVerification.
  ///
  /// In en, this message translates to:
  /// **'Verify your email or phone first and you can connect with people. It only takes a minute.'**
  String get peopleErrVerification;

  /// No description provided for @peopleErrRestricted.
  ///
  /// In en, this message translates to:
  /// **'Your account is restricted for now, so you cannot do this. We will let you know if that changes.'**
  String get peopleErrRestricted;

  /// No description provided for @peopleErrRateLimited.
  ///
  /// In en, this message translates to:
  /// **'You have done a lot in a short time. Take a breather and try again a little later.'**
  String get peopleErrRateLimited;

  /// No description provided for @peopleErrNotFound.
  ///
  /// In en, this message translates to:
  /// **'That person is not available any more.'**
  String get peopleErrNotFound;

  /// No description provided for @opSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Funding, gigs and open calls matched to your craft.'**
  String get opSubtitle;

  /// No description provided for @opSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get opSaved;

  /// No description provided for @opSavedCount.
  ///
  /// In en, this message translates to:
  /// **'Saved, {count} items'**
  String opSavedCount(int count);

  /// No description provided for @opSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search grants, gigs, jobs…'**
  String get opSearchHint;

  /// No description provided for @opCatAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get opCatAll;

  /// No description provided for @opCatFunding.
  ///
  /// In en, this message translates to:
  /// **'Funding'**
  String get opCatFunding;

  /// No description provided for @opCatGrants.
  ///
  /// In en, this message translates to:
  /// **'Grants'**
  String get opCatGrants;

  /// No description provided for @opCatJobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get opCatJobs;

  /// No description provided for @opCatInternships.
  ///
  /// In en, this message translates to:
  /// **'Internships'**
  String get opCatInternships;

  /// No description provided for @opCatGigs.
  ///
  /// In en, this message translates to:
  /// **'Gigs'**
  String get opCatGigs;

  /// No description provided for @opCatCompetitions.
  ///
  /// In en, this message translates to:
  /// **'Competitions'**
  String get opCatCompetitions;

  /// No description provided for @opCatFestivals.
  ///
  /// In en, this message translates to:
  /// **'Festivals'**
  String get opCatFestivals;

  /// No description provided for @opCatPartnerships.
  ///
  /// In en, this message translates to:
  /// **'Partnerships'**
  String get opCatPartnerships;

  /// No description provided for @opCatFellowships.
  ///
  /// In en, this message translates to:
  /// **'Fellowships'**
  String get opCatFellowships;

  /// No description provided for @opCatResidencies.
  ///
  /// In en, this message translates to:
  /// **'Residencies'**
  String get opCatResidencies;

  /// No description provided for @opCatProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Programmes'**
  String get opCatProgrammes;

  /// No description provided for @opTypeGrant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get opTypeGrant;

  /// No description provided for @opTypeFunding.
  ///
  /// In en, this message translates to:
  /// **'Funding'**
  String get opTypeFunding;

  /// No description provided for @opTypeJob.
  ///
  /// In en, this message translates to:
  /// **'Job'**
  String get opTypeJob;

  /// No description provided for @opTypeInternship.
  ///
  /// In en, this message translates to:
  /// **'Internship'**
  String get opTypeInternship;

  /// No description provided for @opTypeGig.
  ///
  /// In en, this message translates to:
  /// **'Gig'**
  String get opTypeGig;

  /// No description provided for @opTypeCompetition.
  ///
  /// In en, this message translates to:
  /// **'Competition'**
  String get opTypeCompetition;

  /// No description provided for @opTypeFestival.
  ///
  /// In en, this message translates to:
  /// **'Festival'**
  String get opTypeFestival;

  /// No description provided for @opTypePartnership.
  ///
  /// In en, this message translates to:
  /// **'Partnership'**
  String get opTypePartnership;

  /// No description provided for @opTypeFellowship.
  ///
  /// In en, this message translates to:
  /// **'Fellowship'**
  String get opTypeFellowship;

  /// No description provided for @opTypeResidency.
  ///
  /// In en, this message translates to:
  /// **'Residency'**
  String get opTypeResidency;

  /// No description provided for @opTypeProgramme.
  ///
  /// In en, this message translates to:
  /// **'Programme'**
  String get opTypeProgramme;

  /// No description provided for @opFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get opFeatured;

  /// No description provided for @opClosingSoon.
  ///
  /// In en, this message translates to:
  /// **'Closing soon'**
  String get opClosingSoon;

  /// No description provided for @opRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get opRecent;

  /// No description provided for @opOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open {kind}'**
  String opOpenCount(int count, String kind);

  /// No description provided for @opKindAll.
  ///
  /// In en, this message translates to:
  /// **'opportunities'**
  String get opKindAll;

  /// No description provided for @opSortDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline: soonest'**
  String get opSortDeadline;

  /// No description provided for @opSortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get opSortRecent;

  /// No description provided for @opSortRelevance.
  ///
  /// In en, this message translates to:
  /// **'Most relevant'**
  String get opSortRelevance;

  /// No description provided for @opSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get opSortBy;

  /// No description provided for @opFilterDeadline.
  ///
  /// In en, this message translates to:
  /// **'Closing within'**
  String get opFilterDeadline;

  /// No description provided for @opFilterAnyTime.
  ///
  /// In en, this message translates to:
  /// **'Any time'**
  String get opFilterAnyTime;

  /// No description provided for @opFilterDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String opFilterDays(int days);

  /// No description provided for @opFilterRemote.
  ///
  /// In en, this message translates to:
  /// **'Remote only'**
  String get opFilterRemote;

  /// No description provided for @opFilterRemoteBody.
  ///
  /// In en, this message translates to:
  /// **'Work you can do from anywhere'**
  String get opFilterRemoteBody;

  /// No description provided for @opFilterTrust.
  ///
  /// In en, this message translates to:
  /// **'Trust'**
  String get opFilterTrust;

  /// No description provided for @opFilterTrustAny.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get opFilterTrustAny;

  /// No description provided for @opFilterApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get opFilterApply;

  /// No description provided for @opNoResults.
  ///
  /// In en, this message translates to:
  /// **'No opportunities match'**
  String get opNoResults;

  /// No description provided for @opNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try clearing a filter, or check back soon.'**
  String get opNoResultsBody;

  /// No description provided for @opNothingOpen.
  ///
  /// In en, this message translates to:
  /// **'Nothing open right now'**
  String get opNothingOpen;

  /// No description provided for @opNothingOpenBody.
  ///
  /// In en, this message translates to:
  /// **'New opportunities are added often. Check back soon.'**
  String get opNothingOpenBody;

  /// No description provided for @opDaysLeft.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Closes today} =1{1 day left} other{{count} days left}}'**
  String opDaysLeft(int count);

  /// No description provided for @opRolling.
  ///
  /// In en, this message translates to:
  /// **'Rolling deadline'**
  String get opRolling;

  /// No description provided for @opClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get opClosed;

  /// No description provided for @opStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get opStatusSaved;

  /// No description provided for @opStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get opStatusInProgress;

  /// No description provided for @opStatusApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get opStatusApplied;

  /// No description provided for @opStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get opStatusCompleted;

  /// No description provided for @opStatusSavedLeft.
  ///
  /// In en, this message translates to:
  /// **'Saved · {when}'**
  String opStatusSavedLeft(String when);

  /// No description provided for @opStatusClosingIn.
  ///
  /// In en, this message translates to:
  /// **'Closing in {count, plural, =0{less than a day} =1{1 day} other{{count} days}}'**
  String opStatusClosingIn(int count);

  /// No description provided for @opStatusAppliedOn.
  ///
  /// In en, this message translates to:
  /// **'Applied externally · {date}'**
  String opStatusAppliedOn(String date);

  /// No description provided for @opStatusCompletedOutcome.
  ///
  /// In en, this message translates to:
  /// **'Completed · {outcome}'**
  String opStatusCompletedOutcome(String outcome);

  /// No description provided for @opApplyWebsite.
  ///
  /// In en, this message translates to:
  /// **'Apply on external website'**
  String get opApplyWebsite;

  /// No description provided for @opApplyEmail.
  ///
  /// In en, this message translates to:
  /// **'Apply by email'**
  String get opApplyEmail;

  /// No description provided for @opClosedNotice.
  ///
  /// In en, this message translates to:
  /// **'This opportunity has closed. It stays in your list so you keep your record.'**
  String get opClosedNotice;

  /// No description provided for @opAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get opAbout;

  /// No description provided for @opRequirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get opRequirements;

  /// No description provided for @opBenefits.
  ///
  /// In en, this message translates to:
  /// **'Benefits'**
  String get opBenefits;

  /// No description provided for @opFactDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get opFactDeadline;

  /// No description provided for @opFactValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get opFactValue;

  /// No description provided for @opFactLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get opFactLocation;

  /// No description provided for @opFactApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get opFactApplication;

  /// No description provided for @opApplicationExternal.
  ///
  /// In en, this message translates to:
  /// **'External website'**
  String get opApplicationExternal;

  /// No description provided for @opApplicationEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get opApplicationEmail;

  /// No description provided for @opNotStated.
  ///
  /// In en, this message translates to:
  /// **'Not stated'**
  String get opNotStated;

  /// No description provided for @opHelpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help me understand this'**
  String get opHelpTitle;

  /// No description provided for @opHelpBody.
  ///
  /// In en, this message translates to:
  /// **'AI summary of eligibility and what to prepare'**
  String get opHelpBody;

  /// No description provided for @opShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get opShare;

  /// No description provided for @opSave.
  ///
  /// In en, this message translates to:
  /// **'Save opportunity'**
  String get opSave;

  /// No description provided for @opUnsave.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get opUnsave;

  /// No description provided for @opGapMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Your profile is missing 1 requirement} other{Your profile is missing {count} requirements}}'**
  String opGapMissing(int count);

  /// No description provided for @opGapMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Add them before you apply'**
  String get opGapMissingBody;

  /// No description provided for @opGapReady.
  ///
  /// In en, this message translates to:
  /// **'You meet the requirements Atarah can check'**
  String get opGapReady;

  /// No description provided for @opGapReadyBody.
  ///
  /// In en, this message translates to:
  /// **'Read the listing for anything else the provider asks for.'**
  String get opGapReadyBody;

  /// No description provided for @opGapUnchecked.
  ///
  /// In en, this message translates to:
  /// **'Atarah can\'t check these requirements'**
  String get opGapUnchecked;

  /// No description provided for @opGapUncheckedBody.
  ///
  /// In en, this message translates to:
  /// **'The provider will confirm them. Read each one carefully.'**
  String get opGapUncheckedBody;

  /// No description provided for @opGapNoRules.
  ///
  /// In en, this message translates to:
  /// **'No special requirements listed'**
  String get opGapNoRules;

  /// No description provided for @opGapNoRulesBody.
  ///
  /// In en, this message translates to:
  /// **'Read the listing and apply when you\'re ready.'**
  String get opGapNoRulesBody;

  /// No description provided for @opGapAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get opGapAdd;

  /// No description provided for @opGapCannotCheck.
  ///
  /// In en, this message translates to:
  /// **'We can\'t check this'**
  String get opGapCannotCheck;

  /// No description provided for @opGapProgress.
  ///
  /// In en, this message translates to:
  /// **'{met} of {total} met'**
  String opGapProgress(int met, int total);

  /// No description provided for @opMineTitle.
  ///
  /// In en, this message translates to:
  /// **'My opportunities'**
  String get opMineTitle;

  /// No description provided for @opSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved opportunities'**
  String get opSavedTitle;

  /// No description provided for @opTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get opTabAll;

  /// No description provided for @opTabClosing.
  ///
  /// In en, this message translates to:
  /// **'Closing soon'**
  String get opTabClosing;

  /// No description provided for @opTabApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get opTabApplied;

  /// No description provided for @opTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get opTabCompleted;

  /// No description provided for @opEmptyAll.
  ///
  /// In en, this message translates to:
  /// **'Nothing tracked yet'**
  String get opEmptyAll;

  /// No description provided for @opEmptyAllBody.
  ///
  /// In en, this message translates to:
  /// **'Save an opportunity or apply for one to follow it here.'**
  String get opEmptyAllBody;

  /// No description provided for @opEmptyClosing.
  ///
  /// In en, this message translates to:
  /// **'Nothing closing soon'**
  String get opEmptyClosing;

  /// No description provided for @opEmptyClosingBody.
  ///
  /// In en, this message translates to:
  /// **'Saved opportunities with a deadline in the next 14 days show up here.'**
  String get opEmptyClosingBody;

  /// No description provided for @opEmptyApplied.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get opEmptyApplied;

  /// No description provided for @opEmptyAppliedBody.
  ///
  /// In en, this message translates to:
  /// **'Opportunities you apply for are listed here.'**
  String get opEmptyAppliedBody;

  /// No description provided for @opEmptyCompleted.
  ///
  /// In en, this message translates to:
  /// **'Nothing completed yet'**
  String get opEmptyCompleted;

  /// No description provided for @opEmptyCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Opportunities you finish will be kept here for your Creative Passport.'**
  String get opEmptyCompletedBody;

  /// No description provided for @opEmptySaved.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get opEmptySaved;

  /// No description provided for @opEmptySavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on an opportunity to keep it here.'**
  String get opEmptySavedBody;

  /// No description provided for @opExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore opportunities'**
  String get opExplore;

  /// No description provided for @opMarkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark as completed'**
  String get opMarkCompleted;

  /// No description provided for @opOutcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get opOutcomeTitle;

  /// No description provided for @opOutcomeAwarded.
  ///
  /// In en, this message translates to:
  /// **'Awarded'**
  String get opOutcomeAwarded;

  /// No description provided for @opOutcomeNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get opOutcomeNotSelected;

  /// No description provided for @opOutcomeWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get opOutcomeWithdrawn;

  /// No description provided for @opOutcomeUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not sure yet'**
  String get opOutcomeUnknown;

  /// No description provided for @opOutcomeSave.
  ///
  /// In en, this message translates to:
  /// **'Save outcome'**
  String get opOutcomeSave;

  /// No description provided for @opAwardedTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get opAwardedTitle;

  /// No description provided for @opAwardedBody.
  ///
  /// In en, this message translates to:
  /// **'Add this win to your achievements so it shows on your Creative Passport.'**
  String get opAwardedBody;

  /// No description provided for @opAddAchievement.
  ///
  /// In en, this message translates to:
  /// **'Add this to your achievements'**
  String get opAddAchievement;

  /// No description provided for @opNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get opNotNow;

  /// No description provided for @opOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t open that. Try again.'**
  String get opOpenFailed;

  /// No description provided for @opNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'That opportunity is not available any more.'**
  String get opNotAvailable;

  /// No description provided for @opMineSummary.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved · {applied} applied · {completed} completed'**
  String opMineSummary(int saved, int applied, int completed);

  /// No description provided for @opSearchTab.
  ///
  /// In en, this message translates to:
  /// **'Opportunities ({count})'**
  String opSearchTab(int count);

  /// No description provided for @lnHubTitle.
  ///
  /// In en, this message translates to:
  /// **'Skill Labs'**
  String get lnHubTitle;

  /// No description provided for @lnHubSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Build the skills that move your creative career forward.'**
  String get lnHubSubtitle;

  /// No description provided for @lnMyLearning.
  ///
  /// In en, this message translates to:
  /// **'My learning'**
  String get lnMyLearning;

  /// No description provided for @lnContinueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get lnContinueLearning;

  /// No description provided for @lnContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE LEARNING'**
  String get lnContinueLabel;

  /// No description provided for @lnContinueMeta.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n} of {total} · {title}'**
  String lnContinueMeta(int n, int total, String title);

  /// No description provided for @lnContinueMetaNoTitle.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} lessons done'**
  String lnContinueMetaNoTitle(int done, int total);

  /// No description provided for @lnFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured Labs'**
  String get lnFeatured;

  /// No description provided for @lnCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get lnCategories;

  /// No description provided for @lnGroupCreative.
  ///
  /// In en, this message translates to:
  /// **'Creative'**
  String get lnGroupCreative;

  /// No description provided for @lnGroupBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get lnGroupBusiness;

  /// No description provided for @lnGroupProfessional.
  ///
  /// In en, this message translates to:
  /// **'Professional'**
  String get lnGroupProfessional;

  /// No description provided for @lnResourcesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 resource} other{{count} resources}}'**
  String lnResourcesCount(int count);

  /// No description provided for @lnRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get lnRecommended;

  /// No description provided for @lnHubEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Skill Labs yet'**
  String get lnHubEmptyTitle;

  /// No description provided for @lnHubEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Courses and resources will appear here as soon as they are published.'**
  String get lnHubEmptyBody;

  /// No description provided for @lnOpenHub.
  ///
  /// In en, this message translates to:
  /// **'Open Skill Labs'**
  String get lnOpenHub;

  /// No description provided for @lnTypeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get lnTypeAll;

  /// No description provided for @lnTypeCourse.
  ///
  /// In en, this message translates to:
  /// **'Course'**
  String get lnTypeCourse;

  /// No description provided for @lnTypeTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get lnTypeTutorial;

  /// No description provided for @lnTypeToolkit.
  ///
  /// In en, this message translates to:
  /// **'Toolkit'**
  String get lnTypeToolkit;

  /// No description provided for @lnTypeWebinar.
  ///
  /// In en, this message translates to:
  /// **'Webinar'**
  String get lnTypeWebinar;

  /// No description provided for @lnTypeMasterclass.
  ///
  /// In en, this message translates to:
  /// **'Masterclass'**
  String get lnTypeMasterclass;

  /// No description provided for @lnTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get lnTypeArticle;

  /// No description provided for @lnPluralCourse.
  ///
  /// In en, this message translates to:
  /// **'courses'**
  String get lnPluralCourse;

  /// No description provided for @lnPluralTutorial.
  ///
  /// In en, this message translates to:
  /// **'tutorials'**
  String get lnPluralTutorial;

  /// No description provided for @lnPluralToolkit.
  ///
  /// In en, this message translates to:
  /// **'toolkits'**
  String get lnPluralToolkit;

  /// No description provided for @lnPluralWebinar.
  ///
  /// In en, this message translates to:
  /// **'webinars'**
  String get lnPluralWebinar;

  /// No description provided for @lnPluralMasterclass.
  ///
  /// In en, this message translates to:
  /// **'masterclasses'**
  String get lnPluralMasterclass;

  /// No description provided for @lnPluralArticle.
  ///
  /// In en, this message translates to:
  /// **'articles'**
  String get lnPluralArticle;

  /// No description provided for @lnPluralAll.
  ///
  /// In en, this message translates to:
  /// **'resources'**
  String get lnPluralAll;

  /// No description provided for @lnSourceAtarahCourse.
  ///
  /// In en, this message translates to:
  /// **'✓ Atarah Course'**
  String get lnSourceAtarahCourse;

  /// No description provided for @lnSourceAtarahEditorial.
  ///
  /// In en, this message translates to:
  /// **'✓ Atarah Editorial'**
  String get lnSourceAtarahEditorial;

  /// No description provided for @lnSourcePartner.
  ///
  /// In en, this message translates to:
  /// **'Partner content'**
  String get lnSourcePartner;

  /// No description provided for @lnSourceExternal.
  ///
  /// In en, this message translates to:
  /// **'External resource'**
  String get lnSourceExternal;

  /// No description provided for @lnDeliveryNative.
  ///
  /// In en, this message translates to:
  /// **'In-app lessons'**
  String get lnDeliveryNative;

  /// No description provided for @lnDeliveryEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Embedded'**
  String get lnDeliveryEmbedded;

  /// No description provided for @lnDeliveryExternal.
  ///
  /// In en, this message translates to:
  /// **'Opens outside Atarah'**
  String get lnDeliveryExternal;

  /// No description provided for @lnLevelBeginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get lnLevelBeginner;

  /// No description provided for @lnLevelIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get lnLevelIntermediate;

  /// No description provided for @lnLevelAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get lnLevelAdvanced;

  /// No description provided for @lnLevelExpert.
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get lnLevelExpert;

  /// No description provided for @lnLessonCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 lesson} other{{count} lessons}}'**
  String lnLessonCount(int count);

  /// No description provided for @lnDurationHm.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String lnDurationHm(int hours, int minutes);

  /// No description provided for @lnDurationH.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String lnDurationH(int hours);

  /// No description provided for @lnDurationM.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String lnDurationM(int minutes);

  /// No description provided for @lnPremiumBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro'**
  String get lnPremiumBadge;

  /// No description provided for @lnCategoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in {category} yet'**
  String lnCategoryEmptyTitle(String category);

  /// No description provided for @lnCategoryEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New Skill Labs are added all the time. Check back soon.'**
  String get lnCategoryEmptyBody;

  /// No description provided for @lnTypeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No {types} in {category} yet'**
  String lnTypeEmptyTitle(String types, String category);

  /// No description provided for @lnTypeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Explore all types'**
  String get lnTypeEmptyCta;

  /// No description provided for @lnLoadMoreFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load more. Tap to try again.'**
  String get lnLoadMoreFailed;

  /// No description provided for @lnYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your progress'**
  String get lnYourProgress;

  /// No description provided for @lnProgressOf.
  ///
  /// In en, this message translates to:
  /// **'{done} / {total}'**
  String lnProgressOf(int done, int total);

  /// No description provided for @lnPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String lnPercentComplete(int percent);

  /// No description provided for @lnWhatYoullLearn.
  ///
  /// In en, this message translates to:
  /// **'What you\'ll learn'**
  String get lnWhatYoullLearn;

  /// No description provided for @lnWhoItsFor.
  ///
  /// In en, this message translates to:
  /// **'Who it\'s for'**
  String get lnWhoItsFor;

  /// No description provided for @lnLessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lnLessons;

  /// No description provided for @lnTaughtBy.
  ///
  /// In en, this message translates to:
  /// **'Taught by'**
  String get lnTaughtBy;

  /// No description provided for @lnFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get lnFrom;

  /// No description provided for @lnStartLearning.
  ///
  /// In en, this message translates to:
  /// **'Start learning'**
  String get lnStartLearning;

  /// No description provided for @lnReviewCourse.
  ///
  /// In en, this message translates to:
  /// **'Review course'**
  String get lnReviewCourse;

  /// No description provided for @lnLessonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get lnLessonDone;

  /// No description provided for @lnLessonCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get lnLessonCurrent;

  /// No description provided for @lnLessonLocked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get lnLessonLocked;

  /// No description provided for @lnLessonRow.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n}: {title}, {minutes} minutes, {state}'**
  String lnLessonRow(int n, String title, int minutes, String state);

  /// No description provided for @lnLessonMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String lnLessonMinutes(int minutes);

  /// No description provided for @lnSaveLab.
  ///
  /// In en, this message translates to:
  /// **'Save to my learning'**
  String get lnSaveLab;

  /// No description provided for @lnUnsaveLab.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get lnUnsaveLab;

  /// No description provided for @lnShareLab.
  ///
  /// In en, this message translates to:
  /// **'Share this Skill Lab'**
  String get lnShareLab;

  /// No description provided for @lnCertificateEarned.
  ///
  /// In en, this message translates to:
  /// **'Certificate earned'**
  String get lnCertificateEarned;

  /// No description provided for @lnCertificateNumber.
  ///
  /// In en, this message translates to:
  /// **'No. {number}'**
  String lnCertificateNumber(String number);

  /// No description provided for @lnCertificateIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued {date}'**
  String lnCertificateIssued(String date);

  /// No description provided for @lnViewOnPassport.
  ///
  /// In en, this message translates to:
  /// **'See it in your achievements'**
  String get lnViewOnPassport;

  /// No description provided for @lnPremiumFeature.
  ///
  /// In en, this message translates to:
  /// **'Premium Skill Labs'**
  String get lnPremiumFeature;

  /// No description provided for @lnPremiumWhat.
  ///
  /// In en, this message translates to:
  /// **'Courses and masterclasses from Atarah and our partners, with certificates.'**
  String get lnPremiumWhat;

  /// No description provided for @lnPremiumWhy.
  ///
  /// In en, this message translates to:
  /// **'Structured learning is the quickest way to move a skill from good to hireable.'**
  String get lnPremiumWhy;

  /// No description provided for @lnPremiumHow.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Atarah Pro to open every Skill Lab.'**
  String get lnPremiumHow;

  /// No description provided for @lnOpenResource.
  ///
  /// In en, this message translates to:
  /// **'Open resource'**
  String get lnOpenResource;

  /// No description provided for @lnLeavingBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re going to {domain}. It\'s a resource from outside Atarah, so what you do there stays there.'**
  String lnLeavingBody(String domain);

  /// No description provided for @lnMarkComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as complete'**
  String get lnMarkComplete;

  /// No description provided for @lnCompletedItem.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lnCompletedItem;

  /// No description provided for @lnStartedItem.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get lnStartedItem;

  /// No description provided for @lnFindSimilar.
  ///
  /// In en, this message translates to:
  /// **'Find similar'**
  String get lnFindSimilar;

  /// No description provided for @lnWatchEmbedded.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get lnWatchEmbedded;

  /// No description provided for @lnEnrolFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t start that course. Try again.'**
  String get lnEnrolFailed;

  /// No description provided for @lnNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to continue.'**
  String get lnNeedsConnection;

  /// No description provided for @lnSavedCopyBanner.
  ///
  /// In en, this message translates to:
  /// **'Showing your saved copy. Connect to the internet to keep learning.'**
  String get lnSavedCopyBanner;

  /// No description provided for @lnLessonOf.
  ///
  /// In en, this message translates to:
  /// **'Lesson {n} of {total}'**
  String lnLessonOf(int n, int total);

  /// No description provided for @lnPractice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get lnPractice;

  /// No description provided for @lnAddToPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Add to portfolio'**
  String get lnAddToPortfolio;

  /// No description provided for @lnLearnNext.
  ///
  /// In en, this message translates to:
  /// **'What should I learn next?'**
  String get lnLearnNext;

  /// No description provided for @lnAllLessons.
  ///
  /// In en, this message translates to:
  /// **'All lessons'**
  String get lnAllLessons;

  /// No description provided for @lnMarkCompleteNext.
  ///
  /// In en, this message translates to:
  /// **'Mark complete & next'**
  String get lnMarkCompleteNext;

  /// No description provided for @lnMarkCompleteFinish.
  ///
  /// In en, this message translates to:
  /// **'Mark complete & finish'**
  String get lnMarkCompleteFinish;

  /// No description provided for @lnLessonProgressBar.
  ///
  /// In en, this message translates to:
  /// **'Lesson progress: {done} of {total} lessons complete'**
  String lnLessonProgressBar(int done, int total);

  /// No description provided for @lnVideoLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this video.'**
  String get lnVideoLoadFailed;

  /// No description provided for @lnVideoPreparing.
  ///
  /// In en, this message translates to:
  /// **'The video is still being prepared. Try again in a moment.'**
  String get lnVideoPreparing;

  /// No description provided for @lnEmbedFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'{service} isn\'t responding'**
  String lnEmbedFailedTitle(String service);

  /// No description provided for @lnBackToCourse.
  ///
  /// In en, this message translates to:
  /// **'Go back to course'**
  String get lnBackToCourse;

  /// No description provided for @lnVideoResuming.
  ///
  /// In en, this message translates to:
  /// **'Resuming from {time}'**
  String lnVideoResuming(String time);

  /// No description provided for @lnLessonLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Finish the earlier lessons to unlock this one.'**
  String get lnLessonLockedMessage;

  /// No description provided for @lnSaveProgressFailed.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your progress. It will retry.'**
  String get lnSaveProgressFailed;

  /// No description provided for @lnVideoSemantic.
  ///
  /// In en, this message translates to:
  /// **'Lesson video'**
  String get lnVideoSemantic;

  /// No description provided for @lnCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Course complete!'**
  String get lnCompleteTitle;

  /// No description provided for @lnCompleteBody.
  ///
  /// In en, this message translates to:
  /// **'You finished {course}. Your certificate is added to your achievements.'**
  String lnCompleteBody(String course);

  /// No description provided for @lnCompleteShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get lnCompleteShare;

  /// No description provided for @lnCompleteShareText.
  ///
  /// In en, this message translates to:
  /// **'I just completed {course} on Atarah Skill Labs.'**
  String lnCompleteShareText(String course);

  /// No description provided for @lnBackToLabs.
  ///
  /// In en, this message translates to:
  /// **'Back to Skill Labs'**
  String get lnBackToLabs;

  /// No description provided for @lnStatInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get lnStatInProgress;

  /// No description provided for @lnStatCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lnStatCompleted;

  /// No description provided for @lnStatHours.
  ///
  /// In en, this message translates to:
  /// **'Hours this month'**
  String get lnStatHours;

  /// No description provided for @lnTabActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lnTabActive;

  /// No description provided for @lnTabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get lnTabCompleted;

  /// No description provided for @lnTabSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get lnTabSaved;

  /// No description provided for @lnSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved Skill Labs'**
  String get lnSavedTitle;

  /// No description provided for @lnEmptyActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing in progress'**
  String get lnEmptyActiveTitle;

  /// No description provided for @lnEmptyActiveBody.
  ///
  /// In en, this message translates to:
  /// **'Start a Skill Lab and pick up where you left off, any time.'**
  String get lnEmptyActiveBody;

  /// No description provided for @lnEmptyActiveCta.
  ///
  /// In en, this message translates to:
  /// **'Browse Skill Labs'**
  String get lnEmptyActiveCta;

  /// No description provided for @lnEmptyCompletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing completed yet'**
  String get lnEmptyCompletedTitle;

  /// No description provided for @lnEmptyCompletedBody.
  ///
  /// In en, this message translates to:
  /// **'Finish a course to earn a certificate for your Passport.'**
  String get lnEmptyCompletedBody;

  /// No description provided for @lnEmptySavedTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved Skill Labs'**
  String get lnEmptySavedTitle;

  /// No description provided for @lnEmptySavedBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on a Skill Lab to keep it here.'**
  String get lnEmptySavedBody;

  /// No description provided for @lnCompletedOn.
  ///
  /// In en, this message translates to:
  /// **'Completed {date}'**
  String lnCompletedOn(String date);

  /// No description provided for @lnLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last active {date}'**
  String lnLastActive(String date);

  /// No description provided for @lnSearchTab.
  ///
  /// In en, this message translates to:
  /// **'Skill Labs ({count})'**
  String lnSearchTab(int count);

  /// No description provided for @premiumSeeProPlain.
  ///
  /// In en, this message translates to:
  /// **'See Pro'**
  String get premiumSeeProPlain;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @ayActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get ayActivityTitle;

  /// No description provided for @ayPickUp.
  ///
  /// In en, this message translates to:
  /// **'Pick up where you left off'**
  String get ayPickUp;

  /// No description provided for @ayNothingToResume.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pick up right now. Start a Skill Lab, save an opportunity or add a project.'**
  String get ayNothingToResume;

  /// No description provided for @ayResumeLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue lesson'**
  String get ayResumeLesson;

  /// No description provided for @ayResumeOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Finish your application'**
  String get ayResumeOpportunity;

  /// No description provided for @ayResumeProject.
  ///
  /// In en, this message translates to:
  /// **'Finish your project'**
  String get ayResumeProject;

  /// No description provided for @ayTileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get ayTileSaved;

  /// No description provided for @ayTileApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get ayTileApplications;

  /// No description provided for @ayTileLearning.
  ///
  /// In en, this message translates to:
  /// **'My learning'**
  String get ayTileLearning;

  /// No description provided for @ayTilePortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get ayTilePortfolio;

  /// No description provided for @ayTileConnections.
  ///
  /// In en, this message translates to:
  /// **'Connections'**
  String get ayTileConnections;

  /// No description provided for @ayTileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get ayTileNotifications;

  /// No description provided for @ayTileMentorship.
  ///
  /// In en, this message translates to:
  /// **'Mentorship'**
  String get ayTileMentorship;

  /// No description provided for @ayTileMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get ayTileMarketplace;

  /// No description provided for @aySoonP2.
  ///
  /// In en, this message translates to:
  /// **'Soon · P2'**
  String get aySoonP2;

  /// No description provided for @ayCount.
  ///
  /// In en, this message translates to:
  /// **'{count} saved'**
  String ayCount(int count);

  /// No description provided for @ayInProgressCount.
  ///
  /// In en, this message translates to:
  /// **'{count} in progress'**
  String ayInProgressCount(int count);

  /// No description provided for @ayPendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} waiting'**
  String ayPendingCount(int count);

  /// No description provided for @ayUnreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String ayUnreadCount(int count);

  /// No description provided for @ayApplicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get ayApplicationsTitle;

  /// No description provided for @ayApplicationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No applications yet'**
  String get ayApplicationsEmptyTitle;

  /// No description provided for @ayApplicationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'When you start or finish an application it is tracked here.'**
  String get ayApplicationsEmptyBody;

  /// No description provided for @ayFindOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Find opportunities'**
  String get ayFindOpportunities;

  /// No description provided for @ayApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get ayApplied;

  /// No description provided for @ayCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get ayCompleted;

  /// No description provided for @ayInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get ayInProgress;

  /// No description provided for @ntTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get ntTitle;

  /// No description provided for @ntSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get ntSettings;

  /// No description provided for @ntAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ntAll;

  /// No description provided for @ntCatOpportunities.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get ntCatOpportunities;

  /// No description provided for @ntCatMentorship.
  ///
  /// In en, this message translates to:
  /// **'Mentorship'**
  String get ntCatMentorship;

  /// No description provided for @ntCatCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get ntCatCommunity;

  /// No description provided for @ntCatLearning.
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get ntCatLearning;

  /// No description provided for @ntCatProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get ntCatProfile;

  /// No description provided for @ntCatMarketplace.
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get ntCatMarketplace;

  /// No description provided for @ntCatSystem.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get ntCatSystem;

  /// No description provided for @ntToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get ntToday;

  /// No description provided for @ntEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get ntEarlier;

  /// No description provided for @ntMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get ntMarkAllRead;

  /// No description provided for @ntEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up'**
  String get ntEmptyTitle;

  /// No description provided for @ntEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'New connection requests, reminders and replies show up here.'**
  String get ntEmptyBody;

  /// No description provided for @ntEmptyCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No {category} notifications'**
  String ntEmptyCategoryTitle(String category);

  /// No description provided for @sdTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get sdTitle;

  /// No description provided for @sdAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get sdAll;

  /// No description provided for @sdTypeOpportunity.
  ///
  /// In en, this message translates to:
  /// **'Opportunities'**
  String get sdTypeOpportunity;

  /// No description provided for @sdTypeLearning.
  ///
  /// In en, this message translates to:
  /// **'Skill Labs'**
  String get sdTypeLearning;

  /// No description provided for @sdTypeCreative.
  ///
  /// In en, this message translates to:
  /// **'Creatives'**
  String get sdTypeCreative;

  /// No description provided for @sdTypeArticle.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get sdTypeArticle;

  /// No description provided for @sdTypePost.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get sdTypePost;

  /// No description provided for @sdTypeListing.
  ///
  /// In en, this message translates to:
  /// **'Listings'**
  String get sdTypeListing;

  /// No description provided for @sdTypeMentor.
  ///
  /// In en, this message translates to:
  /// **'Mentors'**
  String get sdTypeMentor;

  /// No description provided for @sdEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing saved yet'**
  String get sdEmptyTitle;

  /// No description provided for @sdEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark on an opportunity, Skill Lab, article or post to keep it here.'**
  String get sdEmptyBody;

  /// No description provided for @sdEmptyTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved {type}'**
  String sdEmptyTypeTitle(String type);

  /// No description provided for @sdExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get sdExplore;

  /// No description provided for @sdUnsaveFailed.
  ///
  /// In en, this message translates to:
  /// **'That could not be removed from your saved list.'**
  String get sdUnsaveFailed;

  /// No description provided for @stSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get stSaved;

  /// No description provided for @stSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get stSaveChanges;

  /// No description provided for @stFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get stFullName;

  /// No description provided for @stUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get stUsername;

  /// No description provided for @stUsernameHelp.
  ///
  /// In en, this message translates to:
  /// **'Your public address: atarah.app/username'**
  String get stUsernameHelp;

  /// No description provided for @stEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stEmail;

  /// No description provided for @stPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get stPhone;

  /// No description provided for @stNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not added'**
  String get stNotSet;

  /// No description provided for @stChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get stChange;

  /// No description provided for @stChangeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get stChangeEmail;

  /// No description provided for @stChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change phone number'**
  String get stChangePhone;

  /// No description provided for @stChangeEmailBody.
  ///
  /// In en, this message translates to:
  /// **'We will send a link to the new address. Your email changes when you open it. We also tell your current address.'**
  String get stChangeEmailBody;

  /// No description provided for @stChangePhoneBody.
  ///
  /// In en, this message translates to:
  /// **'We will send a code to the new number. Your number changes when you enter it.'**
  String get stChangePhoneBody;

  /// No description provided for @stNewEmail.
  ///
  /// In en, this message translates to:
  /// **'New email'**
  String get stNewEmail;

  /// No description provided for @stNewPhone.
  ///
  /// In en, this message translates to:
  /// **'New phone number'**
  String get stNewPhone;

  /// No description provided for @stSendLink.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get stSendLink;

  /// No description provided for @stSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get stSendCode;

  /// No description provided for @stVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get stVerify;

  /// No description provided for @stDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get stDone;

  /// No description provided for @stOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get stOk;

  /// No description provided for @stPendingChange.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you to confirm {value}'**
  String stPendingChange(String value);

  /// No description provided for @stEmailLinkSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a link to {address}. Open it to finish the change.'**
  String stEmailLinkSent(String address);

  /// No description provided for @stPhoneCodeSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {number}. Enter it below.'**
  String stPhoneCodeSent(String number);

  /// No description provided for @stPrivacyIntro.
  ///
  /// In en, this message translates to:
  /// **'Choose who sees each part of your profile. Private details still power your recommendations.'**
  String get stPrivacyIntro;

  /// No description provided for @stPrivContact.
  ///
  /// In en, this message translates to:
  /// **'Contact details'**
  String get stPrivContact;

  /// No description provided for @stPrivLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stPrivLocation;

  /// No description provided for @stPrivPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get stPrivPortfolio;

  /// No description provided for @stPrivExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get stPrivExperience;

  /// No description provided for @stPrivActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get stPrivActivity;

  /// No description provided for @stPrivNotSaved.
  ///
  /// In en, this message translates to:
  /// **'That change was not saved.'**
  String get stPrivNotSaved;

  /// No description provided for @stVisPublic.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get stVisPublic;

  /// No description provided for @stVisMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get stVisMembers;

  /// No description provided for @stVisPrivate.
  ///
  /// In en, this message translates to:
  /// **'Only me'**
  String get stVisPrivate;

  /// No description provided for @stYourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get stYourData;

  /// No description provided for @stExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get stExportTitle;

  /// No description provided for @stExportBody.
  ///
  /// In en, this message translates to:
  /// **'We prepare a file with your profile, projects and activity, and send you a link that works for 7 days. One export a day.'**
  String get stExportBody;

  /// No description provided for @stExportRequest.
  ///
  /// In en, this message translates to:
  /// **'Request my data'**
  String get stExportRequest;

  /// No description provided for @stExportRequested.
  ///
  /// In en, this message translates to:
  /// **'We are preparing your file. You will be notified when it is ready.'**
  String get stExportRequested;

  /// No description provided for @stExportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get stExportPreparing;

  /// No description provided for @stExportReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get stExportReady;

  /// No description provided for @stExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get stExportFailed;

  /// No description provided for @stExportExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get stExportExpired;

  /// No description provided for @stExportDownload.
  ///
  /// In en, this message translates to:
  /// **'Download my data'**
  String get stExportDownload;

  /// No description provided for @stExportNext.
  ///
  /// In en, this message translates to:
  /// **'You can ask again on {date}.'**
  String stExportNext(String date);

  /// No description provided for @stNotifCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get stNotifCategory;

  /// No description provided for @stNotifPush.
  ///
  /// In en, this message translates to:
  /// **'Push'**
  String get stNotifPush;

  /// No description provided for @stNotifEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stNotifEmail;

  /// No description provided for @stNotifPushFor.
  ///
  /// In en, this message translates to:
  /// **'Push notifications for {category}'**
  String stNotifPushFor(String category);

  /// No description provided for @stNotifEmailFor.
  ///
  /// In en, this message translates to:
  /// **'Email notifications for {category}'**
  String stNotifEmailFor(String category);

  /// No description provided for @stNotifOpportunitiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Deadlines and new matches'**
  String get stNotifOpportunitiesDesc;

  /// No description provided for @stNotifCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Replies, mentions and requests'**
  String get stNotifCommunityDesc;

  /// No description provided for @stNotifLearningDesc.
  ///
  /// In en, this message translates to:
  /// **'Certificates and recommendations'**
  String get stNotifLearningDesc;

  /// No description provided for @stNotifMentorshipDesc.
  ///
  /// In en, this message translates to:
  /// **'Booking updates'**
  String get stNotifMentorshipDesc;

  /// No description provided for @stNotifProfileDesc.
  ///
  /// In en, this message translates to:
  /// **'Profile tips and reminders'**
  String get stNotifProfileDesc;

  /// No description provided for @stNotifMarketplaceDesc.
  ///
  /// In en, this message translates to:
  /// **'Orders and messages'**
  String get stNotifMarketplaceDesc;

  /// No description provided for @stNotifSystemDesc.
  ///
  /// In en, this message translates to:
  /// **'Account and safety updates'**
  String get stNotifSystemDesc;

  /// No description provided for @stNotifSecurityNote.
  ///
  /// In en, this message translates to:
  /// **'Security notices, such as a new sign-in or a password change, are always sent.'**
  String get stNotifSecurityNote;

  /// No description provided for @stPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get stPassword;

  /// No description provided for @stChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get stChangePassword;

  /// No description provided for @stCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get stCurrentPassword;

  /// No description provided for @stNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get stNewPassword;

  /// No description provided for @stPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed. Other devices were signed out.'**
  String get stPasswordChanged;

  /// No description provided for @stTwoStep.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification'**
  String get stTwoStep;

  /// No description provided for @stTwoStepBody.
  ///
  /// In en, this message translates to:
  /// **'A code when you sign in on a new device'**
  String get stTwoStepBody;

  /// No description provided for @stTwoStepNeedsPhone.
  ///
  /// In en, this message translates to:
  /// **'Add a verified phone number to your account first.'**
  String get stTwoStepNeedsPhone;

  /// No description provided for @stTwoStepOn.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is on.'**
  String get stTwoStepOn;

  /// No description provided for @stTwoStepOff.
  ///
  /// In en, this message translates to:
  /// **'Two-step verification is off.'**
  String get stTwoStepOff;

  /// No description provided for @stActiveSessions.
  ///
  /// In en, this message translates to:
  /// **'Active sessions'**
  String get stActiveSessions;

  /// No description provided for @stThisDevice.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get stThisDevice;

  /// No description provided for @stUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown device'**
  String get stUnknownDevice;

  /// No description provided for @stSignOutSession.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get stSignOutSession;

  /// No description provided for @stTwoStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm it is you'**
  String get stTwoStepTitle;

  /// No description provided for @stTwoStepSms.
  ///
  /// In en, this message translates to:
  /// **'Enter the code we sent to your phone to sign in on this device.'**
  String get stTwoStepSms;

  /// No description provided for @stTwoStepApp.
  ///
  /// In en, this message translates to:
  /// **'Enter the code from your authenticator app to sign in on this device.'**
  String get stTwoStepApp;

  /// No description provided for @stTwoStepNoFactor.
  ///
  /// In en, this message translates to:
  /// **'We can\'t find a second step on your account. Sign out and sign in again, or contact support.'**
  String get stTwoStepNoFactor;

  /// No description provided for @stTwoStepWrongCode.
  ///
  /// In en, this message translates to:
  /// **'That code didn\'t work. Check it and try again.'**
  String get stTwoStepWrongCode;

  /// No description provided for @stHelpSearch.
  ///
  /// In en, this message translates to:
  /// **'Search help articles'**
  String get stHelpSearch;

  /// No description provided for @stSafetyCentre.
  ///
  /// In en, this message translates to:
  /// **'Safety centre'**
  String get stSafetyCentre;

  /// No description provided for @stSafetyCentreBody.
  ///
  /// In en, this message translates to:
  /// **'Report, block, mute'**
  String get stSafetyCentreBody;

  /// No description provided for @stHelpArticles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get stHelpArticles;

  /// No description provided for @stFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked'**
  String get stFaq;

  /// No description provided for @stHelpNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that'**
  String get stHelpNoResults;

  /// No description provided for @stHelpNoResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Try fewer words, or ask us directly below.'**
  String get stHelpNoResultsBody;

  /// No description provided for @stStillNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get stStillNeedHelp;

  /// No description provided for @stChatWithUs.
  ///
  /// In en, this message translates to:
  /// **'Chat with us'**
  String get stChatWithUs;

  /// No description provided for @stLegalEmpty.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get stLegalEmpty;

  /// No description provided for @stLegalEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Our legal documents will appear here.'**
  String get stLegalEmptyBody;

  /// No description provided for @stVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String stVersion(String version);

  /// No description provided for @stDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get stDraft;

  /// No description provided for @stDraftPending.
  ///
  /// In en, this message translates to:
  /// **'DRAFT — pending legal review'**
  String get stDraftPending;

  /// No description provided for @stCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'CURRENT PLAN'**
  String get stCurrentPlan;

  /// No description provided for @stPlanFreeBody.
  ///
  /// In en, this message translates to:
  /// **'Everything you need to build your creative identity.'**
  String get stPlanFreeBody;

  /// No description provided for @stPlanProBody.
  ///
  /// In en, this message translates to:
  /// **'Thank you for supporting Atarah.'**
  String get stPlanProBody;

  /// No description provided for @stPlanRenews.
  ///
  /// In en, this message translates to:
  /// **'Renews {date}'**
  String stPlanRenews(String date);

  /// No description provided for @stWhatsIncluded.
  ///
  /// In en, this message translates to:
  /// **'What\'s included'**
  String get stWhatsIncluded;

  /// No description provided for @stFeature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get stFeature;

  /// No description provided for @stIncluded.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get stIncluded;

  /// No description provided for @stNotIncluded.
  ///
  /// In en, this message translates to:
  /// **'Not included'**
  String get stNotIncluded;

  /// No description provided for @stUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro · {price}'**
  String stUpgrade(String price);

  /// No description provided for @stUpgradePlain.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get stUpgradePlain;

  /// No description provided for @stCancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel anytime. No hidden fees.'**
  String get stCancelAnytime;

  /// No description provided for @stDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get stDeleteAccount;

  /// No description provided for @stDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get stDeleteTitle;

  /// No description provided for @stDeleteIntro.
  ///
  /// In en, this message translates to:
  /// **'This can\'t be undone. You will permanently lose:'**
  String get stDeleteIntro;

  /// No description provided for @stDeleteLossProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile and Creative Passport'**
  String get stDeleteLossProfile;

  /// No description provided for @stDeleteLossPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio, services and achievements'**
  String get stDeleteLossPortfolio;

  /// No description provided for @stDeleteLossConnections.
  ///
  /// In en, this message translates to:
  /// **'Your connections and saved items'**
  String get stDeleteLossConnections;

  /// No description provided for @stDeleteLossProgress.
  ///
  /// In en, this message translates to:
  /// **'Your learning progress and certificates'**
  String get stDeleteLossProgress;

  /// No description provided for @stDeleteGrace.
  ///
  /// In en, this message translates to:
  /// **'Your account is hidden and you are signed out right away. Your data is deleted after 30 days. Sign in before then to restore it. Your posts and comments stay and show as \"Deleted member\".'**
  String get stDeleteGrace;

  /// No description provided for @stTypeDelete.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm'**
  String get stTypeDelete;

  /// No description provided for @stPasswordToConfirm.
  ///
  /// In en, this message translates to:
  /// **'Your password'**
  String get stPasswordToConfirm;

  /// No description provided for @stPasswordToConfirmHelp.
  ///
  /// In en, this message translates to:
  /// **'Needed if you signed in more than 5 minutes ago.'**
  String get stPasswordToConfirmHelp;

  /// No description provided for @stDeletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete account permanently'**
  String get stDeletePermanently;

  /// No description provided for @stKeepAccount.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get stKeepAccount;

  /// No description provided for @stDeletedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion'**
  String get stDeletedTitle;

  /// No description provided for @stDeletedBody.
  ///
  /// In en, this message translates to:
  /// **'It is hidden now and your data is deleted after 30 days. Sign in before then if you change your mind.'**
  String get stDeletedBody;

  /// No description provided for @stRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore your account?'**
  String get stRestoreTitle;

  /// No description provided for @stRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion on {date}. Restore it to keep everything.'**
  String stRestoreBody(String date);

  /// No description provided for @stRestoreBodyNoDate.
  ///
  /// In en, this message translates to:
  /// **'Your account is scheduled for deletion. Restore it to keep everything.'**
  String get stRestoreBodyNoDate;

  /// No description provided for @stRestoreAccount.
  ///
  /// In en, this message translates to:
  /// **'Restore account'**
  String get stRestoreAccount;

  /// No description provided for @stOfflineNeedsConnection.
  ///
  /// In en, this message translates to:
  /// **'Needs a connection'**
  String get stOfflineNeedsConnection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
