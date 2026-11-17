import { can, currentAdmin } from '@/lib/admin';
import { ImportForm } from './import-form';

export const metadata = { title: 'Import opportunities' };

export default async function ImportPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'opportunity.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Opportunities.
      </div>
    );
  }
  return (
    <>
      <div className="page-head">
        <h1>Import opportunities</h1>
        <p>Bring in many listings at once. You see a report before anything is saved.</p>
      </div>
      <ImportForm />
    </>
  );
}
