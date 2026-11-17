import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getOpportunity } from '@/lib/opportunities-api';
import {
  canVerify,
  formatDeadline,
  linkMeta,
  RULE_LABELS,
  statusMeta,
  titleCase,
  trustMeta,
  type RuleType,
} from '@/lib/opportunities';
import { OpportunityActions } from './opportunity-actions';

export const metadata = { title: 'Opportunity' };

export default async function OpportunityPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  const { data, response } = await getOpportunity(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the opportunity (${response.status}).`);
  }
  const o = data.data;
  const value =
    o.valueMin !== null || o.valueMax !== null
      ? `${o.valueCurrency ?? 'KES'} ${o.valueMin ?? ''}${o.valueMin !== null && o.valueMax !== null ? ' to ' : ''}${o.valueMax ?? ''}`
      : (o.valueText ?? '—');

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/opportunities">← All opportunities</Link>
        </p>
        <h1>{o.title}</h1>
        <p>
          <span className={`pill ${statusMeta(o.status).tone}`.trim()}>
            {statusMeta(o.status).label}
          </span>{' '}
          <span className={`pill ${trustMeta(o.trust).tone}`.trim()}>
            {trustMeta(o.trust).label}
          </span>
        </p>
      </div>
      <section className="card" aria-label="Opportunity">
        <dl className="facts">
          <dt>Provider</dt>
          <dd>{o.provider.name}</dd>
          <dt>Type</dt>
          <dd>{titleCase(o.type)}</dd>
          <dt>Deadline</dt>
          <dd>{formatDeadline(o.deadlineAt)}</dd>
          <dt>Value</dt>
          <dd>{value}</dd>
          <dt>Where</dt>
          <dd>
            {titleCase(o.workMode)}
            {o.countyName ? ` · ${o.countyName}` : ''}
          </dd>
          <dt>Applying</dt>
          <dd>
            {o.applicationMethod === 'EMAIL'
              ? `By email: ${o.applicationEmail ?? '—'}`
              : `${o.applicationUrl ?? '—'}${o.applicationDomain ? ` (${o.applicationDomain})` : ''}`}
          </dd>
          <dt>Link health</dt>
          <dd>
            <span className={`pill ${linkMeta(o.linkStatus).tone}`.trim()}>
              {linkMeta(o.linkStatus).label}
            </span>
            {o.lastCheckedAt ? (
              <span className="muted"> · checked {o.lastCheckedAt.slice(0, 10)}</span>
            ) : null}
          </dd>
          <dt>Featured</dt>
          <dd>
            {o.featuredUntil && new Date(o.featuredUntil) > new Date()
              ? `Until ${formatDeadline(o.featuredUntil)}`
              : 'No'}
          </dd>
          <dt>Published</dt>
          <dd>{o.publishedAt ? o.publishedAt.slice(0, 10) : 'Not yet'}</dd>
          <dt>Tracking</dt>
          <dd>{o.trackerCount} members</dd>
          <dt>Summary</dt>
          <dd>{o.summary}</dd>
          <dt>About</dt>
          <dd style={{ whiteSpace: 'pre-wrap' }}>{o.about || '—'}</dd>
          <dt>Requirements</dt>
          <dd>{o.requirements.length > 0 ? o.requirements.join(' · ') : '—'}</dd>
          <dt>Benefits</dt>
          <dd>{o.benefits.length > 0 ? o.benefits.join(' · ') : '—'}</dd>
          <dt>Eligibility rules</dt>
          <dd>
            {o.rules.length === 0 ? (
              '—'
            ) : (
              <ul className="plain-list">
                {o.rules.map((r) => (
                  <li key={r.id}>
                    {r.label}{' '}
                    <span className="muted">
                      ({RULE_LABELS[r.ruleType as RuleType] ?? r.ruleType}
                      {r.isBlocking ? '' : ', advice only'})
                    </span>
                  </li>
                ))}
              </ul>
            )}
          </dd>
        </dl>
        <div style={{ padding: '0 20px 20px' }}>
          <Link className="button secondary" href={`/opportunities/${o.id}/edit`}>
            Edit
          </Link>
        </div>
      </section>
      <OpportunityActions
        id={o.id}
        title={o.title}
        status={o.status}
        trust={o.trust}
        featured={Boolean(o.featuredUntil && new Date(o.featuredUntil) > new Date())}
        canVerify={canVerify(me.permissions)}
      />
      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=opportunity&entityId=${o.id}`}>
            View this opportunity&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
