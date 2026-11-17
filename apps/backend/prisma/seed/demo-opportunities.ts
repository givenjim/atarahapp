import {
  type OpportunityProviderType,
  type OpportunityRuleType,
  type OpportunityTrust,
  type OpportunityType,
  type Prisma,
  type PrismaClient,
  type VerificationStatus,
  type WorkMode,
} from '@prisma/client';

/**
 * Demo opportunities (development only): providers and listings of every type, each with structured eligibility rules,
 * so the discovery, profile-gap and tracking flows can be tried. Every organisation here is invented; none is a real
 * funder or employer, and everything is flagged `isDemo`. Deadlines are relative to the day the seed runs. Safe to run
 * again: it does nothing when demo opportunities already exist.
 */

interface RuleSeed {
  type: OpportunityRuleType;
  label: string;
  params: Prisma.InputJsonValue;
  blocking?: boolean;
}

interface Listing {
  title: string;
  provider: string;
  type: OpportunityType;
  summary: string;
  about: string;
  requirements: string[];
  benefits: string[];
  /** Whole days from now; null is a rolling deadline. */
  days: number | null;
  county?: string;
  mode?: WorkMode;
  min?: number;
  max?: number;
  valueText?: string;
  disciplines?: string[];
  trust: OpportunityTrust;
  featured?: boolean;
  rules: RuleSeed[];
  daysAgo?: number;
}

const PROVIDERS: ReadonlyArray<{
  name: string;
  type: OpportunityProviderType;
  site: string;
  status: VerificationStatus;
}> = [
  {
    name: 'Nairobi Creative Fund',
    type: 'NGO',
    site: 'https://nairobicreativefund.example.org',
    status: 'VERIFIED',
  },
  {
    name: 'Kilifi Arts Residency',
    type: 'NGO',
    site: 'https://kilifiarts.example.org',
    status: 'VERIFIED',
  },
  {
    name: 'Lakeside Film Collective',
    type: 'STUDIO',
    site: 'https://lakesidefilm.example.org',
    status: 'NOT_SUBMITTED',
  },
  {
    name: 'Savannah Sound Festival',
    type: 'FESTIVAL',
    site: 'https://savannahsound.example.org',
    status: 'VERIFIED',
  },
  {
    name: 'East Africa Design Week',
    type: 'CORPORATE',
    site: 'https://eadesignweek.example.org',
    status: 'NOT_SUBMITTED',
  },
  {
    name: 'Kenya Creative Economy Council',
    type: 'GOVERNMENT',
    site: 'https://creativeeconomy.example.go.ke',
    status: 'VERIFIED',
  },
  {
    name: 'Mombasa Stories Studio',
    type: 'STUDIO',
    site: 'https://mombasastories.example.org',
    status: 'NOT_SUBMITTED',
  },
  {
    name: 'Rift Valley College of the Arts',
    type: 'EDUCATION',
    site: 'https://riftarts.example.ac.ke',
    status: 'VERIFIED',
  },
];

const LISTINGS: Listing[] = [
  {
    title: 'Emerging Creatives Grant 2027',
    provider: 'Nairobi Creative Fund',
    type: 'GRANT',
    summary: 'Seed grants for early-career Kenyan creatives to make a first body of work.',
    about:
      'The Nairobi Creative Fund supports creatives in the first five years of their practice. Grantees receive unrestricted funding, a mentor from the fund’s network and a small showcase at the end of the year.\n\nApplications are read by a panel of working artists. Tell the panel what you want to make, why now, and how the money will be spent.',
    requirements: [
      'Kenyan resident',
      'At least two published projects',
      'A short project plan (one page)',
    ],
    benefits: ['Unrestricted grant', 'A mentor for six months', 'A year-end showcase'],
    days: 9,
    min: 150_000,
    max: 400_000,
    trust: 'VERIFIED',
    featured: true,
    daysAgo: 12,
    rules: [
      { type: 'RESIDENCY', label: 'Based in Kenya', params: { countryCode: 'KE' } },
      { type: 'MIN_PROJECTS', label: 'At least 2 published projects', params: { count: 2 } },
      {
        type: 'DOCUMENT',
        label: 'Artist statement',
        params: { document: 'ARTIST_STATEMENT' },
        blocking: false,
      },
    ],
  },
  {
    title: 'Short Film Development Fund',
    provider: 'Lakeside Film Collective',
    type: 'FUNDING',
    summary: 'Development money and editing support for short films by directors in western Kenya.',
    about:
      'Lakeside Film Collective backs short films from writers and directors who live around Lake Victoria. Funding covers script development, a pitch workshop and post-production support.',
    requirements: [
      'Based in Kisumu, Siaya, Homa Bay or Migori',
      'A script or treatment',
      'One previous film, even a student film',
    ],
    benefits: [
      'Up to KES 250,000 development funding',
      'Editing suite time',
      'A pitch day with producers',
    ],
    days: 21,
    county: 'Kisumu',
    min: 100_000,
    max: 250_000,
    disciplines: ['Film / Video'],
    trust: 'SOURCE_CONFIRMED',
    daysAgo: 6,
    rules: [
      {
        type: 'DISCIPLINE_IN',
        label: 'Film or video',
        params: { disciplineNames: ['Film / Video'] },
      },
      {
        type: 'RESIDENCY',
        label: 'Based in the Lake region',
        params: { countyCodes: ['KSM', 'SYA', 'HMB', 'MGR'] },
      },
      { type: 'MIN_PROJECTS', label: 'At least 1 published project', params: { count: 1 } },
    ],
  },
  {
    title: 'Junior Motion Designer',
    provider: 'East Africa Design Week',
    type: 'JOB',
    summary:
      'A one-year role on the festival’s in-house design team, mostly motion graphics and titles.',
    about:
      'East Africa Design Week is hiring a junior motion designer to work with the creative director on opening titles, speaker cards and social video for the 2027 festival.',
    requirements: [
      'A portfolio with motion work',
      'After Effects',
      'Able to work from Nairobi three days a week',
    ],
    benefits: ['Monthly salary', 'Festival pass', 'Mentoring from the creative director'],
    days: 12,
    county: 'Nairobi',
    mode: 'HYBRID',
    valueText: 'KES 70,000 a month',
    disciplines: ['Animation', 'Design'],
    trust: 'EXTERNAL_SOURCE',
    daysAgo: 3,
    rules: [
      { type: 'MIN_PROJECTS', label: 'At least 3 published projects', params: { count: 3 } },
      { type: 'RESIDENCY', label: 'Based in Nairobi', params: { countyCodes: ['NBI'] } },
    ],
  },
  {
    title: 'Illustrator in Residence',
    provider: 'Kilifi Arts Residency',
    type: 'RESIDENCY',
    summary: 'Six weeks on the coast with a studio, a stipend and time to finish a picture book.',
    about:
      'Kilifi Arts Residency hosts two illustrators each season. You get a studio, shared meals, a stipend and an open-studio evening at the end. We are looking for work that tells stories for young readers.',
    requirements: [
      'A picture-book dummy or a clear plan for one',
      'At least three published illustration projects',
    ],
    benefits: ['Studio space', 'Weekly stipend', 'Shared accommodation', 'Open-studio evening'],
    days: 45,
    county: 'Kilifi',
    min: 120_000,
    max: 120_000,
    disciplines: ['Visual Art', 'Design'],
    trust: 'VERIFIED',
    featured: true,
    daysAgo: 20,
    rules: [
      {
        type: 'DISCIPLINE_IN',
        label: 'Visual art or design',
        params: { disciplineNames: ['Visual Art', 'Design'] },
      },
      { type: 'MIN_PROJECTS', label: 'At least 3 published projects', params: { count: 3 } },
    ],
  },
  {
    title: 'Open Call: Main Stage Artists',
    provider: 'Savannah Sound Festival',
    type: 'FESTIVAL',
    summary: 'Live acts wanted for the 2027 festival in Nanyuki. Paid slots on three stages.',
    about:
      'Savannah Sound Festival is open to live acts of all genres. Selected artists are paid a fixed fee, with transport from Nairobi and two nights of accommodation.',
    requirements: [
      'A live set of 40 minutes or more',
      'A recording or video of a live performance',
      'A tech rider',
    ],
    benefits: [
      'Performance fee',
      'Transport and two nights of accommodation',
      'Recording of your set',
    ],
    days: 6,
    county: 'Laikipia',
    valueText: 'Paid slots from KES 40,000',
    disciplines: ['Music'],
    trust: 'SOURCE_CONFIRMED',
    daysAgo: 25,
    rules: [
      { type: 'DISCIPLINE_IN', label: 'Music', params: { disciplineNames: ['Music'] } },
      {
        type: 'CUSTOM_TEXT',
        label: 'A live set of 40 minutes or more',
        params: {},
        blocking: false,
      },
    ],
  },
  {
    title: 'Photography Fellowship: Coastal Communities',
    provider: 'Mombasa Stories Studio',
    type: 'FELLOWSHIP',
    summary: 'A nine-month paid fellowship documenting life along the Swahili coast.',
    about:
      'Mombasa Stories Studio is awarding one fellowship to a photographer ready to spend nine months on a long-form project about coastal communities. The fellow works with the studio’s editors and exhibits the series at Fort Jesus.',
    requirements: [
      'A portfolio of documentary work',
      'Able to relocate to Mombasa for the fellowship',
      'Aged 21 to 35',
    ],
    benefits: ['Monthly stipend', 'Equipment budget', 'Exhibition at the end'],
    days: 60,
    county: 'Mombasa',
    min: 600_000,
    max: 600_000,
    disciplines: ['Photography'],
    trust: 'EXTERNAL_SOURCE',
    daysAgo: 9,
    rules: [
      { type: 'DISCIPLINE_IN', label: 'Photography', params: { disciplineNames: ['Photography'] } },
      { type: 'MIN_PROJECTS', label: 'At least 4 published projects', params: { count: 4 } },
      { type: 'AGE_RANGE', label: 'Aged 21 to 35', params: { min: 21, max: 35 } },
    ],
  },
  {
    title: 'Paid Internship: Production Assistant',
    provider: 'Lakeside Film Collective',
    type: 'INTERNSHIP',
    summary: 'Three months on set and in the edit, helping on two commissioned documentaries.',
    about:
      'Interns work alongside the producers on two documentary shoots, handle logistics, log footage and assist in the edit. A strong first step into production.',
    requirements: [
      'Enrolled in or recently finished a film or media course',
      'A driving licence is a plus',
    ],
    benefits: ['Monthly allowance', 'Credit on both films', 'Reference letter'],
    days: 16,
    county: 'Nairobi',
    valueText: 'KES 25,000 a month',
    disciplines: ['Film / Video', 'Production'],
    trust: 'SOURCE_CONFIRMED',
    daysAgo: 4,
    rules: [
      {
        type: 'DISCIPLINE_IN',
        label: 'Film, video or production',
        params: { disciplineNames: ['Film / Video', 'Production'] },
      },
      { type: 'RESIDENCY', label: 'Based in Kenya', params: { countryCode: 'KE' } },
    ],
  },
  {
    title: 'Brand Illustration Commission',
    provider: 'East Africa Design Week',
    type: 'GIG',
    summary: 'A one-off commission: twelve illustrations for the 2027 festival programme.',
    about:
      'We need twelve spot illustrations for the festival programme and website. Delivery within five weeks; two rounds of revisions included.',
    requirements: [
      'A portfolio of editorial or brand illustration',
      'Able to deliver vector files',
    ],
    benefits: ['Fixed fee', 'Credit in the programme', 'Free festival pass'],
    days: 14,
    mode: 'REMOTE',
    min: 60_000,
    max: 90_000,
    disciplines: ['Visual Art', 'Design'],
    trust: 'EXTERNAL_SOURCE',
    daysAgo: 2,
    rules: [
      {
        type: 'DISCIPLINE_IN',
        label: 'Illustration or design',
        params: { disciplineNames: ['Visual Art', 'Design'] },
      },
      { type: 'MIN_PROJECTS', label: 'At least 2 published projects', params: { count: 2 } },
    ],
  },
  {
    title: 'Young Storytellers Competition',
    provider: 'Rift Valley College of the Arts',
    type: 'COMPETITION',
    summary:
      'Submit a short story, script or spoken-word piece for a chance to win a full scholarship.',
    about:
      'The college runs an annual competition for writers under 30. Winners receive prize money and a place on the Writing for Performance diploma.',
    requirements: [
      'Original work in English or Kiswahili',
      'Under 3,000 words or five minutes',
      'Aged 18 to 29',
    ],
    benefits: [
      'First prize KES 150,000',
      'Full diploma scholarship',
      'Publication in the college anthology',
    ],
    days: 30,
    min: 150_000,
    max: 150_000,
    disciplines: ['Writing'],
    trust: 'VERIFIED',
    daysAgo: 8,
    rules: [
      { type: 'DISCIPLINE_IN', label: 'Writing', params: { disciplineNames: ['Writing'] } },
      { type: 'AGE_RANGE', label: 'Aged 18 to 29', params: { min: 18, max: 29 } },
    ],
  },
  {
    title: 'Creative Export Partnership Programme',
    provider: 'Kenya Creative Economy Council',
    type: 'PARTNERSHIP',
    summary: 'Matched with buyers and agents at three international creative markets.',
    about:
      'The council is selecting 20 creative businesses for an export partnership programme, with travel support to markets in Lagos, Johannesburg and London.',
    requirements: [
      'A registered business or a sole proprietor with a KRA PIN',
      'At least five published projects',
      'A one-page export plan',
    ],
    benefits: [
      'Travel and accommodation support',
      'Introductions to buyers',
      'A stand at each market',
    ],
    days: 75,
    valueText: 'Travel and stand fully covered',
    trust: 'VERIFIED',
    daysAgo: 14,
    rules: [
      { type: 'RESIDENCY', label: 'Based in Kenya', params: { countryCode: 'KE' } },
      { type: 'MIN_PROJECTS', label: 'At least 5 published projects', params: { count: 5 } },
      {
        type: 'DOCUMENT',
        label: 'A one-page export plan',
        params: { document: 'DECK' },
        blocking: false,
      },
    ],
  },
  {
    title: 'Community Mural Programme',
    provider: 'Kenya Creative Economy Council',
    type: 'PROGRAMME',
    summary: 'Paid mural work in six towns, with materials and a local assistant provided.',
    about:
      'A county-by-county programme that pays visual artists to paint public murals chosen with local communities. Artists are matched to towns after an interview.',
    requirements: [
      'Experience painting at large scale',
      'Able to travel for up to two weeks at a time',
    ],
    benefits: ['Fee per mural', 'Materials supplied', 'A local assistant on each wall'],
    days: null,
    valueText: 'KES 180,000 per mural',
    disciplines: ['Visual Art'],
    trust: 'VERIFIED',
    daysAgo: 30,
    rules: [
      { type: 'DISCIPLINE_IN', label: 'Visual art', params: { disciplineNames: ['Visual Art'] } },
    ],
  },
  {
    title: 'Fashion Pop-up Residency',
    provider: 'Nairobi Creative Fund',
    type: 'RESIDENCY',
    summary: 'Two weeks in a pop-up studio in Westlands to show a capsule collection to buyers.',
    about:
      'Four fashion designers share a pop-up space for two weeks. The fund covers rent, a photographer and a launch evening with buyers and press.',
    requirements: [
      'A capsule collection of at least eight pieces',
      'Your own label or a clear plan for one',
    ],
    benefits: [
      'Rent-free studio and shop space',
      'Lookbook photography',
      'A launch evening with buyers',
    ],
    days: 26,
    county: 'Nairobi',
    disciplines: ['Fashion'],
    trust: 'SOURCE_CONFIRMED',
    daysAgo: 5,
    rules: [
      { type: 'DISCIPLINE_IN', label: 'Fashion', params: { disciplineNames: ['Fashion'] } },
      { type: 'MIN_PROJECTS', label: 'At least 1 published project', params: { count: 1 } },
    ],
  },
  {
    title: 'Sound Engineer Apprenticeship',
    provider: 'Savannah Sound Festival',
    type: 'INTERNSHIP',
    summary: 'Learn live sound on three stages with the festival’s head engineer.',
    about:
      'Two apprentices join the audio crew for the four months leading up to the festival and the festival itself. Hands-on from day one; no experience with a large desk needed.',
    requirements: ['Basic recording or live sound experience', 'Able to lift and carry kit'],
    benefits: ['Weekly allowance', 'Hands-on training', 'A job reference'],
    days: 3,
    county: 'Nairobi',
    valueText: 'KES 18,000 a month',
    disciplines: ['Music', 'Production'],
    trust: 'EXTERNAL_SOURCE',
    daysAgo: 15,
    rules: [
      {
        type: 'DISCIPLINE_IN',
        label: 'Music or production',
        params: { disciplineNames: ['Music', 'Production'] },
      },
    ],
  },
];

/** Rules name disciplines by name in the table above; the seed turns them into ids. */
async function disciplineIds(prisma: PrismaClient, names: string[]): Promise<string[]> {
  const rows = await prisma.discipline.findMany({
    where: { name: { in: names } },
    select: { id: true },
  });
  return rows.map((r) => r.id);
}

export async function seedDemoOpportunities(prisma: PrismaClient): Promise<void> {
  if ((await prisma.opportunity.count({ where: { isDemo: true } })) > 0) return;
  const admin = await prisma.user.findUnique({ where: { email: 'admin@demo.atarah.test' } });
  const now = Date.now();
  const day = 86_400_000;

  const providers = new Map<string, string>();
  for (const p of PROVIDERS) {
    const row = await prisma.opportunityProvider.create({
      data: {
        name: p.name,
        type: p.type,
        website: p.site,
        verificationStatus: p.status,
        isDemo: true,
      },
    });
    providers.set(p.name, row.id);
  }

  const counties = new Map((await prisma.county.findMany()).map((c) => [c.name, c]));
  for (const l of LISTINGS) {
    const county = l.county ? counties.get(l.county) : undefined;
    const slug = `${l.title}`
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 60);
    const url = new URL(`/apply/${slug}`, PROVIDERS.find((p) => p.name === l.provider)!.site);
    const created = await prisma.opportunity.create({
      data: {
        providerId: providers.get(l.provider)!,
        slug: `${slug}-demo`,
        type: l.type,
        title: l.title,
        summary: l.summary,
        about: l.about,
        requirements: l.requirements,
        benefits: l.benefits,
        valueMinMinor: l.min !== undefined ? BigInt(l.min * 100) : null,
        valueMaxMinor: l.max !== undefined ? BigInt(l.max * 100) : null,
        valueCurrency: l.min !== undefined || l.max !== undefined ? 'KES' : null,
        valueText: l.valueText ?? null,
        deadlineAt: l.days === null ? null : new Date(now + l.days * day),
        countryId: county?.countryId ?? null,
        countyId: county?.id ?? null,
        workMode: l.mode ?? 'ONSITE',
        applicationMethod: 'EXTERNAL_WEBSITE',
        applicationUrl: url.href,
        applicationDomain: url.hostname,
        trust: l.trust,
        status: 'PUBLISHED',
        featuredUntil: l.featured ? new Date(now + 30 * day) : null,
        publishedAt: new Date(now - (l.daysAgo ?? 1) * day),
        createdById: admin?.id ?? null,
        isDemo: true,
      },
    });

    if (l.disciplines?.length) {
      const ids = await disciplineIds(prisma, l.disciplines);
      if (ids.length > 0) {
        await prisma.opportunityDiscipline.createMany({
          data: ids.map((disciplineId) => ({ opportunityId: created.id, disciplineId })),
        });
      }
    }
    let order = 0;
    for (const r of l.rules) {
      let params = r.params;
      if (r.type === 'DISCIPLINE_IN') {
        // The table names disciplines; the stored rule holds their ids.
        const names = (r.params as { disciplineNames: string[] }).disciplineNames;
        params = { disciplineIds: await disciplineIds(prisma, names) };
      }
      await prisma.opportunityRequirementRule.create({
        data: {
          opportunityId: created.id,
          ruleType: r.type,
          params,
          label: r.label,
          isBlocking: r.blocking ?? true,
          sortOrder: order,
        },
      });
      order += 1;
    }
  }

  // Provider counts follow the published listings.
  await prisma.$executeRaw`
    UPDATE opportunity_providers p SET "opportunitiesCount" = (
      SELECT count(*) FROM opportunities o WHERE o."providerId" = p.id AND o.status::text = 'PUBLISHED')::int
    WHERE p."isDemo" = true`;
}
