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
  /// **'Use at least 8 characters, including a number.'**
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
  /// **'Code sent. It expires in 15 minutes.'**
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
