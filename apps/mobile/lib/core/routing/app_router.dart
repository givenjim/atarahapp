import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/design_system/gallery/component_gallery.dart';
import '../../features/activity/activity_screen.dart';
import '../../features/activity/applications_screen.dart';
import '../../features/auth/forgot_screen.dart';
import '../../features/auth/legal_screen.dart';
import '../../features/auth/reset_screen.dart';
import '../../features/auth/signin_screen.dart';
import '../../features/auth/signup_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/auth/verify_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/community/community_screen.dart';
import '../../features/community/compose_screen.dart';
import '../../features/community/groups/group_screen.dart';
import '../../features/community/people/people_screens.dart';
import '../../features/community/post_screen.dart';
import '../../features/cv/cv_screen.dart';
import '../../features/discover/article_screen.dart';
import '../../features/discover/articles_screen.dart';
import '../../features/discover/explore_screen.dart';
import '../../features/discover/home_screen.dart';
import '../../features/discover/search_screen.dart';
import '../../features/learning/course_screen.dart';
import '../../features/learning/learning_category_screen.dart';
import '../../features/learning/learning_hub_screen.dart';
import '../../features/learning/learning_repository.dart' show MyLearningTab;
import '../../features/learning/lesson_screen.dart';
import '../../features/learning/my_learning_screen.dart';
import '../../features/marketplace/enquiry_screens.dart';
import '../../features/marketplace/listing_editor_screen.dart';
import '../../features/marketplace/listing_screen.dart';
import '../../features/marketplace/marketplace_browse_screen.dart';
import '../../features/marketplace/marketplace_screen.dart';
import '../../features/marketplace/my_listings_screen.dart';
import '../../features/marketplace/seller_screen.dart';
import '../../features/mentorship/mentor_apply_screen.dart';
import '../../features/mentorship/mentor_manage_screens.dart';
import '../../features/mentorship/mentor_screen.dart';
import '../../features/mentorship/mentor_tools_screen.dart';
import '../../features/mentorship/mentors_list_screen.dart';
import '../../features/mentorship/mentorship_hub_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/onboarding/onboarding_providers.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/opportunities/my_opportunities_screen.dart';
import '../../features/opportunities/opportunities_list_screen.dart';
import '../../features/opportunities/opportunities_repository.dart' show MyTab;
import '../../features/opportunities/opportunities_screen.dart';
import '../../features/opportunities/opportunity_screen.dart';
import '../../features/payments/payment_models.dart' show PaymentRequest;
import '../../features/payments/payment_screen.dart';
import '../../features/portfolio/achievements_screen.dart';
import '../../features/portfolio/experience_screen.dart';
import '../../features/portfolio/portfolio_screen.dart';
import '../../features/portfolio/project_editor_screen.dart';
import '../../features/portfolio/project_screen.dart';
import '../../features/portfolio/services_screen.dart';
import '../../features/portfolio/skills_screen.dart';
import '../../features/profile/creative_profile_screen.dart';
import '../../features/profile/passport_screen.dart';
import '../../features/profile/profile_repository.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/saved/saved_screen.dart';
import '../../features/settings/account_screen.dart';
import '../../features/settings/delete_screens.dart';
import '../../features/settings/help_screens.dart';
import '../../features/settings/membership_screen.dart';
import '../../features/settings/privacy_screens.dart';
import '../../features/settings/security_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/two_step_screen.dart';
import '../../features/shell/app_shell.dart';
import '../../features/shell/future_route_screen.dart';
import '../api/generated/export.dart'
    show LearningContentType, OpportunityType, TaxonomyItemDto;
import '../auth/session_controller.dart';
import '../auth/two_step.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'redirect.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Detail routes that open the placeholder for now: path, phase, display name.
final List<
  ({String path, String phase, String Function(AppLocalizations) name})
>
_detailRoutes = [];

/// Navigation graph: splash -> session check -> welcome / home, the five-tab shell, and the deep-link
/// routes. Redirect logic lives in [computeRedirect].
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final devTools = ref.watch(appConfigProvider).showDevTools;
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionStatusProvider, (_, _) => refresh.value++);
  ref.listen(onboardingGateProvider, (_, _) => refresh.value++);
  ref.listen(twoStepRequiredProvider, (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  String phaseOf(GoRouterState s) => s.pathParameters['phase'] ?? 'later';

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) => computeRedirect(
      status: ref.read(sessionStatusProvider),
      uri: state.uri,
      devTools: devTools,
      onboarding: ref.read(onboardingGateProvider),
      pendingDeletion:
          ref.read(sessionControllerProvider).value?.deletionScheduledFor !=
          null,
      twoStepRequired: ref.read(twoStepRequiredProvider),
    ),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.welcome, builder: (_, _) => const WelcomeScreen()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignUpScreen()),
      GoRoute(path: Routes.signin, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: Routes.verify,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          final ms = int.tryParse(q['resendAt'] ?? '');
          return VerifyScreen(
            identifier: q['identifier'] ?? '',
            resendAt: ms == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(ms),
          );
        },
      ),
      GoRoute(
        path: Routes.forgot,
        builder: (_, state) =>
            ForgotScreen(identifier: state.uri.queryParameters['identifier']),
      ),
      GoRoute(
        path: Routes.reset,
        builder: (_, state) => ResetScreen(
          identifier: state.uri.queryParameters['identifier'] ?? '',
          codeJustSent: state.uri.queryParameters['sent'] == '1',
        ),
      ),
      GoRoute(
        path: Routes.legal,
        builder: (_, state) =>
            LegalScreen(type: state.pathParameters['type'] ?? 'TERMS'),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.passport, builder: (_, _) => const PassportScreen()),
      GoRoute(path: Routes.cv, builder: (_, _) => const CvScreen()),
      GoRoute(
        path: Routes.portfolio,
        builder: (_, _) => const PortfolioScreen(),
      ),
      GoRoute(
        path: Routes.projectEdit,
        builder: (_, state) => ProjectEditorScreen(
          projectId: state.pathParameters['id'] ?? 'new',
          // The practice box of a Skill Labs lesson starts the project with its skill.
          prefillSkill: switch (state.uri.queryParameters) {
            {'skillId': final id, 'skillName': final name} => TaxonomyItemDto(
              id: id,
              slug: '',
              name: name,
            ),
            _ => null,
          },
        ),
      ),
      GoRoute(
        path: Routes.project,
        builder: (_, state) => ProjectScreen(
          projectId: state.pathParameters['id'] ?? '',
          handle: state.uri.queryParameters['handle'],
          preview: switch (state.uri.queryParameters['preview']) {
            'public' => PublicProfilePreview.public,
            'members' => PublicProfilePreview.members,
            _ => null,
          },
        ),
      ),
      GoRoute(path: Routes.skills, builder: (_, _) => const SkillsScreen()),
      GoRoute(
        path: Routes.experience,
        builder: (_, _) => const ExperienceScreen(),
      ),
      GoRoute(
        path: Routes.achievements,
        builder: (_, _) => const AchievementsScreen(),
      ),
      GoRoute(path: Routes.services, builder: (_, _) => const ServicesScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: Routes.accountSettings,
        builder: (_, _) => const AccountScreen(),
      ),
      GoRoute(
        path: Routes.privacySettings,
        builder: (_, _) => const PrivacyScreen(),
      ),
      GoRoute(
        path: Routes.notificationSettings,
        builder: (_, _) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: Routes.security, builder: (_, _) => const SecurityScreen()),
      GoRoute(path: Routes.help, builder: (_, _) => const HelpScreen()),
      GoRoute(
        path: Routes.helpArticle,
        builder: (_, state) =>
            HelpArticleScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      GoRoute(
        path: Routes.legalList,
        builder: (_, _) => const LegalListScreen(),
      ),
      GoRoute(
        path: Routes.legalDocument,
        builder: (_, state) =>
            LegalDocumentScreen(type: state.pathParameters['type'] ?? 'TERMS'),
      ),
      GoRoute(
        path: Routes.membership,
        builder: (_, _) => const MembershipScreen(),
      ),
      GoRoute(
        path: Routes.deleteAccount,
        builder: (_, _) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: Routes.restore,
        builder: (_, _) => const RestoreAccountScreen(),
      ),
      GoRoute(path: Routes.twoStep, builder: (_, _) => const TwoStepScreen()),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(path: Routes.activity, builder: (_, _) => const ActivityScreen()),
      GoRoute(path: Routes.saved, builder: (_, _) => const SavedScreen()),
      GoRoute(
        path: Routes.applications,
        builder: (_, _) => const ApplicationsScreen(),
      ),
      GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen()),
      GoRoute(path: Routes.articles, builder: (_, _) => const ArticlesScreen()),
      GoRoute(
        path: Routes.creatives,
        builder: (_, _) => const PeopleToMeetScreen(),
      ),
      GoRoute(
        path: Routes.connections,
        builder: (_, state) => ConnectionsScreen(
          initial: ConnectionsView.parse(state.uri.queryParameters['list']),
        ),
      ),
      GoRoute(path: Routes.blocked, builder: (_, _) => const BlockedScreen()),
      // Fixed paths first: `/opportunities/browse` and `/opportunities/mine` must not be read as an id.
      GoRoute(
        path: Routes.opportunitiesList,
        builder: (_, state) => OpportunitiesListScreen(
          type: OpportunityType.values
              .where(
                (t) =>
                    t.json != null &&
                    t.json == state.uri.queryParameters['type'],
              )
              .firstOrNull,
        ),
      ),
      GoRoute(
        path: Routes.myOpportunities,
        builder: (_, state) => MyOpportunitiesScreen(
          initial:
              MyTab.values
                  .where((t) => t.name == state.uri.queryParameters['tab'])
                  .firstOrNull ??
              MyTab.all,
        ),
      ),
      GoRoute(
        path: Routes.opportunity,
        builder: (_, state) =>
            OpportunityScreen(opportunityId: state.pathParameters['id'] ?? ''),
      ),
      // Marketplace (P2-M3). Fixed paths first: `/marketplace/browse`, `/mine`, `/new` and `/enquiries` are not ids.
      GoRoute(
        path: Routes.marketplace,
        builder: (_, _) => const MarketplaceScreen(),
      ),
      GoRoute(
        path: Routes.marketplaceBrowse,
        builder: (_, state) => MarketplaceBrowseScreen(
          categoryId: state.uri.queryParameters['categoryId'],
          categoryName: state.uri.queryParameters['categoryName'],
          type: listingTypeOf(state.uri.queryParameters['type']),
          q: state.uri.queryParameters['q'],
        ),
      ),
      GoRoute(
        path: Routes.myListings,
        builder: (_, _) => const MyListingsScreen(),
      ),
      GoRoute(
        path: Routes.listingNew,
        builder: (_, _) => const ListingEditorScreen(),
      ),
      GoRoute(
        path: Routes.listingEdit,
        builder: (_, state) =>
            ListingEditorScreen(listingId: state.pathParameters['id']),
      ),
      GoRoute(
        path: Routes.enquiries,
        builder: (_, state) => EnquiriesScreen(
          initialReceived: state.uri.queryParameters['tab'] == 'received',
        ),
      ),
      GoRoute(
        path: Routes.enquiry,
        builder: (_, state) =>
            EnquiryScreen(enquiryId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.seller,
        builder: (_, state) =>
            SellerScreen(sellerId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.listing,
        builder: (_, state) =>
            ListingScreen(listingId: state.pathParameters['id'] ?? ''),
      ),
      // Skill Labs. Fixed paths first: `/learning/mine` must not be read as an id.
      GoRoute(
        path: Routes.learning,
        builder: (_, _) => const LearningHubScreen(),
      ),
      GoRoute(
        path: Routes.learningMine,
        builder: (_, state) => MyLearningScreen(
          initial:
              MyLearningTab.values
                  .where((t) => t.name == state.uri.queryParameters['tab'])
                  .firstOrNull ??
              MyLearningTab.active,
        ),
      ),
      GoRoute(
        path: Routes.learningCategory,
        builder: (_, state) => LearningCategoryScreen(
          slug: state.pathParameters['slug'] ?? '',
          type: LearningContentType.values
              .where(
                (t) =>
                    t.json != null &&
                    t.json == state.uri.queryParameters['type'],
              )
              .firstOrNull,
        ),
      ),
      GoRoute(
        path: Routes.course,
        builder: (_, state) =>
            CourseScreen(courseId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.lesson,
        builder: (_, state) =>
            LessonScreen(lessonId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.post,
        builder: (_, state) =>
            PostScreen(postId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.pay,
        builder: (_, state) => PaymentScreen(
          request: state.extra is PaymentRequest
              ? state.extra! as PaymentRequest
              : null,
        ),
      ),
      GoRoute(
        path: Routes.compose,
        builder: (_, state) => ComposeScreen(
          groupId: state.uri.queryParameters['groupId'],
          groupName: state.uri.queryParameters['groupName'],
        ),
      ),
      GoRoute(
        path: Routes.group,
        builder: (_, state) =>
            GroupScreen(groupRef: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.article,
        builder: (_, state) =>
            ArticleScreen(slug: state.pathParameters['slug'] ?? ''),
      ),
      // Mentorship (P2-M4). Fixed paths only, so none can be read as a `/mentors/:id` detail route.
      GoRoute(
        path: Routes.mentorship,
        builder: (_, _) => const MentorshipHubScreen(),
      ),
      GoRoute(
        path: Routes.mentorDirectory,
        builder: (_, _) => const MentorsListScreen(),
      ),
      GoRoute(
        path: Routes.mentorApply,
        builder: (_, _) => const MentorApplyScreen(),
      ),
      GoRoute(
        path: Routes.mentorTools,
        builder: (_, _) => const MentorToolsScreen(),
      ),
      GoRoute(
        path: Routes.mentorAvailability,
        builder: (_, _) => const MentorAvailabilityScreen(),
      ),
      GoRoute(
        path: Routes.mentorSessionTypes,
        builder: (_, _) => const MentorSessionTypesScreen(),
      ),
      GoRoute(
        path: Routes.mentorProfileEdit,
        builder: (_, _) => const MentorProfileEditScreen(),
      ),
      GoRoute(
        path: Routes.mentorRequests,
        builder: (_, _) => const MentorRequestsScreen(),
      ),
      GoRoute(
        path: Routes.mentor,
        builder: (_, state) =>
            MentorScreen(mentorId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.mentorPremium,
        builder: (_, state) =>
            MentorPremiumScreen(mentorId: state.pathParameters['id'] ?? ''),
      ),
      GoRoute(
        path: Routes.creative,
        builder: (_, state) => CreativeProfileScreen(
          handle: state.pathParameters['handle'] ?? '',
          preview: state.uri.queryParameters['preview'] == '1',
        ),
      ),
      if (devTools)
        GoRoute(
          path: Routes.devGallery,
          builder: (_, _) => const ComponentGalleryScreen(),
        ),
      GoRoute(
        path: Routes.soon,
        builder: (_, state) => FutureRouteScreen(
          phase: phaseOf(state),
          name: state.uri.queryParameters['name'],
        ),
      ),
      for (final d in _detailRoutes)
        GoRoute(
          path: d.path,
          builder: (context, state) => FutureRouteScreen(
            phase: d.phase,
            name: d.name(AppLocalizations.of(context)),
          ),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.explore,
                builder: (_, _) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.community,
                builder: (_, _) => const CommunityScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.opportunities,
                builder: (_, _) => const OpportunitiesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
