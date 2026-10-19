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

  /// Paths a signed-out member may open.
  static bool isPublic(String path, {required bool devTools}) {
    if (authScreens.contains(path) && path != splash) return true;
    if (path.startsWith('/legal/')) return true;
    if (devTools && path == devGallery) return true;
    return false;
  }
}
