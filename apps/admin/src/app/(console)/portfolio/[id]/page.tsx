import Link from 'next/link';
import { notFound } from 'next/navigation';
import { can, currentAdmin } from '@/lib/admin';
import { isWebUrl } from '@/lib/portfolio';
import { getAdminProject } from '@/lib/portfolio-api';
import { ProjectActions } from './project-actions';

export const metadata = { title: 'Portfolio project' };

const when = (iso: string) => new Date(iso).toLocaleString('en-KE');

export default async function PortfolioProjectPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const me = await currentAdmin();
  if (!can(me.permissions, 'moderation.act')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Portfolio.
      </div>
    );
  }
  const { data, response } = await getAdminProject(id);
  if (!data) {
    if (response.status === 404 || response.status === 400) notFound();
    throw new Error(`Could not load the project (${response.status}).`);
  }
  const p = data.data;

  return (
    <>
      <div className="page-head">
        <p>
          <Link href="/portfolio">← All projects</Link>
        </p>
        <h1>{p.title}</h1>
      </div>
      <section className="card" aria-label="Project">
        <dl className="facts">
          <dt>Status</dt>
          <dd>
            <span className={`pill ${p.hidden ? 'danger' : 'success'}`}>
              {p.hidden ? 'Hidden' : 'Visible'}
            </span>
            {p.hidden && p.hiddenReason ? <span className="muted"> · {p.hiddenReason}</span> : null}
            {p.hidden && p.hiddenAt ? <span className="muted"> · {when(p.hiddenAt)}</span> : null}
          </dd>
          <dt>Owner</dt>
          <dd>
            <Link href={`/users/${p.ownerUserId}`}>{p.ownerName}</Link>
            {p.ownerHandle ? <span className="muted"> · @{p.ownerHandle}</span> : null}
          </dd>
          <dt>Category</dt>
          <dd>{p.category.toLowerCase()}</dd>
          <dt>Visibility</dt>
          <dd>{p.visibility.toLowerCase()}</dd>
          {p.discipline ? (
            <>
              <dt>Discipline</dt>
              <dd>{p.discipline.name}</dd>
            </>
          ) : null}
          {p.role ? (
            <>
              <dt>Owner&apos;s role</dt>
              <dd>{p.role}</dd>
            </>
          ) : null}
          {p.client ? (
            <>
              <dt>Client</dt>
              <dd>{p.client}</dd>
            </>
          ) : null}
          {p.publishedAt ? (
            <>
              <dt>Published</dt>
              <dd>{when(p.publishedAt)}</dd>
            </>
          ) : null}
          <dt>Updated</dt>
          <dd>{when(p.updatedAt)}</dd>
        </dl>
      </section>

      <section className="card" aria-label="Description" style={{ padding: 20 }}>
        <h2>Description</h2>
        <p style={{ whiteSpace: 'pre-wrap' }}>{p.description || 'No description.'}</p>
        {p.outcome ? (
          <>
            <h2>Outcome</h2>
            <p style={{ whiteSpace: 'pre-wrap' }}>{p.outcome}</p>
          </>
        ) : null}
        {p.skills.length ? (
          <p className="muted">Skills: {p.skills.map((s) => s.name).join(', ')}</p>
        ) : null}
      </section>

      <section className="card" aria-label="Media" style={{ padding: 20 }}>
        <h2>Media ({p.media.length})</h2>
        {p.media.length === 0 ? (
          <p className="empty">No media.</p>
        ) : (
          <ul style={{ display: 'flex', flexWrap: 'wrap', gap: 12, listStyle: 'none', padding: 0 }}>
            {p.media.map((m) => {
              const preview = m.thumbnailUrl ?? (m.kind === 'IMAGE' ? m.url : null);
              return (
                <li key={m.id} style={{ width: 160 }}>
                  {preview ? (
                    // eslint-disable-next-line @next/next/no-img-element
                    <img
                      src={preview}
                      alt={m.caption ?? `${m.kind.toLowerCase()} in ${p.title}`}
                      style={{ width: 160, height: 120, objectFit: 'cover', borderRadius: 8 }}
                    />
                  ) : null}
                  <div className="muted">
                    {m.kind.toLowerCase()}
                    {m.status !== 'READY'
                      ? ` · ${m.status.replaceAll('_', ' ').toLowerCase()}`
                      : ''}
                  </div>
                  {m.caption ? <div>{m.caption}</div> : null}
                  {m.url && isWebUrl(m.url) ? (
                    <a href={m.url} target="_blank" rel="noopener noreferrer">
                      Open original
                    </a>
                  ) : null}
                </li>
              );
            })}
          </ul>
        )}
      </section>

      <section className="card" aria-label="Links and collaborators" style={{ padding: 20 }}>
        <h2>Links ({p.links.length})</h2>
        {p.links.length === 0 ? (
          <p className="empty">No links.</p>
        ) : (
          <ul>
            {p.links.map((l) => (
              <li key={l.id}>
                {isWebUrl(l.url) ? (
                  <a href={l.url} target="_blank" rel="noopener noreferrer">
                    {l.label}
                  </a>
                ) : (
                  l.label
                )}{' '}
                <span className="muted">{l.url}</span>
              </li>
            ))}
          </ul>
        )}
        <h2>Collaborators ({p.collaborators.length})</h2>
        {p.collaborators.length === 0 ? (
          <p className="empty">No collaborators.</p>
        ) : (
          <ul>
            {p.collaborators.map((c) => (
              <li key={c.id}>
                {c.name}
                {c.handle ? <span className="muted"> @{c.handle}</span> : null}
                {c.role ? <span className="muted"> · {c.role}</span> : null}
                <span className="muted"> · {c.status.toLowerCase()}</span>
              </li>
            ))}
          </ul>
        )}
      </section>

      <ProjectActions id={p.id} title={p.title} hidden={p.hidden} />
      {can(me.permissions, 'audit.view') ? (
        <p>
          <Link href={`/audit-logs?entityType=project&entityId=${p.id}`}>
            View this project&apos;s audit history
          </Link>
        </p>
      ) : null}
    </>
  );
}
