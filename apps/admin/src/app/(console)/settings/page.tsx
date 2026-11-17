import Link from 'next/link';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { groupSettings } from '@/lib/ops';
import { listFlags, listSettings } from '@/lib/ops-api';
import { FlagSwitch, SettingRow } from './settings-controls';

export const metadata = { title: 'Settings' };

export default async function SettingsPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'settings.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Settings.
      </div>
    );
  }
  const [flags, settings] = await Promise.all([listFlags(), listSettings()]);

  return (
    <>
      <div className="page-head">
        <h1>Settings</h1>
        <p>
          Feature switches and tunable values. Every change needs a fresh authenticator code and is
          recorded in the audit log. A value keeps its kind: text stays text, a number stays a
          number.
        </p>
        <p>
          <Link href="/settings/jobs">Background jobs and failed jobs</Link>
        </p>
      </div>

      <section className="card" aria-labelledby="flags-title">
        <div style={{ padding: '16px 16px 0' }}>
          <h2 id="flags-title" className="section-title">
            Feature flags
          </h2>
        </div>
        {!flags.data ? (
          <p className="alert notice" role="alert">
            {errorOf(flags.error, flags.response).message}
          </p>
        ) : flags.data.data.length === 0 ? (
          <p className="empty">No feature flags.</p>
        ) : (
          flags.data.data.map((f) => <FlagSwitch key={f.key} flag={f} />)
        )}
      </section>

      {!settings.data ? (
        <p className="alert" role="alert">
          {errorOf(settings.error, settings.response).message}
        </p>
      ) : (
        groupSettings(settings.data.data).map((g) => (
          <section key={g.group} className="card" aria-label={`${g.group} settings`}>
            <div style={{ padding: '16px 16px 0' }}>
              <h2 className="section-title">
                {g.group.charAt(0).toUpperCase() + g.group.slice(1)}
              </h2>
            </div>
            {g.items.map((s) => (
              <SettingRow key={s.key} setting={s} />
            ))}
          </section>
        ))
      )}
    </>
  );
}
