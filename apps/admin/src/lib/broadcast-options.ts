import 'server-only';
import { listCounties } from './opportunities-api';
import { listTaxonomy } from './taxonomy-api';

export interface Choice {
  id: string;
  name: string;
}

/**
 * The audience pickers of the broadcast form. Each list is fetched on its own and falls back to empty, so a missing
 * permission (the taxonomy needs `taxonomy.manage`) leaves that picker empty instead of breaking the page.
 */
export async function loadAudienceOptions(): Promise<{
  disciplines: Choice[];
  counties: Choice[];
}> {
  const [disciplines, counties] = await Promise.all([
    listTaxonomy('disciplines').catch(() => null),
    listCounties().catch(() => null),
  ]);
  const pick = (items: Array<{ id: string; name: string }> | undefined): Choice[] =>
    (items ?? []).map((i) => ({ id: i.id, name: i.name }));
  return {
    disciplines: pick(disciplines?.data?.data.filter((d) => d.isActive)),
    counties: pick(counties?.data?.data),
  };
}
