import { type StoreLinks } from '@/lib/site';

export function JoinCta({ links }: { links: StoreLinks }) {
  if (!links.enabled) {
    return (
      <p className="notice" role="status">
        The Atarah app is launching soon
      </p>
    );
  }
  return (
    <div className="cta-row">
      {links.playStore ? (
        <a className="button" href={links.playStore} rel="noopener">
          Join on Google Play
        </a>
      ) : null}
      {links.appStore ? (
        <a className="button" href={links.appStore} rel="noopener">
          Join on the App Store
        </a>
      ) : null}
    </div>
  );
}
