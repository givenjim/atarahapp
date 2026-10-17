import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';
import type { TaxonomyKind } from './taxonomy';

export type AdminTaxonomyItem = Schemas['AdminTaxonomyItemDto'];

type ListResult = {
  data?: { data: AdminTaxonomyItem[] };
  error?: unknown;
  response: Response;
};

/**
 * GET /admin/taxonomy/{kind}. The generated schema gives this operation the id `list`, which the sessions
 * endpoint also uses, so the typed client resolves it to the wrong response type. This wrapper restores the
 * right types until the backend gives the operation a unique id (the call itself is unchanged).
 */
export async function listTaxonomy(
  kind: TaxonomyKind,
  query: { disciplineId?: string; includeArchived?: boolean } = {},
): Promise<ListResult> {
  const client = api() as unknown as {
    GET: (
      path: '/api/v1/admin/taxonomy/{kind}',
      init: { params: { path: { kind: string }; query: typeof query } },
    ) => Promise<ListResult>;
  };
  return client.GET('/api/v1/admin/taxonomy/{kind}', { params: { path: { kind }, query } });
}
