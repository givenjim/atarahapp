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

  // Detail screens (no tab bar). Parameter names are used by the router.
  static const creative = '/creatives/:handle';
  static const project = '/projects/:id';
  static const opportunity = '/opportunities/:id';
  static const course = '/learning/courses/:id';
  static const lesson = '/learning/lessons/:id';
  static const listing = '/marketplace/listings/:id';
  static const mentor = '/mentors/:id';
  static const article = '/articles/:slug';
  static const group = '/groups/:id';
  static const post = '/posts/:id';
  static const notifications = '/notifications';
  static const search = '/search';
  static const articles = '/articles';

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

  /// Paths a signed-out member may open.
  static bool isPublic(String path, {required bool devTools}) {
    if (authScreens.contains(path) && path != splash) return true;
    if (path.startsWith('/legal/')) return true;
    if (devTools && path == devGallery) return true;
    return false;
  }
}
