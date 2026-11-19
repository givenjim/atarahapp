/// Route paths. Deep links map straight onto these: `https://atarah.app/<path>` and `atarah://app/<path>`.
abstract final class Routes {
  static const splash = '/splash';
  static const welcome = '/welcome';
  static const signup = '/signup';
  static const signin = '/signin';
  static const verify = '/verify';
  static const forgot = '/forgot';
  static const reset = '/reset';
  static const legal = '/legal/:type';
  static const onboarding = '/onboarding';
  static const passport = '/passport';

  /// Creative CV / EPK (P2-M7): pick a format, preview, download a PDF, share a revocable link.
  static const cv = '/cv';
  static const portfolio = '/portfolio';
  static const projectEdit = '/portfolio/:id/edit';
  static const skills = '/skills';
  static const experience = '/experience';
  static const achievements = '/achievements';
  static const services = '/services';
  static const devGallery = '/dev/gallery';

  // The five tab roots (the bottom bar).
  static const home = '/home';
  static const explore = '/explore';
  static const community = '/community';
  static const opportunities = '/opportunities';
  static const profile = '/profile';
  static const settings = '/settings';

  // Detail screens (no tab bar). Parameter names are used by the router.
  static const creative = '/creatives/:handle';
  static const project = '/projects/:id';
  static const opportunity = '/opportunities/:id';

  /// A category (or every opportunity) as a list, and the member's own saved, applied and completed ones.
  /// Both are registered ahead of [opportunity] so they are never read as an id.
  static const opportunitiesList = '/opportunities/browse';
  static const myOpportunities = '/opportunities/mine';
  static const course = '/learning/courses/:id';
  static const lesson = '/learning/lessons/:id';

  /// Skill Labs: the hub, the member's own learning, and one category. Fixed paths register before the
  /// `/learning/courses/:id` detail routes.
  static const learning = '/learning';
  static const learningMine = '/learning/mine';
  static const learningCategory = '/learning/categories/:slug';
  static const listing = '/marketplace/listings/:id';

  /// The marketplace (P2-M3). Fixed paths register ahead of the parameterised ones so they are never read as an id.
  static const marketplace = '/marketplace';
  static const marketplaceBrowse = '/marketplace/browse';
  static const myListings = '/marketplace/mine';
  static const listingNew = '/marketplace/new';
  static const listingEdit = '/marketplace/mine/:id';
  static const enquiries = '/marketplace/enquiries';
  static const enquiry = '/marketplace/enquiries/:id';
  static const seller = '/marketplace/sellers/:id';
  static const mentor = '/mentors/:id';

  /// Mentorship (P2-M4): the hub, the directory, the application, and the mentor's own tools. Fixed paths only, so
  /// none can be read as the `/mentors/:id` detail route.
  static const mentorship = '/mentorship';
  static const mentorDirectory = '/mentorship/mentors';
  static const mentorApply = '/mentorship/apply';
  static const mentorTools = '/mentorship/tools';
  static const mentorAvailability = '/mentorship/tools/availability';
  static const mentorSessionTypes = '/mentorship/tools/sessions';
  static const mentorProfileEdit = '/mentorship/tools/profile';
  static const mentorRequests = '/mentorship/tools/requests';

  /// One mentor's profile.
  static String mentorPath(String id) => '/mentors/${Uri.encodeComponent(id)}';

  /// The premium gate a Free member sees from "Unlock mentorship with Pro".
  static const mentorPremium = '/mentors/:id/pro';
  static String mentorPremiumPath(String id) =>
      '/mentors/${Uri.encodeComponent(id)}/pro';
  static const article = '/articles/:slug';
  static const group = '/groups/:id';
  static const post = '/posts/:id';
  static const compose = '/compose';

  /// The payment screen (P2-M1). Open it with `context.push<PaymentOutcome>(Routes.pay, extra: PaymentRequest(...))`.
  static const pay = '/pay';
  static const notifications = '/notifications';
  static const search = '/search';
  static const articles = '/articles';

  /// People to meet, the connections lists and blocked people (Community -> People).
  static const creatives = '/creatives';
  static const connections = '/connections';
  static const blocked = '/blocked';

  /// Activity (P1-M11): where the member left off, the notifications list, saved things and applications.
  static const activity = '/activity';
  static const saved = '/saved';
  static const applications = '/applications';

  /// Settings sub-screens. The legal documents here are the signed-in reader; `/legal/:type` stays the public one.
  static const accountSettings = '/settings/account';
  static const privacySettings = '/settings/privacy';
  static const notificationSettings = '/settings/notifications';
  static const security = '/settings/security';
  static const help = '/settings/help';
  static const helpArticle = '/settings/help/:slug';
  static const legalList = '/settings/legal';
  static const legalDocument = '/settings/legal/:type';
  static const membership = '/settings/membership';
  static const deleteAccount = '/settings/delete';

  /// A deactivated account in its 30-day grace period is offered "Restore account" here instead of Home.
  static const restore = '/restore';

  /// The second step of sign-in on a new device (the API answered `TWO_STEP_REQUIRED`).
  static const twoStep = '/two-step';

  /// The connections lists. [list] is `connected` (default), `received` or `sent`.
  static String connectionsPath({String? list}) =>
      list == null ? connections : '$connections?list=$list';

  /// Generic "coming soon" screen. `/soon/p2?name=Marketplace`
  static const soon = '/soon/:phase';

  static String soonPath(String phase, {String? name}) => name == null
      ? '/soon/$phase'
      : '/soon/$phase?name=${Uri.encodeQueryComponent(name)}';

  /// The sign-in family. A signed-in member is sent past these.
  static const authScreens = {
    splash,
    welcome,
    signup,
    signin,
    verify,
    forgot,
    reset,
  };

  static String legalPath(String type) => '/legal/$type';

  /// A creative's profile. [preview] is the owner's "Public view" of their own page.
  static String creativePath(String handle, {bool preview = false}) =>
      '/creatives/${Uri.encodeComponent(handle)}${preview ? '?preview=1' : ''}';

  /// A post and its discussion thread.
  static String postPath(String id) => '/posts/${Uri.encodeComponent(id)}';

  /// The composer. With a [groupId] (and its [groupName], for the audience row) it posts into that group.
  static String composePath({String? groupId, String? groupName}) {
    final query = [
      if (groupId != null) 'groupId=${Uri.encodeQueryComponent(groupId)}',
      if (groupId != null && groupName != null)
        'groupName=${Uri.encodeQueryComponent(groupName)}',
    ].join('&');
    return query.isEmpty ? compose : '$compose?$query';
  }

  static String listingPath(String id) =>
      '/marketplace/listings/${Uri.encodeComponent(id)}';

  static String sellerPath(String id) =>
      '/marketplace/sellers/${Uri.encodeComponent(id)}';

  static String enquiryPath(String id) =>
      '/marketplace/enquiries/${Uri.encodeComponent(id)}';

  static String listingEditPath(String id) =>
      '/marketplace/mine/${Uri.encodeComponent(id)}';

  /// The browse list. A category, a kind (`SERVICE` or `PRODUCT`) and a search can narrow it.
  static String marketplaceBrowsePath({
    String? categoryId,
    String? categoryName,
    String? type,
    String? q,
  }) {
    final query = [
      if (categoryId != null)
        'categoryId=${Uri.encodeQueryComponent(categoryId)}',
      if (categoryName != null)
        'categoryName=${Uri.encodeQueryComponent(categoryName)}',
      if (type != null) 'type=${Uri.encodeQueryComponent(type)}',
      if (q != null) 'q=${Uri.encodeQueryComponent(q)}',
    ].join('&');
    return query.isEmpty ? marketplaceBrowse : '$marketplaceBrowse?$query';
  }

  /// One opportunity.
  static String opportunityPath(String id) =>
      '/opportunities/${Uri.encodeComponent(id)}';

  /// The opportunities list. [type] is an `OpportunityType` value such as `GRANT`; null lists everything.
  static String opportunitiesListPath({String? type}) => type == null
      ? opportunitiesList
      : '$opportunitiesList?type=${Uri.encodeQueryComponent(type)}';

  /// The member's own opportunities. [tab] is `all` (default), `closing`, `applied`, `completed` or `saved`.
  static String myOpportunitiesPath({String? tab}) =>
      tab == null ? myOpportunities : '$myOpportunities?tab=$tab';

  /// One help article by its slug.
  static String helpArticlePath(String slug) =>
      '/settings/help/${Uri.encodeComponent(slug)}';

  /// One legal document by its type (`TERMS`, `PRIVACY` ...).
  static String legalDocumentPath(String type) =>
      '/settings/legal/${Uri.encodeComponent(type)}';

  /// One article by its slug.
  static String articlePath(String slug) =>
      '/articles/${Uri.encodeComponent(slug)}';

  /// A project. With a [handle] it is that member's project; without, the signed-in member's own.
  /// [preview] (`public` or `members`) is the owner's "Public view" of their own page.
  static String projectPath(String id, {String? handle, String? preview}) {
    final query = [
      if (handle != null) 'handle=${Uri.encodeQueryComponent(handle)}',
      if (preview != null) 'preview=$preview',
    ].join('&');
    return '/projects/${Uri.encodeComponent(id)}${query.isEmpty ? '' : '?$query'}';
  }

  /// The editor for a project, or for a new one when [id] is `new`.
  static String projectEditPath(String id) =>
      '/portfolio/${Uri.encodeComponent(id)}/edit';

  /// One Skill Lab (a course or any other learning item).
  static String coursePath(String id) =>
      '/learning/courses/${Uri.encodeComponent(id)}';

  /// One lesson of a course.
  static String lessonPath(String id) =>
      '/learning/lessons/${Uri.encodeComponent(id)}';

  /// A Skill Labs category, optionally narrowed to one content type (`COURSE`, `TUTORIAL` ...).
  static String learningCategoryPath(String slug, {String? type}) {
    final base = '/learning/categories/${Uri.encodeComponent(slug)}';
    return type == null ? base : '$base?type=${Uri.encodeQueryComponent(type)}';
  }

  /// The member's own learning. [tab] is `active` (default), `completed` or `saved`.
  static String learningMinePath({String? tab}) =>
      tab == null ? learningMine : '$learningMine?tab=$tab';

  /// Paths a signed-out member may open.
  static bool isPublic(String path, {required bool devTools}) {
    if (authScreens.contains(path) && path != splash) return true;
    if (path.startsWith('/legal/')) return true;
    if (devTools && path == devGallery) return true;
    return false;
  }
}
