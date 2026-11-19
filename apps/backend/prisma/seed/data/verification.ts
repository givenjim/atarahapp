import type { VerificationEvidenceType, VerificationSubjectType } from '@prisma/client';

/**
 * What each verification case type asks for (P2-M6). `evidenceTypes` is the set of evidence that counts towards a row;
 * `minCount` is how many are needed. Rows are created if missing and never overwritten (staff may switch one off).
 */
export interface RequirementDef {
  subjectType: VerificationSubjectType;
  key: string;
  label: string;
  description: string;
  evidenceTypes: VerificationEvidenceType[];
  minCount: number;
}

export const VERIFICATION_REQUIREMENTS: readonly RequirementDef[] = [
  {
    subjectType: 'CREATIVE_IDENTITY',
    key: 'GOVERNMENT_ID',
    label: 'Government ID',
    description: 'Private. Only a reviewer sees it, and it is deleted after the decision. It is never shown on your profile.',
    evidenceTypes: ['GOVERNMENT_ID'],
    minCount: 1,
  },
  {
    subjectType: 'CREATIVE_IDENTITY',
    key: 'PROJECTS',
    label: '3 portfolio projects with your role',
    description: 'Choose three projects from your portfolio that show what you did. Each needs your role filled in.',
    evidenceTypes: ['PORTFOLIO_PROJECT'],
    minCount: 3,
  },
  {
    subjectType: 'CREATIVE_IDENTITY',
    key: 'REFERENCE',
    label: 'One reference from a client or collaborator',
    description: 'We email them a short confirmation request. They are never shown your private details.',
    evidenceTypes: ['REFERENCE'],
    minCount: 1,
  },
  {
    subjectType: 'SKILL',
    key: 'SKILL_EVIDENCE',
    label: 'Evidence of this skill',
    description: 'A project that shows the skill, a certificate, a link to your work, or a reference. One is enough; more helps.',
    evidenceTypes: ['PORTFOLIO_PROJECT', 'DOCUMENT', 'LINK', 'REFERENCE'],
    minCount: 1,
  },
  {
    subjectType: 'SELLER',
    key: 'SELLER_DOCUMENT',
    label: 'Proof of identity or business',
    description: 'A document that shows who is selling.',
    evidenceTypes: ['GOVERNMENT_ID', 'DOCUMENT'],
    minCount: 1,
  },
  {
    subjectType: 'OPPORTUNITY_PROVIDER',
    key: 'PROVIDER_PROOF',
    label: 'Proof of the organisation',
    description: 'A registration document or an official website link.',
    evidenceTypes: ['DOCUMENT', 'LINK'],
    minCount: 1,
  },
  {
    subjectType: 'MENTOR',
    key: 'MENTOR_PROOF',
    label: 'Credentials or work to show',
    description: 'Certificates, a portfolio link or a reference.',
    evidenceTypes: ['DOCUMENT', 'LINK', 'REFERENCE'],
    minCount: 1,
  },
];
