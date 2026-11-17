import 'server-only';
import { embedHosts, listCategories } from './learning-api';
import { listTaxonomy } from './taxonomy-api';

export interface Choice {
  id: string;
  name: string;
}

export interface CategoryChoice extends Choice {
  group: string;
  isActive: boolean;
}

/**
 * The lists the content form chooses from. Each is fetched on its own and falls back to empty, so a missing
 * permission (the taxonomy needs `taxonomy.manage`, which a content admin holds) leaves that picker empty instead of
 * breaking the page.
 */
export async function loadLearningOptions(): Promise<{
  categories: CategoryChoice[];
  disciplines: Choice[];
  skills: Choice[];
  hosts: string[];
}> {
  const [categories, disciplines, skills, hosts] = await Promise.all([
    listCategories().catch(() => null),
    listTaxonomy('disciplines').catch(() => null),
    listTaxonomy('skills').catch(() => null),
    embedHosts().catch(() => null),
  ]);
  const pick = (items: Array<{ id: string; name: string }> | undefined): Choice[] =>
    (items ?? []).map((i) => ({ id: i.id, name: i.name }));
  return {
    categories: (categories?.data?.data ?? []).map((c) => ({
      id: c.id,
      name: c.name,
      group: c.group,
      isActive: c.isActive,
    })),
    disciplines: pick(disciplines?.data?.data.filter((d) => d.isActive)),
    skills: pick(skills?.data?.data.filter((s) => s.isActive)),
    hosts: hosts?.data?.data.hosts ?? [],
  };
}
