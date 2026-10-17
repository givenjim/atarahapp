import { notFound } from 'next/navigation';
import { SoonPanel } from '@/components/ui/soon-panel';
import { can, currentAdmin } from '@/lib/admin';
import { NAV, sectionBySlug } from '@/lib/nav';

export const dynamicParams = false;

/** Live sections have their own routes; this page serves only the sections that are not built yet. */
export const generateStaticParams = () =>
  NAV.filter((s) => s.phase !== 'live' && s.slug !== 'dashboard').map((s) => ({ section: s.slug }));

export default async function SectionPage({ params }: { params: Promise<{ section: string }> }) {
  const { section: slug } = await params;
  const section = sectionBySlug(slug);
  if (!section || section.phase === 'live') notFound();
  const me = await currentAdmin();
  if (!can(me.permissions, section.permission)) {
    return (
      <div className="card empty" role="alert">
        You do not have access to {section.label}.
      </div>
    );
  }
  return (
    <>
      <div className="page-head">
        <h1>{section.label}</h1>
      </div>
      <SoonPanel section={section} />
    </>
  );
}
