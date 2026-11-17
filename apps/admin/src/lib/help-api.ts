import 'server-only';
import type { Schemas } from '@atarah/api-contracts';
import { api } from './api';

export type AdminHelpArticle = Schemas['AdminHelpArticleDto'];
export type AdminFaq = Schemas['AdminFaqDto'];
export type AdminLegal = Schemas['AdminLegalDto'];

export type Result<T> = { data?: T; error?: unknown; response: Response };
type List<T> = { data: T[]; meta?: unknown };

interface Client {
  GET: (path: string, init: unknown) => Promise<Result<unknown>>;
  POST: (path: string, init: unknown) => Promise<Result<unknown>>;
  PATCH: (path: string, init: unknown) => Promise<Result<unknown>>;
  DELETE: (path: string, init: unknown) => Promise<Result<unknown>>;
}

/** The generated schema reuses generic operation ids across modules, so these wrappers pin the right types. */
const client = () => api() as unknown as Client;
const P = '/api/v1/admin';
const path = (params: Record<string, string>) => ({ params: { path: params } });

// ---- help articles ----

export const listHelpArticles = async (query: { page: number; limit: number; q?: string }) =>
  (await client().GET(`${P}/help-articles`, { params: { query } })) as Result<
    List<AdminHelpArticle>
  >;

type ArticleResult = Result<{ data: AdminHelpArticle }>;

export const getHelpArticle = async (id: string) =>
  (await client().GET(`${P}/help-articles/{id}`, path({ id }))) as ArticleResult;

export const createHelpArticle = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/help-articles`, { body })) as ArticleResult;

export const updateHelpArticle = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/help-articles/{id}`, { ...path({ id }), body })) as ArticleResult;

export const deleteHelpArticle = async (id: string) =>
  (await client().DELETE(`${P}/help-articles/{id}`, path({ id }))) as Result<unknown>;

// ---- FAQ ----

export const listFaq = async (query: { page: number; limit: number; q?: string }) =>
  (await client().GET(`${P}/faq`, { params: { query } })) as Result<List<AdminFaq>>;

type FaqResult = Result<{ data: AdminFaq }>;

export const createFaq = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/faq`, { body })) as FaqResult;

export const updateFaq = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/faq/{id}`, { ...path({ id }), body })) as FaqResult;

export const deleteFaq = async (id: string) =>
  (await client().DELETE(`${P}/faq/{id}`, path({ id }))) as Result<unknown>;

// ---- legal documents ----

export const listLegalDocuments = async (type?: string) =>
  (await client().GET(`${P}/legal-documents`, {
    params: { query: type ? { type } : {} },
  })) as Result<{ data: AdminLegal[] }>;

type LegalResult = Result<{ data: AdminLegal }>;

export const createLegalVersion = async (body: Record<string, unknown>) =>
  (await client().POST(`${P}/legal-documents`, { body })) as LegalResult;

export const updateLegalDraft = async (id: string, body: Record<string, unknown>) =>
  (await client().PATCH(`${P}/legal-documents/{id}`, { ...path({ id }), body })) as LegalResult;

export const publishLegal = async (id: string, effectiveAt?: string) =>
  (await client().POST(`${P}/legal-documents/{id}/publish`, {
    ...path({ id }),
    body: effectiveAt ? { effectiveAt } : {},
  })) as LegalResult;
