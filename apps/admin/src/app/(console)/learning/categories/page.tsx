import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listCategories } from '@/lib/learning-api';
import { groupCategories, groupLabel } from '@/lib/learning';
import { CategoryFormDialog } from './category-form';

export const metadata = { title: 'Learning categories' };

export default async function CategoriesPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'learning.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to Learning.
      </div>
    );
  }
  const { data, error, response } = await listCategories();
  if (!data) {
    return (
      <p className="alert" role="alert">
        {errorOf(error, response).message}
      </p>
    );
  }
  const groups = groupCategories(data.data);

  return (
    <>
      <div className="page-head">
        <h1>Categories</h1>
        <p>
          Members browse Skill Labs by category, in three groups. A category that is switched off
          disappears from the app but keeps its items.
        </p>
      </div>
      <section className="card" aria-label="Categories" style={{ padding: 20 }}>
        <div className="toolbar">
          <span />
          <CategoryFormDialog />
        </div>
        {groups.map((g) => (
          <div key={g.group} style={{ marginTop: 16 }}>
            <h2>{groupLabel(g.group)}</h2>
            {g.items.length === 0 ? (
              <p className="empty">No categories in this group.</p>
            ) : (
              <div className="table-wrap">
                <table className="data">
                  <caption className="sr-only" style={{ position: 'absolute', left: -9999 }}>
                    {groupLabel(g.group)} categories
                  </caption>
                  <thead>
                    <tr>
                      <th scope="col">Name</th>
                      <th scope="col">Order</th>
                      <th scope="col">Items</th>
                      <th scope="col">Status</th>
                      <th scope="col">
                        <span className="sr-only">Actions</span>
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.items.map((c) => (
                      <tr key={c.id}>
                        <td>{c.name}</td>
                        <td>{c.sortOrder}</td>
                        <td>{c.contentCount}</td>
                        <td>
                          <span className={`pill ${c.isActive ? 'success' : 'muted'}`}>
                            {c.isActive ? 'Active' : 'Off'}
                          </span>
                        </td>
                        <td>
                          <CategoryFormDialog
                            id={c.id}
                            initial={{
                              name: c.name,
                              group: c.group,
                              sortOrder: String(c.sortOrder),
                              isActive: c.isActive,
                            }}
                          />
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </div>
        ))}
      </section>
    </>
  );
}
