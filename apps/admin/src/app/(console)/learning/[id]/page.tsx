import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { getContent } from '@/lib/learning-api';
import { loadLearningOptions } from '@/lib/learning-options';
import {
  accessLabel,
  deliveryLabel,
  groupLabel,
  linkMeta,
  sourceLabel,
  statusMeta,
  titleCase,
  typeLabel,
} from '@/lib/learning';
import { ContentActions } from './content-actions';
import { LessonsManager } from './lessons-manager';
import { OverrideDialog } from './override-dialog';

export const metadata = { title: 'Skill Lab' };

export default async function ContentPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const [{ data, response }, options] = await Promise.all([getContent(id), loadLearningOptions()]);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the item (${response.status}).`);
  }
  const c = data.data;
  const isCourse = c.type === 'COURSE';

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/learning">← All Skill Labs</Link>
        </p>
        <h1>{c.title}</h1>
        <p>
          <span className={`pill ${statusMeta(c.status).tone}`.trim()}>
            {statusMeta(c.status).label}
          </span>{' '}
          <span className="pill">{typeLabel(c.type)}</span>{' '}
          {c.featured ? <span className="pill success">Featured</span> : null}
        </p>
      </div>
      <section className="card" aria-label="Skill Lab">
        <dl className="facts">
          <dt>Category</dt>
          <dd>
            {c.category.name} <span className="muted">({groupLabel(c.category.group)})</span>
          </dd>
          <dt>Source</dt>
          <dd>{sourceLabel(c.source)}</dd>
          <dt>Delivery</dt>
          <dd>{deliveryLabel(c.delivery)}</dd>
          <dt>Access</dt>
          <dd>{accessLabel(c.access)}</dd>
          <dt>Level</dt>
          <dd>{titleCase(c.level)}</dd>
          <dt>Duration</dt>
          <dd>{c.durationMinutes > 0 ? `${c.durationMinutes} min` : '—'}</dd>
          <dt>Provider</dt>
          <dd>{c.providerName ?? '—'}</dd>
          <dt>Learners</dt>
          <dd>{c.enrolmentCount}</dd>
          {c.delivery === 'EXTERNAL_LINK' ? (
            <>
              <dt>Opens</dt>
              <dd>{c.externalUrl ?? 'No address yet (needed before publishing)'}</dd>
            </>
          ) : null}
          {c.delivery === 'EMBEDDED' && !isCourse ? (
            <>
              <dt>Embedded player</dt>
              <dd>{c.embedUrl ?? 'No player yet (needed before publishing)'}</dd>
            </>
          ) : null}
          {c.delivery !== 'NATIVE' ? (
            <>
              <dt>Link health</dt>
              <dd>
                <span className={`pill ${linkMeta(c.linkStatus).tone}`.trim()}>
                  {linkMeta(c.linkStatus).label}
                </span>
                {c.lastCheckedAt ? (
                  <span className="muted"> · checked {c.lastCheckedAt.slice(0, 10)}</span>
                ) : null}
              </dd>
            </>
          ) : null}
          {isCourse ? (
            <>
              <dt>Lessons</dt>
              <dd>
                {c.lessons.length} · {c.sequential ? 'unlock one after another' : 'all open'}
              </dd>
            </>
          ) : null}
          <dt>Published</dt>
          <dd>{c.publishedAt ? c.publishedAt.slice(0, 10) : 'Not yet'}</dd>
          <dt>Summary</dt>
          <dd>{c.summary}</dd>
          <dt>What you’ll learn</dt>
          <dd>{c.whatYouLearn.length > 0 ? c.whatYouLearn.join(' · ') : '—'}</dd>
          <dt>Who it’s for</dt>
          <dd>{c.whoItsFor ?? '—'}</dd>
        </dl>
        <div style={{ padding: '0 20px 20px' }} className="row-actions">
          <Link className="button secondary" href={`/learning/${c.id}/edit`}>
            Edit
          </Link>
          {isCourse ? <OverrideDialog courseId={c.id} lessons={c.lessons} /> : null}
        </div>
      </section>

      <ContentActions id={c.id} title={c.title} status={c.status} learners={c.enrolmentCount} />

      {isCourse ? (
        <LessonsManager
          courseId={c.id}
          lessons={c.lessons}
          skills={options.skills}
          hosts={options.hosts}
        />
      ) : null}

      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=learning&entityId=${c.id}`}>
            View this item&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
