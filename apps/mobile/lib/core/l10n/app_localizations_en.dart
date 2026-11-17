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
  String get grpYourGroups => 'Your groups';

  @override
  String get grpYourGroupsEmpty =>
      'You haven\'t joined a group yet. Find one below.';

  @override
  String get grpDiscover => 'Discover groups';

  @override
  String get grpSearchHint => 'Search groups';

  @override
  String get grpSearchClear => 'Clear search';

  @override
  String get grpFilterAll => 'All';

  @override
  String get grpTypeDiscipline => 'Discipline';

  @override
  String get grpTypeLocation => 'Location';

  @override
  String get grpTypeInterest => 'Interest';

  @override
  String get grpTypeProgramme => 'Programme';

  @override
  String grpMembers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get grpDiscoverEmpty => 'No groups to show';

  @override
  String get grpDiscoverEmptyBody =>
      'Try another type or search, or check back soon.';

  @override
  String get grpLoadMore => 'Show more groups';

  @override
  String grpLeaveTitle(String name) {
    return 'Leave $name?';
  }

  @override
  String get grpLeaveBody =>
      'You\'ll stop seeing its discussions. You can join again any time.';

  @override
  String get grpLeaveConfirm => 'Leave group';

  @override
  String get grpStay => 'Stay';

  @override
  String grpJoinedToast(String name) {
    return 'You joined $name';
  }

  @override
  String grpLeftToast(String name) {
    return 'You left $name';
  }

  @override
  String get grpOwnerCantLeave =>
      'You own this group, so you can\'t leave it. Ask the Atarah team to hand it over first.';

  @override
  String get grpErrRestricted =>
      'Your account is restricted right now, so you can\'t join or post in groups.';

  @override
  String get grpErrVerify =>
      'Verify your email or phone number to join groups and post in them.';

  @override
  String get grpErrRate =>
      'You\'re doing that a lot. Give it a moment and try again.';

  @override
  String get grpErrPrivate =>
      'This group is private. Members are added by invitation.';

  @override
  String get grpJoinGroup => 'Join group';

  @override
  String get grpShare => 'Share group';

  @override
  String grpShareText(String name) {
    return 'Join $name on Atarah';
  }

  @override
  String get grpTypePrivate => 'Private';

  @override
  String get grpOfficial => 'Official';

  @override
  String get grpPinned => 'Pinned announcement';

  @override
  String get grpRecent => 'Recent discussions';

  @override
  String get grpNoDiscussions => 'No discussions yet';

  @override
  String get grpNoDiscussionsBody => 'Be the first to start one.';

  @override
  String get grpStartDiscussion => 'Start a discussion';

  @override
  String get grpJoinToPost => 'Join this group to post';

  @override
  String get grpPrivateNote =>
      'Private group. Members are added by invitation.';

  @override
  String get grpGone => 'This group isn\'t available';

  @override
  String get grpGoneBody => 'It may be private, archived or no longer exist.';

  @override
  String get grpPostsFailed => 'We couldn\'t load the discussions';

  @override
  String get grpMoreDiscussions => 'Show more discussions';

  @override
  String grpReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
    );
    return '$_temp0';
  }

  @override
  String grpMeta(String type, String members) {
    return '$type · $members';
  }

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
  String get cfdTitle => 'Community';

  @override
  String get cfdSubtitle => 'Ask, share and build with Kenya\'s creatives.';

  @override
  String get cfdNewPost => 'New post';

  @override
  String get cfdTabFeed => 'Feed';

  @override
  String get cfdTabDiscussions => 'Discussions';

  @override
  String get cfdTabGroups => 'Groups';

  @override
  String get cfdTabPeople => 'People';

  @override
  String get cfdComposerPrompt => 'Share an update or ask a question…';

  @override
  String get cfdFeedEmpty => 'Nothing here yet';

  @override
  String get cfdFeedEmptyBody =>
      'Be the first to share an update or ask a question.';

  @override
  String get cfdDiscussionsEmpty => 'No discussions yet';

  @override
  String get cfdDiscussionsEmptyBody =>
      'Start one and ask the community what they think.';

  @override
  String get cfdWritePost => 'Write a post';

  @override
  String get cfdFeedFailed => 'We couldn\'t load the feed';

  @override
  String get cfdOfflineTitle => 'You\'re offline';

  @override
  String get cfdOfflineBody => 'Reconnect to see the latest posts.';

  @override
  String get cfdLoadMoreFailed => 'We couldn\'t load more posts.';

  @override
  String get cfdTypeUpdate => 'Creative update';

  @override
  String get cfdTypeQuestion => 'Question';

  @override
  String get cfdTypeDiscussion => 'Discussion';

  @override
  String get cfdTypeCollaboration => 'Collaboration';

  @override
  String get cfdTypeAnnouncement => 'Announcement';

  @override
  String get cfdChipUpdate => 'Update';

  @override
  String get cfdAuthorTeam => 'Atarah Team';

  @override
  String get cfdNow => 'now';

  @override
  String cfdMinutes(int n) {
    return '${n}m';
  }

  @override
  String cfdHours(int n) {
    return '${n}h';
  }

  @override
  String cfdDays(int n) {
    return '${n}d';
  }

  @override
  String get cfdEdited => 'edited';

  @override
  String cfdShareText(String name, String excerpt, String url) {
    return '$name on Atarah: $excerpt\n$url';
  }

  @override
  String cfdOpenLink(String title) {
    return 'Open link: $title';
  }

  @override
  String get cfdVideo => 'Video';

  @override
  String cfdPhotoOf(String name) {
    return 'Photo by $name';
  }

  @override
  String get cfdSavedPost => 'Saved to your saved items.';

  @override
  String get cfdUnsavedPost => 'Removed from your saved items.';

  @override
  String cfdReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
      zero: 'No replies yet',
    );
    return '$_temp0';
  }

  @override
  String get cfdReplyHint => 'Write a reply…';

  @override
  String cfdReplyingTo(String name) {
    return 'Replying to $name';
  }

  @override
  String get cfdCancelReply => 'Cancel reply';

  @override
  String get cfdSendReply => 'Send reply';

  @override
  String get cfdReply => 'Reply';

  @override
  String get cfdNoReplies => 'No replies yet';

  @override
  String get cfdNoRepliesBody => 'Be the first to reply.';

  @override
  String get cfdMoreReplies => 'Show more replies';

  @override
  String get cfdMenuSave => 'Save discussion';

  @override
  String get cfdMenuUnsave => 'Remove from saved';

  @override
  String get cfdMenuMute => 'Mute thread';

  @override
  String get cfdMenuUnmute => 'Unmute thread';

  @override
  String get cfdMenuBlock => 'Block author';

  @override
  String get cfdMenuReport => 'Report';

  @override
  String get cfdMenuEdit => 'Edit';

  @override
  String get cfdMenuDelete => 'Delete';

  @override
  String get cfdMuted => 'Thread muted. You won\'t be notified about it.';

  @override
  String get cfdUnmuted => 'Thread unmuted.';

  @override
  String get cfdEditPostTitle => 'Edit post';

  @override
  String get cfdEditReplyTitle => 'Edit reply';

  @override
  String get cfdSaveChanges => 'Save changes';

  @override
  String get cfdCancel => 'Cancel';

  @override
  String get cfdDone => 'Done';

  @override
  String get cfdDeletePostTitle => 'Delete this post?';

  @override
  String get cfdDeletePostBody =>
      'It will be removed for everyone, including the replies. This can\'t be undone.';

  @override
  String get cfdDeleteReplyTitle => 'Delete this reply?';

  @override
  String get cfdDeleteReplyBody =>
      'It will be removed for everyone. This can\'t be undone.';

  @override
  String get cfdDelete => 'Delete';

  @override
  String get cfdPostGone => 'This post isn\'t available';

  @override
  String get cfdPostGoneBody =>
      'It may have been removed, or you can no longer see it.';

  @override
  String get cfdReportTitle => 'Report';

  @override
  String get cfdReportIntro =>
      'Why are you reporting this? The person won\'t be told it was you.';

  @override
  String get cfdReasonInappropriate => 'Inappropriate or offensive';

  @override
  String get cfdReasonHarassment => 'Harassment or bullying';

  @override
  String get cfdReasonScam => 'Scam or spam';

  @override
  String get cfdReasonMisleading => 'Misleading or false';

  @override
  String get cfdReasonImpersonation => 'Pretending to be someone else';

  @override
  String get cfdReasonIp => 'Copied or stolen work';

  @override
  String get cfdReasonOther => 'Something else';

  @override
  String get cfdReportNoteLabel => 'Add a note (optional)';

  @override
  String get cfdReportNoteHint => 'Tell us what we should look at';

  @override
  String get cfdReportSubmit => 'Send report';

  @override
  String get cfdReportDoneTitle => 'Thanks for telling us';

  @override
  String get cfdReportDoneBody =>
      'Our team will review this report. When a decision is made you\'ll get a notification with the outcome. We don\'t share details about other members, and the person won\'t know it was you.';

  @override
  String cfdBlockTitle(String name) {
    return 'Block $name?';
  }

  @override
  String get cfdBlockBody =>
      'You won\'t see each other\'s posts, replies or profiles, and neither of you can connect with or reply to the other. They won\'t be told.';

  @override
  String get cfdBlockConfirm => 'Block';

  @override
  String cfdBlockedTitle(String name) {
    return '$name is blocked';
  }

  @override
  String get cfdBlockedBody =>
      'Their posts and replies are now hidden from you.';

  @override
  String get cfdUndoBlock => 'Undo block';

  @override
  String cfdUnblocked(String name) {
    return '$name is unblocked.';
  }

  @override
  String get cfdComposeTitle => 'New post';

  @override
  String get cfdPost => 'Post';

  @override
  String get cfdBodyHint => 'What would you like to share?';

  @override
  String cfdCharCount(int count, int max) {
    return '$count/$max';
  }

  @override
  String get cfdDraftSaved => 'Draft saved automatically';

  @override
  String get cfdAttachPhoto => 'Photo';

  @override
  String get cfdAttachVideo => 'Video';

  @override
  String get cfdAttachLink => 'Link';

  @override
  String get cfdAttachOpportunity => 'Opportunity';

  @override
  String get cfdAudience => 'Audience';

  @override
  String get cfdAudMembers => 'Atarah members';

  @override
  String get cfdAudMembersBody => 'Everyone signed in to Atarah';

  @override
  String get cfdAudPublic => 'Public';

  @override
  String get cfdAudPublicBody => 'Anyone, including people outside Atarah';

  @override
  String get cfdAudConnections => 'Connections';

  @override
  String get cfdAudConnectionsBody => 'Only people you\'re connected with';

  @override
  String get cfdAudGroups => 'Your groups';

  @override
  String get cfdAudGroupBody => 'Members of this group';

  @override
  String get cfdAudGroupsFailed => 'We couldn\'t load your groups.';

  @override
  String get cfdLinkTitle => 'Add a link';

  @override
  String get cfdLinkHint => 'https://';

  @override
  String get cfdLinkInvalid =>
      'Enter a full web address that starts with http:// or https://';

  @override
  String get cfdLinkNote =>
      'A preview appears on the post a moment after you share it.';

  @override
  String get cfdLinkAdd => 'Add link';

  @override
  String get cfdLinkRemove => 'Remove link';

  @override
  String get cfdMediaFull => 'A post can have up to 10 photos or videos.';

  @override
  String get cfdPickFailed => 'We couldn\'t open your files. Try again.';

  @override
  String get cfdNeedsContent =>
      'Write something, or add a photo, video or link.';

  @override
  String cfdTooLong(int max) {
    return 'Posts can be up to $max characters.';
  }

  @override
  String get cfdUploadsPending =>
      'Wait for your files to finish uploading, or remove them.';

  @override
  String get cfdPostedToast => 'Posted.';

  @override
  String get cfdErrVerification =>
      'Verify your email or phone number first, then try again.';

  @override
  String get cfdErrRestricted =>
      'Your account is restricted right now, so you can\'t do this. If you think that\'s a mistake, contact support.';

  @override
  String get cfdErrNotMember => 'Join this group first, then try again.';

  @override
  String get cfdErrNotFound => 'This isn\'t available any more.';

  @override
  String get cfdErrRateLimited =>
      'You\'re going a little fast. Please wait a while and try again.';

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
      'Use at least 8 characters, including a letter and a number.';

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
  String get forgotSent => 'Code sent. It expires in 10 minutes.';

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

  @override
  String dcWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get dcWelcomeBody =>
      'Your creative journey matters. Let\'s build what\'s next.';

  @override
  String get dcNotifications => 'Notifications';

  @override
  String dcNotificationsUnread(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Notifications, $count unread',
      one: 'Notifications, 1 unread',
    );
    return '$_temp0';
  }

  @override
  String get dcYourProfile => 'Your profile';

  @override
  String get dcCompletion => 'Profile completion';

  @override
  String get dcCompletionBody =>
      'Complete your profile to unlock more opportunities and get better recommendations.';

  @override
  String dcCompletionLabel(int percent) {
    return 'Profile completion, $percent percent';
  }

  @override
  String get dcViewProfile => 'View profile';

  @override
  String get dcQuickAccess => 'Quick Access';

  @override
  String get dcSkillLabs => 'Skill Labs';

  @override
  String get dcSkillLabsBody => 'Short courses for working creatives';

  @override
  String get dcPortfolio => 'Portfolio';

  @override
  String get dcPassport => 'Passport';

  @override
  String get dcRecommended => 'Recommended for you';

  @override
  String get dcCreativesToMeet => 'Creatives to meet';

  @override
  String get dcMarketplace => 'Marketplace';

  @override
  String get dcMarketplaceBody => 'Hire creatives or sell your services';

  @override
  String get dcMentorship => 'Mentorship';

  @override
  String get dcMentorshipBody => 'Book time with industry mentors';

  @override
  String get dcGrowCareer => 'Grow your creative career';

  @override
  String get dcOpen => 'Open';

  @override
  String get dcLoadFailed => 'We couldn\'t load this';

  @override
  String get dcExploreTitle => 'Explore creatives';

  @override
  String get dcExploreBody =>
      'Discover amazing talent, connect and be inspired.';

  @override
  String get dcSearchHint => 'Search creatives, articles';

  @override
  String get dcFilters => 'Filters';

  @override
  String get dcAll => 'All';

  @override
  String dcRemoveFilter(String name) {
    return 'Remove filter $name';
  }

  @override
  String get dcOpenToCommissions => 'Open to commissions';

  @override
  String get dcVerified => 'Verified by Atarah';

  @override
  String get dcVerifiedOnly => 'Verified only';

  @override
  String get dcVerifiedOnlyBody => 'Identity or skills verified by Atarah';

  @override
  String dcCreativesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creatives',
      one: '1 creative',
    );
    return '$_temp0';
  }

  @override
  String get dcNoCreativesNearby =>
      'No creatives in this discipline yet nearby.';

  @override
  String get dcShowAll => 'Show all';

  @override
  String get dcNoCreativesYet => 'No creatives to show yet';

  @override
  String get dcNoCreativesYetBody =>
      'People appear here when they finish setting up their profile.';

  @override
  String get dcMoreToExplore => 'More to explore';

  @override
  String get dcOpportunitiesBody => 'Grants, calls and jobs';

  @override
  String get dcArticles => 'Articles';

  @override
  String get dcArticlesBody => 'Stories and advice for creatives';

  @override
  String get dcCreativeEconomy => 'Creative economy';

  @override
  String get dcCreativeEconomyBody =>
      'See where creative work is happening across Kenya';

  @override
  String get dcDiscoveredTitle => 'Want to be discovered?';

  @override
  String get dcDiscoveredBody =>
      'Complete your profile and showcase your work to the Atarah community.';

  @override
  String get dcReset => 'Reset';

  @override
  String get dcDiscipline => 'Discipline';

  @override
  String get dcLocation => 'Location';

  @override
  String get dcCounty => 'County';

  @override
  String get dcAnywhere => 'Anywhere';

  @override
  String get dcChooseCounty => 'Choose county';

  @override
  String get dcAvailability => 'Availability';

  @override
  String get dcSortBy => 'Sort by';

  @override
  String get dcSortRelevance => 'Best match';

  @override
  String get dcSortRecent => 'Newest';

  @override
  String dcShowResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count results',
      one: 'Show 1 result',
    );
    return '$_temp0';
  }

  @override
  String get dcShowResultsLoading => 'Show results';

  @override
  String get dcClearSearch => 'Clear search';

  @override
  String get dcRecent => 'Recent';

  @override
  String get dcClearAll => 'Clear all';

  @override
  String dcRemoveRecent(String query) {
    return 'Remove recent search $query';
  }

  @override
  String get dcSearchEmptyTitle => 'Search Atarah';

  @override
  String get dcSearchEmptyBody =>
      'Find creatives by name, field or skill, and articles by topic.';

  @override
  String get dcSearchTooShort => 'Type at least 2 characters.';

  @override
  String dcNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get dcNoResultsBody => 'Check the spelling or try a different word.';

  @override
  String get dcCreatives => 'Creatives';

  @override
  String dcAllCount(int count) {
    return 'All ($count)';
  }

  @override
  String dcCreativesTab(int count) {
    return 'Creatives ($count)';
  }

  @override
  String dcArticlesTab(int count) {
    return 'Articles ($count)';
  }

  @override
  String dcSeeAllCount(int count) {
    return 'See all $count';
  }

  @override
  String get dcSourceAtarah => 'Atarah Editorial';

  @override
  String get dcSourcePartner => 'Partner';

  @override
  String get dcSourceExternal => 'External source';

  @override
  String dcReadMinutes(int count) {
    return '$count min read';
  }

  @override
  String get dcShare => 'Share';

  @override
  String get dcSave => 'Save article';

  @override
  String get dcUnsave => 'Remove from saved';

  @override
  String get dcSaveFailed => 'We couldn\'t save that. Try again.';

  @override
  String get dcRuleOfThumb => 'Rule of thumb';

  @override
  String get dcArticleGone => 'This article is not available';

  @override
  String get dcArticleGoneBody =>
      'It may have been removed or not published yet.';

  @override
  String get dcNoArticles => 'No articles yet';

  @override
  String get dcNoArticlesBody => 'New stories and advice will appear here.';

  @override
  String get proPillLabel => 'Pro';

  @override
  String get appearanceLabel => 'Appearance';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get settingsGroupAccount => 'Account';

  @override
  String get settingsGroupSupport => 'Support';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsPrivacy => 'Privacy & visibility';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get peopleTitle => 'People to meet';

  @override
  String get peopleBody =>
      'Creatives who work like you, near you or in what you do.';

  @override
  String get peopleOpenToWork => 'Open to work';

  @override
  String get peopleAnyDiscipline => 'All disciplines';

  @override
  String get peopleAnyCounty => 'All counties';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0';
  }

  @override
  String get peopleRequested => 'Requested';

  @override
  String peopleConnectWith(String name) {
    return 'Connect with $name';
  }

  @override
  String get peopleRespond => 'Respond';

  @override
  String get peopleSave => 'Save';

  @override
  String peopleSaveLabel(String name) {
    return 'Save $name';
  }

  @override
  String get peopleSaveFeature => 'Saving people';

  @override
  String get peopleConnections => 'Connections';

  @override
  String get peopleRequests => 'Requests';

  @override
  String peopleRequestsWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count requests waiting',
      one: '1 request waiting',
    );
    return '$_temp0';
  }

  @override
  String get peopleConnectionsBody =>
      'The people you are connected with and the requests going back and forth.';

  @override
  String get peopleListConnected => 'Connected';

  @override
  String get peopleListReceived => 'Received';

  @override
  String get peopleListSent => 'Sent';

  @override
  String get peopleMore => 'More options';

  @override
  String get peopleBlocked => 'Blocked people';

  @override
  String get peopleBlockedBody =>
      'Blocking hides posts both ways and stops requests, comments and mentions.';

  @override
  String get peopleBlockedEmptyTitle => 'You have not blocked anyone';

  @override
  String get peopleBlockedEmptyBody =>
      'People you block will be listed here, and you can unblock them at any time.';

  @override
  String get peopleUnblock => 'Unblock';

  @override
  String peopleUnblockLabel(String name) {
    return 'Unblock $name';
  }

  @override
  String peopleBlockedSince(String date) {
    return 'Blocked $date';
  }

  @override
  String get peopleEmptyTitle => 'No one to suggest yet';

  @override
  String get peopleEmptyBody =>
      'As more creatives join and your profile fills in, people you may want to meet will appear here.';

  @override
  String get peopleEmptyFilteredTitle => 'No one matches those filters';

  @override
  String get peopleEmptyFilteredBody =>
      'Try fewer filters or a different county.';

  @override
  String get peopleClearFilters => 'Clear filters';

  @override
  String get peopleConnectedEmptyTitle => 'No connections yet';

  @override
  String get peopleConnectedEmptyBody =>
      'Connect with people you meet on Atarah and they will be listed here.';

  @override
  String get peopleReceivedEmptyTitle => 'No requests waiting';

  @override
  String get peopleReceivedEmptyBody =>
      'When someone asks to connect, you can accept or decline here.';

  @override
  String get peopleSentEmptyTitle => 'No pending requests';

  @override
  String get peopleSentEmptyBody =>
      'Requests you have sent that have not been answered yet are listed here.';

  @override
  String peopleSince(String date) {
    return 'Since $date';
  }

  @override
  String peopleRequestedOn(String date) {
    return 'Requested $date';
  }

  @override
  String peopleSentCancelLabel(String name) {
    return 'Withdraw request to $name';
  }

  @override
  String peopleAcceptLabel(String name) {
    return 'Accept $name';
  }

  @override
  String peopleDeclineLabel(String name) {
    return 'Decline $name';
  }

  @override
  String get peopleErrVerification =>
      'Verify your email or phone first and you can connect with people. It only takes a minute.';

  @override
  String get peopleErrRestricted =>
      'Your account is restricted for now, so you cannot do this. We will let you know if that changes.';

  @override
  String get peopleErrRateLimited =>
      'You have done a lot in a short time. Take a breather and try again a little later.';

  @override
  String get peopleErrNotFound => 'That person is not available any more.';

  @override
  String get opSubtitle =>
      'Funding, gigs and open calls matched to your craft.';

  @override
  String get opSaved => 'Saved';

  @override
  String opSavedCount(int count) {
    return 'Saved, $count items';
  }

  @override
  String get opSearchHint => 'Search grants, gigs, jobs…';

  @override
  String get opCatAll => 'All';

  @override
  String get opCatFunding => 'Funding';

  @override
  String get opCatGrants => 'Grants';

  @override
  String get opCatJobs => 'Jobs';

  @override
  String get opCatInternships => 'Internships';

  @override
  String get opCatGigs => 'Gigs';

  @override
  String get opCatCompetitions => 'Competitions';

  @override
  String get opCatFestivals => 'Festivals';

  @override
  String get opCatPartnerships => 'Partnerships';

  @override
  String get opCatFellowships => 'Fellowships';

  @override
  String get opCatResidencies => 'Residencies';

  @override
  String get opCatProgrammes => 'Programmes';

  @override
  String get opTypeGrant => 'Grant';

  @override
  String get opTypeFunding => 'Funding';

  @override
  String get opTypeJob => 'Job';

  @override
  String get opTypeInternship => 'Internship';

  @override
  String get opTypeGig => 'Gig';

  @override
  String get opTypeCompetition => 'Competition';

  @override
  String get opTypeFestival => 'Festival';

  @override
  String get opTypePartnership => 'Partnership';

  @override
  String get opTypeFellowship => 'Fellowship';

  @override
  String get opTypeResidency => 'Residency';

  @override
  String get opTypeProgramme => 'Programme';

  @override
  String get opFeatured => 'Featured';

  @override
  String get opClosingSoon => 'Closing soon';

  @override
  String get opRecent => 'Recently added';

  @override
  String opOpenCount(int count, String kind) {
    return '$count open $kind';
  }

  @override
  String get opKindAll => 'opportunities';

  @override
  String get opSortDeadline => 'Deadline: soonest';

  @override
  String get opSortRecent => 'Recently added';

  @override
  String get opSortRelevance => 'Most relevant';

  @override
  String get opSortBy => 'Sort by';

  @override
  String get opFilterDeadline => 'Closing within';

  @override
  String get opFilterAnyTime => 'Any time';

  @override
  String opFilterDays(int days) {
    return '$days days';
  }

  @override
  String get opFilterRemote => 'Remote only';

  @override
  String get opFilterRemoteBody => 'Work you can do from anywhere';

  @override
  String get opFilterTrust => 'Trust';

  @override
  String get opFilterTrustAny => 'Any';

  @override
  String get opFilterApply => 'Apply filters';

  @override
  String get opNoResults => 'No opportunities match';

  @override
  String get opNoResultsBody => 'Try clearing a filter, or check back soon.';

  @override
  String get opNothingOpen => 'Nothing open right now';

  @override
  String get opNothingOpenBody =>
      'New opportunities are added often. Check back soon.';

  @override
  String opDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
      zero: 'Closes today',
    );
    return '$_temp0';
  }

  @override
  String get opRolling => 'Rolling deadline';

  @override
  String get opClosed => 'Closed';

  @override
  String get opStatusSaved => 'Saved';

  @override
  String get opStatusInProgress => 'In progress';

  @override
  String get opStatusApplied => 'Applied';

  @override
  String get opStatusCompleted => 'Completed';

  @override
  String opStatusSavedLeft(String when) {
    return 'Saved · $when';
  }

  @override
  String opStatusClosingIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'less than a day',
    );
    return 'Closing in $_temp0';
  }

  @override
  String opStatusAppliedOn(String date) {
    return 'Applied externally · $date';
  }

  @override
  String opStatusCompletedOutcome(String outcome) {
    return 'Completed · $outcome';
  }

  @override
  String get opApplyWebsite => 'Apply on external website';

  @override
  String get opApplyEmail => 'Apply by email';

  @override
  String get opClosedNotice =>
      'This opportunity has closed. It stays in your list so you keep your record.';

  @override
  String get opAbout => 'About';

  @override
  String get opRequirements => 'Requirements';

  @override
  String get opBenefits => 'Benefits';

  @override
  String get opFactDeadline => 'Deadline';

  @override
  String get opFactValue => 'Value';

  @override
  String get opFactLocation => 'Location';

  @override
  String get opFactApplication => 'Application';

  @override
  String get opApplicationExternal => 'External website';

  @override
  String get opApplicationEmail => 'Email';

  @override
  String get opNotStated => 'Not stated';

  @override
  String get opHelpTitle => 'Help me understand this';

  @override
  String get opHelpBody => 'AI summary of eligibility and what to prepare';

  @override
  String get opShare => 'Share';

  @override
  String get opSave => 'Save opportunity';

  @override
  String get opUnsave => 'Remove from saved';

  @override
  String opGapMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Your profile is missing $count requirements',
      one: 'Your profile is missing 1 requirement',
    );
    return '$_temp0';
  }

  @override
  String get opGapMissingBody => 'Add them before you apply';

  @override
  String get opGapReady => 'You meet the requirements Atarah can check';

  @override
  String get opGapReadyBody =>
      'Read the listing for anything else the provider asks for.';

  @override
  String get opGapUnchecked => 'Atarah can\'t check these requirements';

  @override
  String get opGapUncheckedBody =>
      'The provider will confirm them. Read each one carefully.';

  @override
  String get opGapNoRules => 'No special requirements listed';

  @override
  String get opGapNoRulesBody =>
      'Read the listing and apply when you\'re ready.';

  @override
  String get opGapAdd => 'Add';

  @override
  String get opGapCannotCheck => 'We can\'t check this';

  @override
  String opGapProgress(int met, int total) {
    return '$met of $total met';
  }

  @override
  String get opMineTitle => 'My opportunities';

  @override
  String get opSavedTitle => 'Saved opportunities';

  @override
  String get opTabAll => 'All';

  @override
  String get opTabClosing => 'Closing soon';

  @override
  String get opTabApplied => 'Applied';

  @override
  String get opTabCompleted => 'Completed';

  @override
  String get opEmptyAll => 'Nothing tracked yet';

  @override
  String get opEmptyAllBody =>
      'Save an opportunity or apply for one to follow it here.';

  @override
  String get opEmptyClosing => 'Nothing closing soon';

  @override
  String get opEmptyClosingBody =>
      'Saved opportunities with a deadline in the next 14 days show up here.';

  @override
  String get opEmptyApplied => 'No applications yet';

  @override
  String get opEmptyAppliedBody =>
      'Opportunities you apply for are listed here.';

  @override
  String get opEmptyCompleted => 'Nothing completed yet';

  @override
  String get opEmptyCompletedBody =>
      'Opportunities you finish will be kept here for your Creative Passport.';

  @override
  String get opEmptySaved => 'Nothing saved yet';

  @override
  String get opEmptySavedBody =>
      'Tap the bookmark on an opportunity to keep it here.';

  @override
  String get opExplore => 'Explore opportunities';

  @override
  String get opMarkCompleted => 'Mark as completed';

  @override
  String get opOutcomeTitle => 'How did it go?';

  @override
  String get opOutcomeAwarded => 'Awarded';

  @override
  String get opOutcomeNotSelected => 'Not selected';

  @override
  String get opOutcomeWithdrawn => 'Withdrawn';

  @override
  String get opOutcomeUnknown => 'Not sure yet';

  @override
  String get opOutcomeSave => 'Save outcome';

  @override
  String get opAwardedTitle => 'Congratulations!';

  @override
  String get opAwardedBody =>
      'Add this win to your achievements so it shows on your Creative Passport.';

  @override
  String get opAddAchievement => 'Add this to your achievements';

  @override
  String get opNotNow => 'Not now';

  @override
  String get opOpenFailed => 'We couldn\'t open that. Try again.';

  @override
  String get opNotAvailable => 'That opportunity is not available any more.';

  @override
  String opMineSummary(int saved, int applied, int completed) {
    return '$saved saved · $applied applied · $completed completed';
  }

  @override
  String opSearchTab(int count) {
    return 'Opportunities ($count)';
  }

  @override
  String get lnHubTitle => 'Skill Labs';

  @override
  String get lnHubSubtitle =>
      'Build the skills that move your creative career forward.';

  @override
  String get lnMyLearning => 'My learning';

  @override
  String get lnContinueLearning => 'Continue learning';

  @override
  String get lnContinueLabel => 'CONTINUE LEARNING';

  @override
  String lnContinueMeta(int n, int total, String title) {
    return 'Lesson $n of $total · $title';
  }

  @override
  String lnContinueMetaNoTitle(int done, int total) {
    return '$done of $total lessons done';
  }

  @override
  String get lnFeatured => 'Featured Labs';

  @override
  String get lnCategories => 'Categories';

  @override
  String get lnGroupCreative => 'Creative';

  @override
  String get lnGroupBusiness => 'Business';

  @override
  String get lnGroupProfessional => 'Professional';

  @override
  String lnResourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources',
      one: '1 resource',
    );
    return '$_temp0';
  }

  @override
  String get lnRecommended => 'Recommended for you';

  @override
  String get lnHubEmptyTitle => 'No Skill Labs yet';

  @override
  String get lnHubEmptyBody =>
      'Courses and resources will appear here as soon as they are published.';

  @override
  String get lnOpenHub => 'Open Skill Labs';

  @override
  String get lnTypeAll => 'All';

  @override
  String get lnTypeCourse => 'Course';

  @override
  String get lnTypeTutorial => 'Tutorial';

  @override
  String get lnTypeToolkit => 'Toolkit';

  @override
  String get lnTypeWebinar => 'Webinar';

  @override
  String get lnTypeMasterclass => 'Masterclass';

  @override
  String get lnTypeArticle => 'Article';

  @override
  String get lnPluralCourse => 'courses';

  @override
  String get lnPluralTutorial => 'tutorials';

  @override
  String get lnPluralToolkit => 'toolkits';

  @override
  String get lnPluralWebinar => 'webinars';

  @override
  String get lnPluralMasterclass => 'masterclasses';

  @override
  String get lnPluralArticle => 'articles';

  @override
  String get lnPluralAll => 'resources';

  @override
  String get lnSourceAtarahCourse => '✓ Atarah Course';

  @override
  String get lnSourceAtarahEditorial => '✓ Atarah Editorial';

  @override
  String get lnSourcePartner => 'Partner content';

  @override
  String get lnSourceExternal => 'External resource';

  @override
  String get lnDeliveryNative => 'In-app lessons';

  @override
  String get lnDeliveryEmbedded => 'Embedded';

  @override
  String get lnDeliveryExternal => 'Opens outside Atarah';

  @override
  String get lnLevelBeginner => 'Beginner';

  @override
  String get lnLevelIntermediate => 'Intermediate';

  @override
  String get lnLevelAdvanced => 'Advanced';

  @override
  String get lnLevelExpert => 'Expert';

  @override
  String lnLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String lnDurationHm(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String lnDurationH(int hours) {
    return '${hours}h';
  }

  @override
  String lnDurationM(int minutes) {
    return '$minutes min';
  }

  @override
  String get lnPremiumBadge => 'Pro';

  @override
  String lnCategoryEmptyTitle(String category) {
    return 'Nothing in $category yet';
  }

  @override
  String get lnCategoryEmptyBody =>
      'New Skill Labs are added all the time. Check back soon.';

  @override
  String lnTypeEmptyTitle(String types, String category) {
    return 'No $types in $category yet';
  }

  @override
  String get lnTypeEmptyCta => 'Explore all types';

  @override
  String get lnLoadMoreFailed => 'We couldn\'t load more. Tap to try again.';

  @override
  String get lnYourProgress => 'Your progress';

  @override
  String lnProgressOf(int done, int total) {
    return '$done / $total';
  }

  @override
  String lnPercentComplete(int percent) {
    return '$percent% complete';
  }

  @override
  String get lnWhatYoullLearn => 'What you\'ll learn';

  @override
  String get lnWhoItsFor => 'Who it\'s for';

  @override
  String get lnLessons => 'Lessons';

  @override
  String get lnTaughtBy => 'Taught by';

  @override
  String get lnFrom => 'From';

  @override
  String get lnStartLearning => 'Start learning';

  @override
  String get lnReviewCourse => 'Review course';

  @override
  String get lnLessonDone => 'Done';

  @override
  String get lnLessonCurrent => 'Current';

  @override
  String get lnLessonLocked => 'Locked';

  @override
  String lnLessonRow(int n, String title, int minutes, String state) {
    return 'Lesson $n: $title, $minutes minutes, $state';
  }

  @override
  String lnLessonMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get lnSaveLab => 'Save to my learning';

  @override
  String get lnUnsaveLab => 'Remove from saved';

  @override
  String get lnShareLab => 'Share this Skill Lab';

  @override
  String get lnCertificateEarned => 'Certificate earned';

  @override
  String lnCertificateNumber(String number) {
    return 'No. $number';
  }

  @override
  String lnCertificateIssued(String date) {
    return 'Issued $date';
  }

  @override
  String get lnViewOnPassport => 'See it in your achievements';

  @override
  String get lnPremiumFeature => 'Premium Skill Labs';

  @override
  String get lnPremiumWhat =>
      'Courses and masterclasses from Atarah and our partners, with certificates.';

  @override
  String get lnPremiumWhy =>
      'Structured learning is the quickest way to move a skill from good to hireable.';

  @override
  String get lnPremiumHow => 'Upgrade to Atarah Pro to open every Skill Lab.';

  @override
  String get lnOpenResource => 'Open resource';

  @override
  String lnLeavingBody(String domain) {
    return 'You\'re going to $domain. It\'s a resource from outside Atarah, so what you do there stays there.';
  }

  @override
  String get lnMarkComplete => 'Mark as complete';

  @override
  String get lnCompletedItem => 'Completed';

  @override
  String get lnStartedItem => 'In progress';

  @override
  String get lnFindSimilar => 'Find similar';

  @override
  String get lnWatchEmbedded => 'Watch';

  @override
  String get lnEnrolFailed => 'We couldn\'t start that course. Try again.';

  @override
  String get lnNeedsConnection => 'Connect to the internet to continue.';

  @override
  String get lnSavedCopyBanner =>
      'Showing your saved copy. Connect to the internet to keep learning.';

  @override
  String lnLessonOf(int n, int total) {
    return 'Lesson $n of $total';
  }

  @override
  String get lnPractice => 'Practice';

  @override
  String get lnAddToPortfolio => 'Add to portfolio';

  @override
  String get lnLearnNext => 'What should I learn next?';

  @override
  String get lnAllLessons => 'All lessons';

  @override
  String get lnMarkCompleteNext => 'Mark complete & next';

  @override
  String get lnMarkCompleteFinish => 'Mark complete & finish';

  @override
  String lnLessonProgressBar(int done, int total) {
    return 'Lesson progress: $done of $total lessons complete';
  }

  @override
  String get lnVideoLoadFailed => 'We couldn\'t load this video.';

  @override
  String get lnVideoPreparing =>
      'The video is still being prepared. Try again in a moment.';

  @override
  String lnEmbedFailedTitle(String service) {
    return '$service isn\'t responding';
  }

  @override
  String get lnBackToCourse => 'Go back to course';

  @override
  String lnVideoResuming(String time) {
    return 'Resuming from $time';
  }

  @override
  String get lnLessonLockedMessage =>
      'Finish the earlier lessons to unlock this one.';

  @override
  String get lnSaveProgressFailed =>
      'We couldn\'t save your progress. It will retry.';

  @override
  String get lnVideoSemantic => 'Lesson video';

  @override
  String get lnCompleteTitle => 'Course complete!';

  @override
  String lnCompleteBody(String course) {
    return 'You finished $course. Your certificate is added to your achievements.';
  }

  @override
  String get lnCompleteShare => 'Share';

  @override
  String lnCompleteShareText(String course) {
    return 'I just completed $course on Atarah Skill Labs.';
  }

  @override
  String get lnBackToLabs => 'Back to Skill Labs';

  @override
  String get lnStatInProgress => 'In progress';

  @override
  String get lnStatCompleted => 'Completed';

  @override
  String get lnStatHours => 'Hours this month';

  @override
  String get lnTabActive => 'Active';

  @override
  String get lnTabCompleted => 'Completed';

  @override
  String get lnTabSaved => 'Saved';

  @override
  String get lnSavedTitle => 'Saved Skill Labs';

  @override
  String get lnEmptyActiveTitle => 'Nothing in progress';

  @override
  String get lnEmptyActiveBody =>
      'Start a Skill Lab and pick up where you left off, any time.';

  @override
  String get lnEmptyActiveCta => 'Browse Skill Labs';

  @override
  String get lnEmptyCompletedTitle => 'Nothing completed yet';

  @override
  String get lnEmptyCompletedBody =>
      'Finish a course to earn a certificate for your Passport.';

  @override
  String get lnEmptySavedTitle => 'No saved Skill Labs';

  @override
  String get lnEmptySavedBody =>
      'Tap the bookmark on a Skill Lab to keep it here.';

  @override
  String lnCompletedOn(String date) {
    return 'Completed $date';
  }

  @override
  String lnLastActive(String date) {
    return 'Last active $date';
  }

  @override
  String lnSearchTab(int count) {
    return 'Skill Labs ($count)';
  }

  @override
  String get premiumSeeProPlain => 'See Pro';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get ayActivityTitle => 'Activity';

  @override
  String get ayPickUp => 'Pick up where you left off';

  @override
  String get ayNothingToResume =>
      'Nothing to pick up right now. Start a Skill Lab, save an opportunity or add a project.';

  @override
  String get ayResumeLesson => 'Continue lesson';

  @override
  String get ayResumeOpportunity => 'Finish your application';

  @override
  String get ayResumeProject => 'Finish your project';

  @override
  String get ayTileSaved => 'Saved';

  @override
  String get ayTileApplications => 'Applications';

  @override
  String get ayTileLearning => 'My learning';

  @override
  String get ayTilePortfolio => 'Portfolio';

  @override
  String get ayTileConnections => 'Connections';

  @override
  String get ayTileNotifications => 'Notifications';

  @override
  String get ayTileMentorship => 'Mentorship';

  @override
  String get ayTileMarketplace => 'Marketplace';

  @override
  String get aySoonP2 => 'Soon · P2';

  @override
  String ayCount(int count) {
    return '$count saved';
  }

  @override
  String ayInProgressCount(int count) {
    return '$count in progress';
  }

  @override
  String ayPendingCount(int count) {
    return '$count waiting';
  }

  @override
  String ayUnreadCount(int count) {
    return '$count unread';
  }

  @override
  String get ayApplicationsTitle => 'Applications';

  @override
  String get ayApplicationsEmptyTitle => 'No applications yet';

  @override
  String get ayApplicationsEmptyBody =>
      'When you start or finish an application it is tracked here.';

  @override
  String get ayFindOpportunities => 'Find opportunities';

  @override
  String get ayApplied => 'Applied';

  @override
  String get ayCompleted => 'Completed';

  @override
  String get ayInProgress => 'In progress';

  @override
  String get ntTitle => 'Notifications';

  @override
  String get ntSettings => 'Notification settings';

  @override
  String get ntAll => 'All';

  @override
  String get ntCatOpportunities => 'Opportunities';

  @override
  String get ntCatMentorship => 'Mentorship';

  @override
  String get ntCatCommunity => 'Community';

  @override
  String get ntCatLearning => 'Learning';

  @override
  String get ntCatProfile => 'Profile';

  @override
  String get ntCatMarketplace => 'Marketplace';

  @override
  String get ntCatSystem => 'Updates';

  @override
  String get ntToday => 'Today';

  @override
  String get ntEarlier => 'Earlier';

  @override
  String get ntMarkAllRead => 'Mark all read';

  @override
  String get ntEmptyTitle => 'You\'re all caught up';

  @override
  String get ntEmptyBody =>
      'New connection requests, reminders and replies show up here.';

  @override
  String ntEmptyCategoryTitle(String category) {
    return 'No $category notifications';
  }

  @override
  String get sdTitle => 'Saved';

  @override
  String get sdAll => 'All';

  @override
  String get sdTypeOpportunity => 'Opportunities';

  @override
  String get sdTypeLearning => 'Skill Labs';

  @override
  String get sdTypeCreative => 'Creatives';

  @override
  String get sdTypeArticle => 'Articles';

  @override
  String get sdTypePost => 'Posts';

  @override
  String get sdTypeListing => 'Listings';

  @override
  String get sdTypeMentor => 'Mentors';

  @override
  String get sdEmptyTitle => 'Nothing saved yet';

  @override
  String get sdEmptyBody =>
      'Tap the bookmark on an opportunity, Skill Lab, article or post to keep it here.';

  @override
  String sdEmptyTypeTitle(String type) {
    return 'No saved $type';
  }

  @override
  String get sdExplore => 'Explore';

  @override
  String get sdUnsaveFailed =>
      'That could not be removed from your saved list.';

  @override
  String get stSaved => 'Saved';

  @override
  String get stSaveChanges => 'Save changes';

  @override
  String get stFullName => 'Full name';

  @override
  String get stUsername => 'Username';

  @override
  String get stUsernameHelp => 'Your public address: atarah.app/username';

  @override
  String get stEmail => 'Email';

  @override
  String get stPhone => 'Phone';

  @override
  String get stNotSet => 'Not added';

  @override
  String get stChange => 'Change';

  @override
  String get stChangeEmail => 'Change email';

  @override
  String get stChangePhone => 'Change phone number';

  @override
  String get stChangeEmailBody =>
      'We will send a link to the new address. Your email changes when you open it. We also tell your current address.';

  @override
  String get stChangePhoneBody =>
      'We will send a code to the new number. Your number changes when you enter it.';

  @override
  String get stNewEmail => 'New email';

  @override
  String get stNewPhone => 'New phone number';

  @override
  String get stSendLink => 'Send link';

  @override
  String get stSendCode => 'Send code';

  @override
  String get stVerify => 'Verify';

  @override
  String get stDone => 'Done';

  @override
  String get stOk => 'OK';

  @override
  String stPendingChange(String value) {
    return 'Waiting for you to confirm $value';
  }

  @override
  String stEmailLinkSent(String address) {
    return 'We sent a link to $address. Open it to finish the change.';
  }

  @override
  String stPhoneCodeSent(String number) {
    return 'We sent a code to $number. Enter it below.';
  }

  @override
  String get stPrivacyIntro =>
      'Choose who sees each part of your profile. Private details still power your recommendations.';

  @override
  String get stPrivContact => 'Contact details';

  @override
  String get stPrivLocation => 'Location';

  @override
  String get stPrivPortfolio => 'Portfolio';

  @override
  String get stPrivExperience => 'Experience';

  @override
  String get stPrivActivity => 'Activity';

  @override
  String get stPrivNotSaved => 'That change was not saved.';

  @override
  String get stVisPublic => 'Public';

  @override
  String get stVisMembers => 'Members';

  @override
  String get stVisPrivate => 'Only me';

  @override
  String get stYourData => 'Your data';

  @override
  String get stExportTitle => 'Export my data';

  @override
  String get stExportBody =>
      'We prepare a file with your profile, projects and activity, and send you a link that works for 7 days. One export a day.';

  @override
  String get stExportRequest => 'Request my data';

  @override
  String get stExportRequested =>
      'We are preparing your file. You will be notified when it is ready.';

  @override
  String get stExportPreparing => 'Preparing';

  @override
  String get stExportReady => 'Ready';

  @override
  String get stExportFailed => 'Failed';

  @override
  String get stExportExpired => 'Expired';

  @override
  String get stExportDownload => 'Download my data';

  @override
  String stExportNext(String date) {
    return 'You can ask again on $date.';
  }

  @override
  String get stNotifCategory => 'Category';

  @override
  String get stNotifPush => 'Push';

  @override
  String get stNotifEmail => 'Email';

  @override
  String stNotifPushFor(String category) {
    return 'Push notifications for $category';
  }

  @override
  String stNotifEmailFor(String category) {
    return 'Email notifications for $category';
  }

  @override
  String get stNotifOpportunitiesDesc => 'Deadlines and new matches';

  @override
  String get stNotifCommunityDesc => 'Replies, mentions and requests';

  @override
  String get stNotifLearningDesc => 'Certificates and recommendations';

  @override
  String get stNotifMentorshipDesc => 'Booking updates';

  @override
  String get stNotifProfileDesc => 'Profile tips and reminders';

  @override
  String get stNotifMarketplaceDesc => 'Orders and messages';

  @override
  String get stNotifSystemDesc => 'Account and safety updates';

  @override
  String get stNotifSecurityNote =>
      'Security notices, such as a new sign-in or a password change, are always sent.';

  @override
  String get stPassword => 'Password';

  @override
  String get stChangePassword => 'Change password';

  @override
  String get stCurrentPassword => 'Current password';

  @override
  String get stNewPassword => 'New password';

  @override
  String get stPasswordChanged =>
      'Password changed. Other devices were signed out.';

  @override
  String get stTwoStep => 'Two-step verification';

  @override
  String get stTwoStepBody => 'A code when you sign in on a new device';

  @override
  String get stTwoStepNeedsPhone =>
      'Add a verified phone number to your account first.';

  @override
  String get stTwoStepOn => 'Two-step verification is on.';

  @override
  String get stTwoStepOff => 'Two-step verification is off.';

  @override
  String get stActiveSessions => 'Active sessions';

  @override
  String get stThisDevice => 'This device';

  @override
  String get stUnknownDevice => 'Unknown device';

  @override
  String get stSignOutSession => 'Sign out';

  @override
  String get stTwoStepTitle => 'Confirm it is you';

  @override
  String get stTwoStepSms =>
      'Enter the code we sent to your phone to sign in on this device.';

  @override
  String get stTwoStepApp =>
      'Enter the code from your authenticator app to sign in on this device.';

  @override
  String get stTwoStepNoFactor =>
      'We can\'t find a second step on your account. Sign out and sign in again, or contact support.';

  @override
  String get stTwoStepWrongCode =>
      'That code didn\'t work. Check it and try again.';

  @override
  String get stHelpSearch => 'Search help articles';

  @override
  String get stSafetyCentre => 'Safety centre';

  @override
  String get stSafetyCentreBody => 'Report, block, mute';

  @override
  String get stHelpArticles => 'Articles';

  @override
  String get stFaq => 'Frequently asked';

  @override
  String get stHelpNoResults => 'Nothing matches that';

  @override
  String get stHelpNoResultsBody =>
      'Try fewer words, or ask us directly below.';

  @override
  String get stStillNeedHelp => 'Still need help?';

  @override
  String get stChatWithUs => 'Chat with us';

  @override
  String get stLegalEmpty => 'No documents yet';

  @override
  String get stLegalEmptyBody => 'Our legal documents will appear here.';

  @override
  String stVersion(String version) {
    return 'Version $version';
  }

  @override
  String get stDraft => 'Draft';

  @override
  String get stDraftPending => 'DRAFT — pending legal review';

  @override
  String get stCurrentPlan => 'CURRENT PLAN';

  @override
  String get stPlanFreeBody =>
      'Everything you need to build your creative identity.';

  @override
  String get stPlanProBody => 'Thank you for supporting Atarah.';

  @override
  String stPlanRenews(String date) {
    return 'Renews $date';
  }

  @override
  String get stWhatsIncluded => 'What\'s included';

  @override
  String get stFeature => 'Feature';

  @override
  String get stIncluded => 'Included';

  @override
  String get stNotIncluded => 'Not included';

  @override
  String stUpgrade(String price) {
    return 'Upgrade to Pro · $price';
  }

  @override
  String get stUpgradePlain => 'Upgrade to Pro';

  @override
  String get stCancelAnytime => 'Cancel anytime. No hidden fees.';

  @override
  String get stDeleteAccount => 'Delete account';

  @override
  String get stDeleteTitle => 'Delete your account?';

  @override
  String get stDeleteIntro =>
      'This can\'t be undone. You will permanently lose:';

  @override
  String get stDeleteLossProfile => 'Your profile and Creative Passport';

  @override
  String get stDeleteLossPortfolio =>
      'Your portfolio, services and achievements';

  @override
  String get stDeleteLossConnections => 'Your connections and saved items';

  @override
  String get stDeleteLossProgress => 'Your learning progress and certificates';

  @override
  String get stDeleteGrace =>
      'Your account is hidden and you are signed out right away. Your data is deleted after 30 days. Sign in before then to restore it. Your posts and comments stay and show as \"Deleted member\".';

  @override
  String get stTypeDelete => 'Type DELETE to confirm';

  @override
  String get stPasswordToConfirm => 'Your password';

  @override
  String get stPasswordToConfirmHelp =>
      'Needed if you signed in more than 5 minutes ago.';

  @override
  String get stDeletePermanently => 'Delete account permanently';

  @override
  String get stKeepAccount => 'Keep my account';

  @override
  String get stDeletedTitle => 'Your account is scheduled for deletion';

  @override
  String get stDeletedBody =>
      'It is hidden now and your data is deleted after 30 days. Sign in before then if you change your mind.';

  @override
  String get stRestoreTitle => 'Restore your account?';

  @override
  String stRestoreBody(String date) {
    return 'Your account is scheduled for deletion on $date. Restore it to keep everything.';
  }

  @override
  String get stRestoreBodyNoDate =>
      'Your account is scheduled for deletion. Restore it to keep everything.';

  @override
  String get stRestoreAccount => 'Restore account';

  @override
  String get stOfflineNeedsConnection => 'Needs a connection';
}
