'use server';

import { revalidatePath } from 'next/cache';
import { api, errorOf } from '@/lib/api';
import { can, currentAdmin } from '@/lib/admin';
import { listTaxonomy } from '@/lib/taxonomy-api';
import { isTaxonomyKind, KIND_INFO, normaliseName, validateItemForm } from '@/lib/taxonomy';

export type TaxonomyResult = { ok: true } | { ok: false; error: string };

export interface SpecialisationOption {
  id: string;
  name: string;
}

const DENIED = 'You do not have permission to manage the taxonomy.';
const BAD_KIND = 'That list does not exist.';

/** The backend enforces `taxonomy.manage` on every call; this only gives a clearer answer sooner. */
async function allowed(): Promise<boolean> {
  const me = await currentAdmin();
  return can(me.permissions, 'taxonomy.manage');
}

function refresh(): void {
  revalidatePath('/taxonomy', 'layout');
}

export async function createTaxonomyItemAction(
  kind: string,
  input: { name: string; icon: string; disciplineId: string },
): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  if (!isTaxonomyKind(kind)) return { ok: false, error: BAD_KIND };
  const info = KIND_INFO[kind];
  const problem = validateItemForm(info, input, 'create');
  if (problem) return { ok: false, error: problem };

  const { error, response } = await api().POST('/api/v1/admin/taxonomy/{kind}', {
    params: { path: { kind } },
    body: {
      name: normaliseName(input.name),
      ...(info.hasIcon ? { icon: input.icon.trim() } : {}),
      ...(info.scoped && input.disciplineId ? { disciplineId: input.disciplineId } : {}),
    },
  });
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

export async function updateTaxonomyItemAction(
  kind: string,
  id: string,
  input: { name?: string; icon?: string; isActive?: boolean },
): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  if (!isTaxonomyKind(kind)) return { ok: false, error: BAD_KIND };
  const info = KIND_INFO[kind];
  if (input.name !== undefined || input.icon !== undefined) {
    const problem = validateItemForm(
      info,
      { name: input.name ?? 'ok', icon: input.icon ?? 'ok', disciplineId: '' },
      'edit',
    );
    if (problem) return { ok: false, error: problem };
  }

  const { error, response } = await api().PATCH('/api/v1/admin/taxonomy/{kind}/{id}', {
    params: { path: { kind, id } },
    body: {
      ...(input.name !== undefined ? { name: normaliseName(input.name) } : {}),
      ...(info.hasIcon && input.icon !== undefined ? { icon: input.icon.trim() } : {}),
      ...(input.isActive !== undefined ? { isActive: input.isActive } : {}),
    },
  });
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

export async function reorderTaxonomyAction(kind: string, ids: string[]): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  if (!isTaxonomyKind(kind)) return { ok: false, error: BAD_KIND };
  const { error, response } = await api().POST('/api/v1/admin/taxonomy/{kind}/reorder', {
    params: { path: { kind } },
    body: { ids },
  });
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

/** Active specialisations of one discipline, for the Merge picker. */
export async function listSpecialisationsAction(
  disciplineId: string,
): Promise<{ ok: true; items: SpecialisationOption[] } | { ok: false; error: string }> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const { data, error, response } = await listTaxonomy('specialisations', {
    disciplineId,
    includeArchived: false,
  });
  if (!data) return { ok: false, error: errorOf(error, response).message };
  return { ok: true, items: data.data.map((s) => ({ id: s.id, name: s.name })) };
}

export async function approveSuggestionAction(id: string, name: string): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const corrected = normaliseName(name);
  const { error, response } = await api().POST(
    '/api/v1/admin/specialisation-suggestions/{id}/approve',
    { params: { path: { id } }, body: corrected ? { name: corrected } : {} },
  );
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

export async function mergeSuggestionAction(
  id: string,
  specialisationId: string,
): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  if (!specialisationId) return { ok: false, error: 'Choose the specialisation to merge into.' };
  const { error, response } = await api().POST(
    '/api/v1/admin/specialisation-suggestions/{id}/merge',
    { params: { path: { id } }, body: { specialisationId } },
  );
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}

export async function rejectSuggestionAction(id: string, note: string): Promise<TaxonomyResult> {
  if (!(await allowed())) return { ok: false, error: DENIED };
  const trimmed = note.trim();
  const { error, response } = await api().POST(
    '/api/v1/admin/specialisation-suggestions/{id}/reject',
    { params: { path: { id } }, body: trimmed ? { note: trimmed } : {} },
  );
  if (!response.ok) return { ok: false, error: errorOf(error, response).message };
  refresh();
  return { ok: true };
}
