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

  @override
  String get pfPublicView => 'Public view';

  @override
  String get pfEditProfile => 'Edit profile';

  @override
  String get pfImproveBio => 'Improve my bio';

  @override
  String get pfAddHeadline => 'Add a headline';

  @override
  String get pfLocationNotSet => 'Location not set';

  @override
  String get pfLoadFailed => 'We couldn\'t load your profile';

  @override
  String get pfPassportCardTitle => 'Creative Passport';

  @override
  String get pfNextBestAction => 'Next best step';

  @override
  String pfCompletionPercent(int percent) {
    return '$percent% complete';
  }

  @override
  String get pfAllDone => 'Your profile is complete. Nice work.';

  @override
  String get pfYourTools => 'Your tools';

  @override
  String get pfMentorTools => 'Mentor tools';

  @override
  String get pfSellerTools => 'Seller tools';

  @override
  String get pfMyIdentity => 'My creative identity';

  @override
  String get pfPortfolio => 'Portfolio';

  @override
  String get pfSkills => 'Skills';

  @override
  String get pfExperience => 'Experience';

  @override
  String get pfAchievements => 'Achievements';

  @override
  String get pfServices => 'Services';

  @override
  String get pfConnections => 'Connections';

  @override
  String get pfSaved => 'Saved';

  @override
  String pfCount(int count) {
    return '$count';
  }

  @override
  String pfPendingRequests(int count) {
    return '$count waiting';
  }

  @override
  String get epTitle => 'Edit profile';

  @override
  String get epDisplayName => 'Display name';

  @override
  String get epHeadline => 'Headline';

  @override
  String get epHeadlineHint => 'For example: Character animator in Nairobi';

  @override
  String get epBio => 'Short bio';

  @override
  String get epLinks => 'Links';

  @override
  String get epLinkLabel => 'Label';

  @override
  String get epLinkUrl => 'Address (https://)';

  @override
  String get epAddLink => 'Add a link';

  @override
  String get epRemoveLink => 'Remove link';

  @override
  String epLinksLimit(int max) {
    return 'You can add up to $max links.';
  }

  @override
  String get epLinkInvalid => 'Enter a web address that starts with https://';

  @override
  String get epLinkLabelMissing => 'Give the link a label.';

  @override
  String get epContactPrefs => 'Contact and availability';

  @override
  String get epOpenToCommissions => 'Open to commissions';

  @override
  String get epShowEmail => 'Show my email when my contact details are visible';

  @override
  String get epShowPhone =>
      'Show my phone number when my contact details are visible';

  @override
  String get epContactForConnections =>
      'My connections can see my contact details';

  @override
  String get epAcceptConnections => 'Accept connection requests';

  @override
  String get epSave => 'Save changes';

  @override
  String get epSaved => 'Profile updated.';

  @override
  String get epNameError => 'Enter the name you want people to see.';

  @override
  String get ppTitle => 'Creative Passport';

  @override
  String ppMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get ppGrowth => 'Growth';

  @override
  String get ppStrengthEarly => 'Early';

  @override
  String get ppStrengthGrowing => 'Growing';

  @override
  String get ppStrengthActive => 'Active';

  @override
  String get ppStrengthStrong => 'Strong';

  @override
  String get ppGrowthIdentity => 'Identity';

  @override
  String get ppGrowthPortfolio => 'Portfolio';

  @override
  String get ppGrowthSkills => 'Skills';

  @override
  String get ppGrowthLearning => 'Learning';

  @override
  String get ppGrowthConnections => 'Connections';

  @override
  String get ppGrowthProfessionalisation => 'Professionalisation';

  @override
  String get ppSections => 'Sections & visibility';

  @override
  String get ppSectionsBody =>
      'Choose who can see each part of your profile. Changes apply straight away.';

  @override
  String get ppCopyLink => 'Copy link';

  @override
  String get ppLinkCopied => 'Link copied.';

  @override
  String get ppCreateCv => 'Create CV / EPK';

  @override
  String get ppVisibilityFailed => 'We couldn\'t change that. Try again.';

  @override
  String ppChooseAudience(String section) {
    return 'Who can see $section?';
  }

  @override
  String get vsPublic => 'Public';

  @override
  String get vsMembers => 'Members only';

  @override
  String get vsPrivate => 'Only me';

  @override
  String get vsPublicNote => 'Anyone, including people outside Atarah.';

  @override
  String get vsMembersNote => 'Signed-in Atarah members.';

  @override
  String get vsPrivateNote =>
      'Only you (and connections, for contact details, if you allow it).';

  @override
  String get secBio => 'Bio';

  @override
  String get secLocation => 'Location';

  @override
  String get secPortfolio => 'Portfolio';

  @override
  String get secSkills => 'Skills';

  @override
  String get secExperience => 'Experience';

  @override
  String get secServices => 'Services';

  @override
  String get secLinks => 'Links';

  @override
  String get secContact => 'Contact details';

  @override
  String get cpAbout => 'About';

  @override
  String get cpPortfolio => 'Portfolio';

  @override
  String get cpServices => 'Services';

  @override
  String get cpShare => 'Share profile';

  @override
  String cpShareText(String name) {
    return '$name on Atarah';
  }

  @override
  String get cpOpenToCommissions => 'Open to commissions';

  @override
  String get cpConnect => 'Connect';

  @override
  String get cpMessage => 'Message';

  @override
  String get cpRequestSent => 'Request sent';

  @override
  String get cpCancelRequest => 'Cancel request';

  @override
  String get cpAccept => 'Accept';

  @override
  String get cpDecline => 'Decline';

  @override
  String get cpConnected => 'Connected';

  @override
  String get cpRemoveConnection => 'Remove connection';

  @override
  String get cpRemoveConfirmTitle => 'Remove this connection?';

  @override
  String get cpRemoveConfirmBody =>
      'You\'ll stop being connected. You can send a new request later.';

  @override
  String get cpNotAccepting => 'Not accepting requests';

  @override
  String get cpAskLater => 'You can ask again later';

  @override
  String cpConnectionsCount(int count) {
    return '$count connections';
  }

  @override
  String get cpPreviewBanner => 'This is how your profile looks to others.';

  @override
  String get cpPreviewPublic => 'Public';

  @override
  String get cpPreviewMembers => 'Members';

  @override
  String get cpBioLocked => 'The bio is not shared with you.';

  @override
  String cpHidden(String section) {
    return '$section is hidden.';
  }

  @override
  String get cpSkillsHeading => 'Skills';

  @override
  String get cpSpecialisationsHeading => 'Specialisations';

  @override
  String get cpLinksHeading => 'Links';

  @override
  String get cpContactHeading => 'Contact';

  @override
  String get cpNoBio => 'No bio yet.';

  @override
  String get cpNoPortfolio => 'No projects yet.';

  @override
  String get cpNoServices => 'No services yet.';

  @override
  String get cpNotFoundTitle => 'We couldn\'t find that creative';

  @override
  String get cpActionFailed => 'That didn\'t work. Try again.';

  @override
  String cpMemberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get save => 'Save';

  @override
  String get skAddTitle => 'Add a skill';

  @override
  String get skEmptyTitle => 'No skills yet';

  @override
  String get skEmptyBody =>
      'List what you do well so people can find you and see what you can offer.';

  @override
  String get skLevelLabel => 'Level';

  @override
  String get skLevelBeginner => 'Beginner';

  @override
  String get skLevelIntermediate => 'Intermediate';

  @override
  String get skLevelAdvanced => 'Advanced';

  @override
  String get skLevelExpert => 'Expert';

  @override
  String get skLevelUnrated => 'Not rated';

  @override
  String get skSourceSelf => 'Self-declared';

  @override
  String get skSourceLearning => 'From learning';

  @override
  String get skSourceVerified => 'Verified';

  @override
  String skUsedIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Used in $count projects',
      one: 'Used in 1 project',
      zero: 'Not used in a project yet',
    );
    return '$_temp0';
  }

  @override
  String get skImprove => 'Improve this skill';

  @override
  String get skFindOpportunities => 'Find opportunities';

  @override
  String get skVerify => 'Verify';

  @override
  String get skChangeLevel => 'Change level';

  @override
  String get skSearchLabel => 'Search skills';

  @override
  String get skNoMatches => 'No skills match. Try a different word.';

  @override
  String get skRemove => 'Remove skill';

  @override
  String skRemoveTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get skRemoveBody =>
      'It leaves your profile. Projects that used it keep their own list.';

  @override
  String get xpAddTitle => 'Add experience';

  @override
  String get xpEditTitle => 'Edit experience';

  @override
  String get xpEmptyTitle => 'No experience yet';

  @override
  String get xpEmptyBody =>
      'Add the studios, clients and roles that shaped your work.';

  @override
  String get xpPresent => 'Present';

  @override
  String get xpTitleLabel => 'Role';

  @override
  String get xpOrgLabel => 'Where';

  @override
  String get xpOrgHint => 'Company, studio, school or Freelance';

  @override
  String get xpLocationLabel => 'Location (optional)';

  @override
  String get xpStartLabel => 'Started';

  @override
  String get xpEndLabel => 'Ended';

  @override
  String get xpCurrentLabel => 'I work here now';

  @override
  String get xpDescriptionLabel => 'What you did (optional)';

  @override
  String get xpTitleError => 'Enter your role.';

  @override
  String get xpOrgError => 'Enter where you worked.';

  @override
  String get xpStartError => 'Choose when you started.';

  @override
  String get xpEndRequired =>
      'Choose when you left, or switch on “I work here now”.';

  @override
  String get xpEndBeforeStart =>
      'The end date cannot be before the start date.';

  @override
  String get xpDelete => 'Delete experience';

  @override
  String get xpDeleteTitle => 'Delete this experience?';

  @override
  String get xpDeleteBody => 'It is removed from your profile.';

  @override
  String get acAddTitle => 'Add achievement';

  @override
  String get acEditTitle => 'Edit achievement';

  @override
  String get acEmptyTitle => 'No achievements yet';

  @override
  String get acEmptyBody =>
      'Awards, certificates, features and selections build trust in your work.';

  @override
  String get acTypeLabel => 'Type';

  @override
  String get acTypeAward => 'Award';

  @override
  String get acTypeCertificate => 'Certificate';

  @override
  String get acTypeFeature => 'Feature';

  @override
  String get acTypeSelection => 'Selection';

  @override
  String get acTypeNomination => 'Nomination';

  @override
  String get acTitleLabel => 'Title';

  @override
  String get acIssuerLabel => 'Given by (optional)';

  @override
  String get acDateLabel => 'Date (optional)';

  @override
  String get acUrlLabel => 'Link (optional)';

  @override
  String get acDescriptionLabel => 'Details (optional)';

  @override
  String get acTitleError => 'Enter a title.';

  @override
  String get acUrlError => 'Links must start with https://';

  @override
  String get acByAtarah => 'Added by Atarah';

  @override
  String get acDelete => 'Delete achievement';

  @override
  String get acDeleteTitle => 'Delete this achievement?';

  @override
  String get acDeleteBody => 'It is removed from your profile.';

  @override
  String get svAddTitle => 'Add a service';

  @override
  String get svEditTitle => 'Edit service';

  @override
  String get svEmptyTitle => 'No services yet';

  @override
  String get svEmptyBody =>
      'Tell people what you can do for them and roughly what it costs.';

  @override
  String get svTitleLabel => 'Service';

  @override
  String get svDescriptionLabel => 'What is included (optional)';

  @override
  String get svPriceTypeLabel => 'Price';

  @override
  String get svTypeFixed => 'Fixed';

  @override
  String get svTypeRange => 'Range';

  @override
  String get svTypeOnRequest => 'On request';

  @override
  String get svPriceLabel => 'Price';

  @override
  String get svMinLabel => 'From';

  @override
  String get svMaxLabel => 'To';

  @override
  String get svTitleError => 'Enter the name of the service.';

  @override
  String get svPriceError => 'Enter a price in Kenya shillings.';

  @override
  String get svMaxError => 'The highest price must be at least the lowest.';

  @override
  String svPriceFixed(String amount) {
    return 'KES $amount';
  }

  @override
  String svPriceRange(String min, String max) {
    return 'KES $min to $max';
  }

  @override
  String get svPriceOnRequest => 'Price on request';

  @override
  String get svProfileOnly => 'Profile only';

  @override
  String get svOnMarketplace => 'On the marketplace';

  @override
  String get svPublish => 'Publish to marketplace';

  @override
  String get svViewListing => 'View listing';

  @override
  String get svEdit => 'Edit';

  @override
  String get svDelete => 'Delete service';

  @override
  String get svDeleteTitle => 'Delete this service?';

  @override
  String get svDeleteBody => 'It is removed from your profile.';

  @override
  String get pjAdd => 'Add project';

  @override
  String get pjAddTitle => 'Add a project';

  @override
  String get pjEditTitle => 'Edit project';

  @override
  String get pjAddZone => 'Add project';

  @override
  String get pjAll => 'All';

  @override
  String get pjFeatured => 'Featured';

  @override
  String get pjCatProjects => 'Projects';

  @override
  String get pjCatMediaPlural => 'Media';

  @override
  String get pjCatPublications => 'Publications';

  @override
  String get pjCatPerformances => 'Performances';

  @override
  String get pjCatProject => 'Project';

  @override
  String get pjCatMedia => 'Media';

  @override
  String get pjCatPublication => 'Publication';

  @override
  String get pjCatPerformance => 'Performance';

  @override
  String get pjEmptyBody =>
      'Show your best work. Add a project to start your portfolio.';

  @override
  String get pjNothingInFilter => 'Nothing here yet.';

  @override
  String get pjDrafts => 'Drafts';

  @override
  String get pjDraft => 'Draft';

  @override
  String get pjHidden => 'Hidden';

  @override
  String get pjUntitled => 'Untitled project';

  @override
  String pjInviteTitle(String owner, String project) {
    return '$owner tagged you on “$project”';
  }

  @override
  String pjInviteRole(String role) {
    return 'As $role';
  }

  @override
  String get pjInviteAccept => 'Accept';

  @override
  String get pjInviteDecline => 'Decline';

  @override
  String get pjIntro =>
      'Tell the story of your work. Your changes are saved as a draft while you type, and nobody sees it until you publish.';

  @override
  String get pjSaved => 'Draft saved';

  @override
  String get pjSaving => 'Saving…';

  @override
  String get pjSaveFailed =>
      'Could not save yet. Check your connection; we will try again as you type.';

  @override
  String get pjSaveFirst => 'Save the project first, then add collaborators.';

  @override
  String get pjFilesHeading => 'Files';

  @override
  String get pjAddFiles => 'Add files';

  @override
  String pjFilesHint(int max) {
    return 'Photos, video or audio. Up to $max files.';
  }

  @override
  String get pjFileAlt => 'Project file';

  @override
  String get pjPickPhotos => 'Photos';

  @override
  String get pjPickVideo => 'Video';

  @override
  String get pjPickAudio => 'Audio';

  @override
  String get pjPickFailed => 'We could not open your files. Try again.';

  @override
  String get pjTitleLabel => 'Title';

  @override
  String get pjRoleLabel => 'Your role';

  @override
  String get pjClientLabel => 'Client (optional)';

  @override
  String get pjDateLabel => 'Date of the work';

  @override
  String get pjDateNotSet => 'Not set';

  @override
  String get pjDateClear => 'Clear date';

  @override
  String get pjCategoryHeading => 'Type of work';

  @override
  String get pjDescriptionLabel => 'Description';

  @override
  String get pjHelpDescribe => 'Help me describe this';

  @override
  String get pjOutcomeLabel => 'Outcome (optional)';

  @override
  String get pjOutcomeHint => 'What did the work achieve?';

  @override
  String get pjSkillsHeading => 'Skills used';

  @override
  String get pjAddSkill => 'Add a skill';

  @override
  String pjRemoveNamed(String name) {
    return 'Remove $name';
  }

  @override
  String get pjCollaborators => 'Collaborators';

  @override
  String get pjAddCollaborator => 'Add a collaborator';

  @override
  String get pjCollabMember => 'Atarah member';

  @override
  String get pjCollabName => 'Someone else';

  @override
  String get pjCollabRole => 'Their role (optional)';

  @override
  String get pjCollabSearch => 'Search by name or @handle';

  @override
  String get pjCollabNoMembers => 'No members found.';

  @override
  String get pjCollabNameLabel => 'Their name';

  @override
  String get pjCollabAddName => 'Add';

  @override
  String get pjCollabNameError => 'Enter their name.';

  @override
  String get pjCollabPending => 'Waiting to accept';

  @override
  String get pjLinks => 'Links';

  @override
  String get pjAddLink => 'Add a link';

  @override
  String get pjLinkLabel => 'Label';

  @override
  String get pjLinkUrl => 'Address';

  @override
  String get pjLinkError => 'Enter an address starting with https://';

  @override
  String get pjRemoveLink => 'Remove link';

  @override
  String get pjVisibilityHeading => 'Who can see it';

  @override
  String get pjVisibilityNote =>
      'Your Portfolio setting in the Creative Passport also applies.';

  @override
  String get pjFeaturedToggle => 'Feature this project (up to 3)';

  @override
  String get pjPublish => 'Publish';

  @override
  String get pjSaveChanges => 'Save changes';

  @override
  String get pjSaveDraft => 'Save draft';

  @override
  String get pjPreview => 'Preview project';

  @override
  String get pjDelete => 'Delete project';

  @override
  String get pjDeleteTitle => 'Delete this project?';

  @override
  String get pjDeleteBody => 'It is removed from your portfolio and profile.';

  @override
  String get pjTitleError => 'Give your project a title.';

  @override
  String get pjShare => 'Share project';

  @override
  String get pjEdit => 'Edit project';

  @override
  String pjShareText(String title) {
    return '$title on Atarah';
  }

  @override
  String get pjNotFound => 'This project is not available';

  @override
  String pjHiddenNotice(String reason) {
    return 'A moderator hid this project: $reason';
  }

  @override
  String get pjDraftNotice => 'This is a draft. Only you can see it.';

  @override
  String get pjSkillsUsed => 'Skills used';

  @override
  String get pjOutcome => 'Outcome';

  @override
  String get pjMediaProcessing => 'This file is still being prepared.';

  @override
  String get pjMediaFailed => 'We could not play this file.';

  @override
  String get pjImageAlt => 'Project image';

  @override
  String get pjPlay => 'Play';

  @override
  String get pjPause => 'Pause';

  @override
  String get leavingOpenFailed => 'We couldn\'t open that link.';
}
