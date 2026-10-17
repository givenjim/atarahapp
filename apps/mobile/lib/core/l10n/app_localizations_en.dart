// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Atarah';

  @override
  String get tagline => 'CREATE · CONNECT · GROW';

  @override
  String soonPhase(int phase) {
    return 'Soon · P$phase';
  }

  @override
  String get soonLater => 'Soon · Later';

  @override
  String get futureTitle => 'Coming soon';

  @override
  String get futureBody =>
      'We\'re building this part of Atarah. It will open up as the app grows.';

  @override
  String get futureBack => 'Go back';

  @override
  String get offlineBanner =>
      'You\'re offline. Saved content is still available.';

  @override
  String get needsConnection => 'Needs a connection';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get seeAll => 'See all';

  @override
  String get retry => 'Try again';

  @override
  String get loading => 'Loading';

  @override
  String get verified => 'Verified';

  @override
  String get verifiedByAtarah => 'Verified by Atarah';

  @override
  String get selfDeclared => 'Self-declared';

  @override
  String get verificationRejected => 'Not verified';

  @override
  String get verificationExpired => 'Verification expired';

  @override
  String get verificationRevoked => 'Verification revoked';

  @override
  String get underReview => 'Under review';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get clear => 'Clear';

  @override
  String get remove => 'Remove';

  @override
  String codeDigit(int position, int total) {
    return 'Digit $position of $total';
  }

  @override
  String get passwordStrengthWeak => 'Weak — use 8+ characters with a number';

  @override
  String get passwordStrengthOk => 'Almost — add a number';

  @override
  String get passwordStrengthStrong => 'Strong — 8+ characters with a number';

  @override
  String premiumGateTitle(String feature) {
    return '$feature is part of Pro';
  }

  @override
  String get premiumWhatItDoes => 'What it does';

  @override
  String get premiumWhyItMatters => 'Why it matters';

  @override
  String get premiumHowToGet => 'How to get it';

  @override
  String premiumSeePro(String price) {
    return 'See Pro · $price';
  }

  @override
  String get premiumScholarship => 'Check scholarship eligibility';

  @override
  String get errorAtarahTitle => 'Something went wrong on our side';

  @override
  String get errorAtarahBody => 'Your work is safe. Try again in a moment.';

  @override
  String get errorExternalTitle => 'That site isn\'t responding';

  @override
  String get errorExternalBody =>
      'Atarah is working normally. The other site may be down.';

  @override
  String get errorInvalidLinkTitle => 'This link no longer works';

  @override
  String get errorInvalidLinkBody => 'It may have moved or expired.';

  @override
  String get emptyTitle => 'Nothing here yet';

  @override
  String get leavingTitle => 'You\'re leaving Atarah';

  @override
  String leavingBody(String domain) {
    return 'You\'re going to $domain. Atarah doesn\'t receive or process this application.';
  }

  @override
  String get leavingTrack => 'Track this as applied in Activity';

  @override
  String get leavingContinue => 'Continue to website';

  @override
  String get leavingStay => 'Stay on Atarah';

  @override
  String get aiAssisted => 'AI-assisted';

  @override
  String get aiTestMode => 'AI preview (test mode)';

  @override
  String get aiDisclaimer =>
      'Check facts and names before applying — you\'re responsible for what you publish.';

  @override
  String get aiDiscard => 'Discard';

  @override
  String get aiApply => 'Apply';

  @override
  String get tabHome => 'Home';

  @override
  String get tabExplore => 'Explore';

  @override
  String get tabCommunity => 'Community';

  @override
  String get tabOpportunities => 'Opportunities';

  @override
  String get tabProfile => 'Profile';

  @override
  String get uploadDrop => 'Tap to add files';

  @override
  String get uploadRetry => 'Upload failed. Tap to retry.';

  @override
  String uploading(int percent) {
    return 'Uploading $percent%';
  }

  @override
  String get featured => 'Featured';

  @override
  String get sourceConfirmed => 'Source confirmed';

  @override
  String get externalSource => 'External source';

  @override
  String get contactSupport => 'Contact support';

  @override
  String saveItem(String title) {
    return 'Save $title';
  }

  @override
  String unsaveItem(String title) {
    return 'Remove from saved: $title';
  }

  @override
  String likeAction(int count) {
    return 'Like, $count likes';
  }

  @override
  String unlikeAction(int count) {
    return 'Unlike, $count likes';
  }

  @override
  String repliesAction(int count) {
    return 'Replies, $count';
  }

  @override
  String get shareAction => 'Share';

  @override
  String get savePost => 'Save post';

  @override
  String get unsavePost => 'Unsave post';

  @override
  String get moreOptions => 'More options';

  @override
  String get improveSkill => 'Improve this skill';

  @override
  String get findOpportunities => 'Find opportunities';

  @override
  String get verifyAction => 'Verify';

  @override
  String get joinAction => 'Join';

  @override
  String get joinedAction => 'Joined';

  @override
  String get creativePassport => 'CREATIVE PASSPORT';

  @override
  String get unreadPrefix => 'Unread.';

  @override
  String get welcomeHeadline =>
      'One creative identity. Many connected possibilities.';

  @override
  String get welcomeCreateAccount => 'Create account';

  @override
  String get welcomeSignIn => 'Sign in';

  @override
  String get emailOrPhone => 'Email or phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signingOut => 'Signing out';

  @override
  String get splashCheckingTitle => 'Checking your session';

  @override
  String get splashOfflineTitle => 'Can\'t reach Atarah';

  @override
  String get splashOfflineBody =>
      'We couldn\'t check your session. Your saved content is still on this device.';

  @override
  String get profileMembershipFree => 'Free plan';

  @override
  String get profileMembershipPro => 'Atarah Pro';

  @override
  String get profileCreativePassport => 'Creative Passport';

  @override
  String get profileActivity => 'Activity';

  @override
  String get profileSettings => 'Settings';

  @override
  String get profileMembership => 'Membership';

  @override
  String get featureHome => 'Home';

  @override
  String get featureExplore => 'Explore';

  @override
  String get featureCommunity => 'Community';

  @override
  String get featureOpportunities => 'Opportunities';

  @override
  String get featureNotifications => 'Notifications';

  @override
  String get featureCreativeProfile => 'Creative profile';

  @override
  String get featureProject => 'Project';

  @override
  String get featureCourse => 'Course';

  @override
  String get featureLesson => 'Lesson';

  @override
  String get featureListing => 'Marketplace listing';

  @override
  String get featureMentor => 'Mentor';

  @override
  String get featureArticle => 'Article';

  @override
  String get featureGroup => 'Group';

  @override
  String get featurePost => 'Discussion';

  @override
  String get welcomeSubhead =>
      'Learn, connect, discover opportunities and grow your career — from one profile that works everywhere in Atarah.';

  @override
  String get pillarIdentity => 'Identity';

  @override
  String get pillarLearn => 'Learn';

  @override
  String get pillarConnect => 'Connect';

  @override
  String get pillarEarn => 'Earn';

  @override
  String get welcomeTerms => 'Terms';

  @override
  String get welcomePrivacy => 'Privacy';

  @override
  String get legalDraftBanner =>
      'This is a draft that has not been reviewed yet. It is not the final text.';

  @override
  String get legalUnavailable => 'We couldn\'t load this document.';

  @override
  String get legalTermsTitle => 'Terms of Service';

  @override
  String get legalPrivacyTitle => 'Privacy Policy';

  @override
  String get signupTitle => 'Create your account';

  @override
  String get signupSubtitle =>
      'Takes under a minute. You\'ll set up your creative profile next.';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameError => 'Enter your full name.';

  @override
  String get identifierError => 'Enter a valid email address or phone number.';

  @override
  String get identifierHintPhone =>
      'Phone numbers starting with 0 or 7 are treated as Kenyan (+254).';

  @override
  String get passwordRuleError =>
      'Use at least 8 characters, including a number.';

  @override
  String get consentPrefix => 'I agree to the ';

  @override
  String get consentAnd => ' and ';

  @override
  String get consentTermsLink => 'Terms of Service';

  @override
  String get consentPrivacyLink => 'Privacy Policy';

  @override
  String get consentRequired =>
      'You need to accept the Terms and Privacy Policy to continue.';

  @override
  String get signupAction => 'Continue';

  @override
  String get googleContinue => 'Continue with Google';

  @override
  String get alreadyMember => 'Already a member?';

  @override
  String get newToAtarah => 'New to Atarah?';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get signInInstead => 'Sign in instead';

  @override
  String get verifyTitleEmail => 'Verify your email';

  @override
  String get verifyTitlePhone => 'Verify your phone number';

  @override
  String get verifyBody => 'Enter the 6-digit code we sent to';

  @override
  String get verifyDidntGet => 'Didn\'t get it?';

  @override
  String verifyResendIn(String time) {
    return 'Resend in $time';
  }

  @override
  String get verifyResend => 'Resend code';

  @override
  String get verifyResent => 'New code sent.';

  @override
  String get verifyWhyLead => 'Why we verify:';

  @override
  String get verifyWhyBody =>
      ' it protects your creative identity and is needed before you message, apply or book.';

  @override
  String get verifyNextLead => 'What\'s next:';

  @override
  String get verifyNextBody =>
      ' four short steps to set up your creative profile.';

  @override
  String get verifyCodeLabel => 'Verification code';

  @override
  String get signInTitle => 'Welcome back';

  @override
  String get signInSubtitle => 'Sign in to continue your creative journey.';

  @override
  String get forgotPasswordLink => 'Forgot password?';

  @override
  String get signInLockedHint =>
      'You can also reset your password to sign in right away.';

  @override
  String get forgotTitle => 'Reset your password';

  @override
  String get forgotBody =>
      'Enter the email or phone on your account and we\'ll send a recovery code.';

  @override
  String get forgotSent => 'Code sent. It expires in 15 minutes.';

  @override
  String get forgotAction => 'Send code';

  @override
  String get resetTitle => 'Set a new password';

  @override
  String get resetBody => 'You\'ll be signed out of other devices.';

  @override
  String get recoveryCodeLabel => 'Recovery code';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get confirmPasswordLabel => 'Confirm new password';

  @override
  String get passwordsDontMatch => 'The passwords don\'t match.';

  @override
  String get resetAction => 'Reset password';

  @override
  String get resetDone =>
      'Password updated. You were signed out of your other devices.';

  @override
  String get onboardingPlaceholderName => 'Creative profile setup';

  @override
  String get codeIncomplete => 'Enter all 6 digits.';
}
