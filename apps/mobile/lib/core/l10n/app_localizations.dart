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

  /// No description provided for @devSignInEntry.
  ///
  /// In en, this message translates to:
  /// **'Developer sign in'**
  String get devSignInEntry;

  /// No description provided for @devSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Developer sign in'**
  String get devSignInTitle;

  /// No description provided for @devSignInBody.
  ///
  /// In en, this message translates to:
  /// **'Development builds only. Signs in with a real account on the local API.'**
  String get devSignInBody;

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
