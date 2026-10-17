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
  String get codeIncomplete => 'Enter all 6 digits.';

  @override
  String get obSkip => 'Skip';

  @override
  String obStepOf(int n, int total) {
    return 'Step $n of $total';
  }

  @override
  String get obGettingStarted => 'Getting started';

  @override
  String get obProgressLabel => 'Setup progress';

  @override
  String get obGetStarted => 'Get started';

  @override
  String get obContinue => 'Continue';

  @override
  String get obFinish => 'Finish';

  @override
  String get obIntroTitle => 'Let\'s set up your creative identity';

  @override
  String get obIntroBody =>
      'Four short steps. Each one makes the opportunities, people and learning you see more relevant.';

  @override
  String get obIntroDisciplineTitle => 'Your discipline';

  @override
  String get obIntroDisciplineBody => 'What you create and your specialization';

  @override
  String get obIntroSkillsTitle => 'Skills & interests';

  @override
  String get obIntroSkillsBody => 'What you’re good at and want to grow';

  @override
  String get obIntroLocationTitle => 'Location';

  @override
  String get obIntroLocationBody =>
      'For local people, events and opportunities';

  @override
  String get obIntroBasicsTitle => 'Profile basics';

  @override
  String get obIntroBasicsBody => 'Your name, a short bio and a photo';

  @override
  String get obDisciplineTitle => 'What do you create?';

  @override
  String get obDisciplineBody =>
      'Your discipline helps us show you more relevant opportunities, people and learning.';

  @override
  String get obDisciplineRequired =>
      'Choose what you create, or skip this step.';

  @override
  String get obSpecTitle => 'Your specialization';

  @override
  String get obSpecBodyPrefix => 'Within ';

  @override
  String get obSpecBodySuffix => ' — pick any that describe your practice.';

  @override
  String get obSpecNeedDiscipline =>
      'Choose your discipline first, then come back to pick your specialization.';

  @override
  String get obSuggest => 'Suggest a specialization';

  @override
  String get obSuggestTitle => 'Suggest a specialization';

  @override
  String obSuggestBody(String discipline) {
    return 'Tell us what is missing from the $discipline list. We review every suggestion.';
  }

  @override
  String get obSuggestLabel => 'Specialization name';

  @override
  String get obSuggestSend => 'Send suggestion';

  @override
  String get obSuggestEmpty => 'Enter a name for the specialization.';

  @override
  String get obSuggestThanksTitle => 'Thanks, we\'ll take a look';

  @override
  String obSuggestThanksBody(String name) {
    return 'We\'ll tell you when “$name” is added or merged. You can carry on meanwhile.';
  }

  @override
  String get obSuggestDone => 'Done';

  @override
  String get obSkillsTitle => 'Skills & interests';

  @override
  String get obSkillsBody =>
      'These power your learning recommendations, discovery and opportunity matches.';

  @override
  String get obGroupSkills => 'Skills';

  @override
  String get obGroupInterests => 'Interests';

  @override
  String get obGroupGrow => 'Areas to develop';

  @override
  String obSelectedCount(int count) {
    return '$count selected';
  }

  @override
  String obLimitReached(int max) {
    return 'You can pick up to $max.';
  }

  @override
  String get obLocTitle => 'Where are you based?';

  @override
  String get obLocBody =>
      'For local discovery, regional opportunities and your county\'s creative community.';

  @override
  String get obCountry => 'Country';

  @override
  String get obCounty => 'County';

  @override
  String get obTown => 'Town or neighbourhood (optional)';

  @override
  String get obSelectPlaceholder => 'Select';

  @override
  String get obUseLocation => 'Use my current location';

  @override
  String get obLocating => 'Finding your county…';

  @override
  String obLocationFound(String county) {
    return 'We set your county to $county.';
  }

  @override
  String get obLocationNoMatch =>
      'We couldn\'t match your location to a county. Choose it from the list.';

  @override
  String get obLocationDenied =>
      'Location permission is off. Choose your county from the list.';

  @override
  String get obLocationDeniedForever =>
      'Location is blocked for Atarah in your phone settings. Choose your county from the list.';

  @override
  String get obLocationServicesOff =>
      'Location is switched off on this phone. Choose your county from the list.';

  @override
  String get obLocationFailed =>
      'We couldn\'t get your location. Choose your county from the list.';

  @override
  String get obCountyRequired => 'Choose your county, or skip this step.';

  @override
  String get obChooseCounty => 'Choose a county';

  @override
  String get obChooseCountry => 'Choose a country';

  @override
  String get obSearch => 'Search';

  @override
  String get obNoResults => 'Nothing matches that.';

  @override
  String get obWhoSees => 'Who can see your location?';

  @override
  String get obVisPublic => 'Public';

  @override
  String get obVisMembers => 'Members';

  @override
  String get obVisPrivate => 'Private';

  @override
  String get obVisPublicNote =>
      'Anyone, including people outside Atarah, can see your county.';

  @override
  String get obVisMembersNote =>
      'Only signed-in Atarah members can see your county.';

  @override
  String get obVisPrivateNote =>
      'Hidden from everyone. Still used to personalise what you see.';

  @override
  String get obBasicsTitle => 'Introduce yourself';

  @override
  String get obBasicsBody =>
      'A name and a line or two — you can expand this into your Creative Passport later.';

  @override
  String get obDisplayName => 'Display name';

  @override
  String get obDisplayNameError => 'Enter the name you want people to see.';

  @override
  String get obProfileLink => 'Profile link';

  @override
  String get obHandleChecking => 'Checking…';

  @override
  String obHandleAvailable(String handle) {
    return '$handle is available.';
  }

  @override
  String get obHandleTaken => 'That profile link is taken.';

  @override
  String get obHandleReserved => 'That link is reserved. Try another.';

  @override
  String get obHandleInvalid => 'Use 3 to 30 letters, numbers or underscores.';

  @override
  String get obHandleTry => 'Try one of these';

  @override
  String get obHandleRequired => 'Choose your profile link.';

  @override
  String get obShortBio => 'Short bio';

  @override
  String get obHelpWrite => 'Help me write this';

  @override
  String obBioCount(int count) {
    return '$count / 160';
  }

  @override
  String get obPhotoTitle => 'Add a profile photo';

  @override
  String get obPhotoBody =>
      'Profiles with a clear photo get more connection requests and mentor replies.';

  @override
  String get obGallery => 'Gallery';

  @override
  String get obTakePhoto => 'Take photo';

  @override
  String get obPhotoSkip => 'Skip for now';

  @override
  String get obPhotoUploading => 'Uploading your photo…';

  @override
  String get obPhotoAdded => 'Photo added.';

  @override
  String get obPhotoRemove => 'Remove photo';

  @override
  String get obPhotoPreview => 'Profile photo preview';

  @override
  String get obPhotoPickFailed => 'We couldn\'t open that photo. Try another.';

  @override
  String get obCropTitle => 'Crop your photo';

  @override
  String get obCropUse => 'Use photo';

  @override
  String get obCropCancel => 'Cancel';

  @override
  String get obDoneTitle => 'Your creative journey starts here.';

  @override
  String get obDoneBody =>
      'Your Creative Passport is live. Complete it at your own pace — Atarah gets more useful as it grows.';

  @override
  String get obPassportLabel => 'CREATIVE PASSPORT';

  @override
  String get obSpecNotSet => 'Specialization not set';

  @override
  String get obLocationNotSet => 'Location not set';

  @override
  String get obCompletion => 'Profile completion';

  @override
  String get obGoHome => 'Go to Home';

  @override
  String get obLoadFailedTitle => 'We couldn\'t load your setup';

  @override
  String get obHandleSuggestionsLabel => 'Available alternatives';
}
