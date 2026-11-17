import 'server-only';
import { listTaxonomy } from './taxonomy-api';
import { listCounties, listProviders } from './opportunities-api';

export interface Choice {
  id: string;
  name: string;
}

/**
 * The lists the opportunity form chooses from. Each is fetched on its own and falls back to empty, so a missing
 * permission (the taxonomy needs `taxonomy.manage`) leaves that picker empty instead of breaking the page.
 */
export async function loadFormOptions(): Promise<{
  providers: Choice[];
  counties: Choice[];
  disciplines: Choice[];
  skills: Choice[];
}> {
  const [providers, counties, disciplines, skills] = await Promise.all([
    listProviders({ page: 1, limit: 100 }).catch(() => null),
    listCounties().catch(() => null),
    listTaxonomy('disciplines').catch(() => null),
    listTaxonomy('skills').catch(() => null),
  ]);
  const pick = (items: Array<{ id: string; name: string }> | undefined): Choice[] =>
    (items ?? []).map((i) => ({ id: i.id, name: i.name }));
  return {
    providers: pick(providers?.data?.data),
    counties: pick(counties?.data?.data),
    disciplines: pick(disciplines?.data?.data.filter((d) => d.isActive)),
    skills: pick(skills?.data?.data.filter((s) => s.isActive)),
  };
}
