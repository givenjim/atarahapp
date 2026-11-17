import Link from 'next/link';
import { EventChartCard } from '@/components/ops/event-chart';
import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import {
  analyticsQuery,
  buildCharts,
  EVENT_LABELS,
  EVENT_NAMES,
  MAX_RANGE_DAYS,
  parseRange,
} from '@/lib/ops';
import { getAnalytics } from '@/lib/ops-api';

export const metadata = { title: 'Analytics' };

type SearchParams = Promise<{ from?: string; to?: string; names?: string | string[] }>;

export default async function AnalyticsPage({ searchParams }: { searchParams: SearchParams }) {
  const sp = await searchParams;
  const me = await currentAdmin();
  if (!can(me.permissions, 'analytics.view')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Analytics.
      </div>
    );
  }
  const range = parseRange(sp);
  const { data, error, response } = await getAnalytics(analyticsQuery(range));

  return (
    <>
      <div className="page-head">
        <h1>Analytics</h1>
        <p>
          Daily event counts, by Nairobi date. Events carry no names, contact details or search
          words; members are counted as anonymous daily hashes. Today is counted live.
        </p>
      </div>
      <section className="card" aria-label="Date range and events">
        <form className="filters" role="search" method="get">
          <label className="field">
            From
            <input className="input" type="date" name="from" defaultValue={range.from} required />
          </label>
          <label className="field">
            To
            <input className="input" type="date" name="to" defaultValue={range.to} required />
          </label>
          <fieldset className="checks">
            <legend>Events (none ticked shows all)</legend>
            {EVENT_NAMES.map((n) => (
              <label key={n}>
                <input
                  type="checkbox"
                  name="names"
                  value={n}
                  defaultChecked={range.names.includes(n)}
                />
                {EVENT_LABELS[n]}
              </label>
            ))}
          </fieldset>
          <button className="button" type="submit">
            Apply
          </button>
          <Link className="button secondary" href="/analytics">
            Last 30 days
          </Link>
        </form>
        <p className="muted notice" style={{ margin: '0 16px 16px' }}>
          Choose up to {MAX_RANGE_DAYS} days.
        </p>
        {range.problem ? (
          <p className="alert notice" role="alert">
            {range.problem} Showing the last 30 days instead.
          </p>
        ) : null}
      </section>
      {!data ? (
        <p className="alert" role="alert">
          {errorOf(error, response).message}
        </p>
      ) : (
        <ul className="charts" aria-label="Events by day">
          {buildCharts(data.data, range.names).map((c) => (
            <EventChartCard key={c.name} chart={c} />
          ))}
        </ul>
      )}
    </>
  );
}
