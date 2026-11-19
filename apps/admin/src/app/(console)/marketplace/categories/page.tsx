import { errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listCategories } from '@/lib/marketplace-api';
import { CategoryManager } from '../marketplace-actions-ui';

export const metadata = { title: 'Marketplace categories' };

export default async function CategoriesPage() {
  const me = await currentAdmin();
  if (!can(me.permissions, 'category.manage')) {
    return (
      <div className="card empty" role="alert">
        You do not have access to marketplace categories. They are managed by content admins.
      </div>
    );
  }
  const { data, error, response } = await listCategories();
  return (
    <>
      <div className="page-head">
        <h1>Categories</h1>
        <p>
          Sellers pick one category per listing and buyers browse by it. A category with live
          listings cannot be hidden until they are moved or paused.
        </p>
      </div>
      <section className="card" aria-label="Categories">
        {!data ? (
          <p className="alert" role="alert" style={{ margin: 16 }}>
            {errorOf(error, response).message}
          </p>
        ) : (
          <CategoryManager categories={data.data} />
        )}
      </section>
    </>
  );
}
