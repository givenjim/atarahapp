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
