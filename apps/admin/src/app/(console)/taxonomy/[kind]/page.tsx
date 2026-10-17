import { notFound } from 'next/navigation';
import { errorOf } from '@/lib/api';
import { listTaxonomy } from '@/lib/taxonomy-api';
import { isTaxonomyKind, KIND_INFO } from '@/lib/taxonomy';
import { TaxonomyManager, type DisciplineOption } from './taxonomy-manager';

type SearchParams = Promise<{ disciplineId?: string }>;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export default async function TaxonomyKindPage({
  params,
  searchParams,
}: {
  params: Promise<{ kind: string }>;
  searchParams: SearchParams;
}) {
  const { kind } = await params;
  if (!isTaxonomyKind(kind)) notFound();
  const info = KIND_INFO[kind];
  const sp = await searchParams;
  const disciplineId =
    info.scoped && sp.disciplineId && UUID.test(sp.disciplineId) ? sp.disciplineId : undefined;

  const [list, disciplines] = await Promise.all([
    listTaxonomy(kind, { includeArchived: true, disciplineId }),
    info.scoped ? listTaxonomy('disciplines', { includeArchived: true }) : null,
  ]);

  if (!list.data) {
    return (
      <p className="alert" role="alert" style={{ margin: 16 }}>
        {errorOf(list.error, list.response).message}
      </p>
    );
  }
  if (disciplines && !disciplines.data) {
    return (
      <p className="alert" role="alert" style={{ margin: 16 }}>
        {errorOf(disciplines.error, disciplines.response).message}
      </p>
    );
  }
  const disciplineOptions: DisciplineOption[] = (disciplines?.data?.data ?? []).map((d) => ({
    id: d.id,
    name: d.name,
    isActive: d.isActive,
  }));

  return (
    <TaxonomyManager
      kind={kind}
      items={list.data.data}
      disciplines={disciplineOptions}
      disciplineId={disciplineId}
    />
  );
}
