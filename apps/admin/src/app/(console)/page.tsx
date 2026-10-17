import { SoonPanel } from '@/components/ui/soon-panel';
import { sectionBySlug } from '@/lib/nav';

export const metadata = { title: 'Dashboard' };

export default function DashboardPage() {
  const section = sectionBySlug('dashboard')!;
  return (
    <>
      <div className="page-head">
        <h1>Dashboard</h1>
      </div>
      <SoonPanel section={section} />
    </>
  );
}
