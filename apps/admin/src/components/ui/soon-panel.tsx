import { phaseLabel, type NavSection } from '@/lib/nav';

/** Placeholder for sections that are specified but not built yet. Never a dead page: it says what and when. */
export function SoonPanel({ section }: { section: NavSection }) {
  return (
    <section className="card soon" aria-labelledby="soon-title">
      <span className="pill warning">{phaseLabel(section.phase)}</span>
      <h2 id="soon-title">{section.label} is on its way</h2>
      <p className="muted">{section.summary}</p>
    </section>
  );
}
