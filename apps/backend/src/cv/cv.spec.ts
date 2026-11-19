import { type CreativeDocumentFormat, type ProfileSection } from '@prisma/client';
import {
  type CvConfig,
  type CvSource,
  FORMAT_SPECS,
  FORMATS,
  buildCvDocument,
  sectionIncluded,
} from './cv.model';
import { esc, renderCvHtml } from './cv.templates';
import { PdfRenderer, PdfRendererUnavailableError } from './pdf-renderer';
import { TOKEN_PATTERN } from './cv.service';
import { type AppConfigService } from '../config/app-config.service';

const SECRET_BIO = 'SECRET-members-bio';
const SECRET_PROJECT = 'SECRET-private-project';

/** One member whose BIO is members-only and CONTACT, LOCATION, EXPERIENCE are not public either. */
const source = (over: Partial<CvSource> = {}): CvSource => ({
  profileId: 'p1',
  handle: 'nia',
  displayName: 'Nia Wairimu',
  headline: 'Illustrator',
  bio: SECRET_BIO,
  discipline: 'Animation',
  county: 'Nairobi',
  town: 'Kilimani',
  openToCommissions: true,
  avatarDataUri: null,
  contact: { email: 'nia@example.test', phone: '+254700000001', showEmail: true, showPhone: true },
  visibility: {
    BIO: 'MEMBERS',
    LOCATION: 'MEMBERS',
    PORTFOLIO: 'PUBLIC',
    SKILLS: 'PUBLIC',
    EXPERIENCE: 'MEMBERS',
    SERVICES: 'PUBLIC',
    LINKS: 'PUBLIC',
    CONTACT: 'PRIVATE',
  },
  skills: [
    { id: 's1', name: '2D Animation', level: 'EXPERT' },
    { id: 's2', name: 'Storyboarding', level: null },
  ],
  projects: [
    {
      id: 'pub',
      title: 'Public project',
      role: 'Lead',
      client: null,
      year: 2026,
      category: 'PROJECT',
      description: 'Seen by everyone.',
      outcome: null,
      visibility: 'PUBLIC',
      published: true,
      hidden: false,
      deleted: false,
      skills: ['2D Animation'],
      links: [],
    },
    {
      id: 'priv',
      title: SECRET_PROJECT,
      role: null,
      client: null,
      year: 2025,
      category: 'PROJECT',
      description: null,
      outcome: null,
      visibility: 'PRIVATE',
      published: true,
      hidden: false,
      deleted: false,
      skills: [],
      links: [],
    },
    {
      id: 'draft',
      title: 'Draft project',
      role: null,
      client: null,
      year: null,
      category: 'PROJECT',
      description: null,
      outcome: null,
      visibility: 'PUBLIC',
      published: false,
      hidden: false,
      deleted: false,
      skills: [],
      links: [],
    },
    {
      id: 'hidden',
      title: 'Hidden by moderators',
      role: null,
      client: null,
      year: null,
      category: 'PROJECT',
      description: null,
      outcome: null,
      visibility: 'PUBLIC',
      published: true,
      hidden: true,
      deleted: false,
      skills: [],
      links: [],
    },
  ],
  experience: [
    {
      title: 'SECRET-members-role',
      organisation: 'Studio',
      location: null,
      start: '2022-01-01',
      end: null,
      current: true,
      description: null,
    },
  ],
  achievements: [
    { type: 'AWARD', title: 'SECRET-members-award', issuer: null, year: 2024, description: null },
  ],
  services: [{ title: 'Illustration', description: null, price: 'KES 5,000' }],
  links: [{ label: 'Site', url: 'https://nia.example.test' }],
  ...over,
});

const config = (format: CreativeDocumentFormat, over: Partial<CvConfig> = {}): CvConfig => ({
  format,
  sections: [...FORMAT_SPECS[format].allowed],
  projectIds: ['pub', 'priv', 'draft', 'hidden'],
  restricted: [],
  ...over,
});

const marks = { identity: false, skillIds: new Set<string>() };

describe('CV visibility filtering', () => {
  it.each(FORMATS)('%s: members-only and private fields are excluded by default', (format) => {
    const doc = buildCvDocument(source(), config(format), marks);
    const html = renderCvHtml(doc, new Date('2026-11-20T00:00:00Z'));
    for (const secret of [
      SECRET_BIO,
      'SECRET-members-role',
      'SECRET-members-award',
      SECRET_PROJECT,
      'nia@example.test',
      '+254700000001',
      'Kilimani',
      'Draft project',
      'Hidden by moderators',
    ]) {
      expect(html).not.toContain(secret);
    }
    expect(doc.bio).toBeNull();
    expect(doc.location).toBeNull();
    expect(doc.contact).toBeNull();
    expect(doc.experience).toBeNull();
    // Public content still appears.
    expect(html).toContain('Nia Wairimu');
    expect(doc.included).not.toContain('BIO');
    expect(doc.withheld).toEqual(
      expect.arrayContaining(
        ['BIO', 'LOCATION', 'EXPERIENCE', 'CONTACT'].filter((s) =>
          FORMAT_SPECS[format].allowed.includes(s as ProfileSection),
        ) as ProfileSection[],
      ),
    );
  });

  it.each(FORMATS)('%s: public content of the chosen sections is included', (format) => {
    const doc = buildCvDocument(source(), config(format), marks);
    const html = renderCvHtml(doc, new Date());
    expect(html).toContain('2D Animation');
    if (FORMAT_SPECS[format].maxProjects > 0) expect(html).toContain('Public project');
    else expect(doc.projects).toBeNull();
    expect(html).toContain('https://nia.example.test');
  });

  it.each(FORMATS)('%s: a non-public section appears only when explicitly allowed', (format) => {
    const allowed = FORMAT_SPECS[format].allowed.filter((s) =>
      ['BIO', 'EXPERIENCE', 'CONTACT', 'LOCATION'].includes(s),
    );
    const doc = buildCvDocument(source(), config(format, { restricted: allowed }), marks);
    const html = renderCvHtml(doc, new Date());
    expect(html).toContain(SECRET_BIO);
    expect(html).toContain('nia@example.test');
    expect(html).toContain('+254700000001');
    expect(html).toContain('Kilimani');
    if (allowed.includes('EXPERIENCE')) expect(html).toContain('SECRET-members-role');
  });

  it('a section that is not picked never appears, even when it is public and allowed', () => {
    const doc = buildCvDocument(
      source(),
      config('CV', { sections: ['BIO'], restricted: ['BIO'] }),
      marks,
    );
    expect(doc.skills).toBeNull();
    expect(doc.links).toBeNull();
    expect(doc.projects).toBeNull();
    expect(doc.bio).toBe(SECRET_BIO);
  });

  it('a section the format cannot show is ignored even if the config lists it', () => {
    const doc = buildCvDocument(
      source(),
      config('BIO', { sections: ['BIO', 'PORTFOLIO', 'SERVICES'], restricted: ['BIO'] }),
      marks,
    );
    expect(doc.projects).toBeNull();
    expect(doc.services).toBeNull();
  });

  it('contact respects the member’s email and phone switches even when allowed', () => {
    const src = source({
      contact: {
        email: 'nia@example.test',
        phone: '+254700000001',
        showEmail: false,
        showPhone: true,
      },
    });
    const doc = buildCvDocument(src, config('CV', { restricted: ['CONTACT'] }), marks);
    expect(doc.contact).toEqual({ email: null, phone: '+254700000001' });
    const none = source({
      contact: { email: 'nia@example.test', phone: null, showEmail: false, showPhone: false },
    });
    expect(
      buildCvDocument(none, config('CV', { restricted: ['CONTACT'] }), marks).contact,
    ).toBeNull();
  });

  it('a private project needs the explicit allow on the portfolio section', () => {
    const without = buildCvDocument(source(), config('CV'), marks);
    expect(without.projects?.map((p) => p.title)).toEqual(['Public project']);
    const withAllow = buildCvDocument(source(), config('CV', { restricted: ['PORTFOLIO'] }), marks);
    expect(withAllow.projects?.map((p) => p.title)).toEqual(['Public project', SECRET_PROJECT]);
    // Drafts and moderated projects never appear, whatever the member allows.
    expect(withAllow.projects?.some((p) => p.title === 'Draft project')).toBe(false);
    expect(withAllow.projects?.some((p) => p.title === 'Hidden by moderators')).toBe(false);
  });

  it('only projects the member listed, in their order and up to the layout limit', () => {
    const many = Array.from({ length: 15 }, (_, i) => ({
      ...source().projects[0]!,
      id: `x${i}`,
      title: `P${i}`,
    }));
    const ids = many.map((p) => p.id);
    const doc = buildCvDocument(
      source({ projects: many }),
      config('EPK', { projectIds: [...ids].reverse() }),
      marks,
    );
    expect(doc.projects).toHaveLength(FORMAT_SPECS.EPK.maxProjects);
    expect(doc.projects?.[0]?.title).toBe('P14');
    expect(
      buildCvDocument(source({ projects: many }), config('EPK', { projectIds: [] }), marks)
        .projects,
    ).toEqual([]);
  });

  it('shows verified marks only for ids the reader reports', () => {
    const doc = buildCvDocument(source(), config('CV'), {
      identity: true,
      skillIds: new Set(['s1']),
    });
    expect(doc.skills).toEqual([
      { name: '2D Animation', level: 'EXPERT', verified: true },
      { name: 'Storyboarding', level: null, verified: false },
    ]);
    const html = renderCvHtml(doc, new Date());
    expect(html).toContain('2D Animation ✓');
    expect(html).not.toContain('Storyboarding ✓');
    expect(html).toContain('class="tick"');
    expect(renderCvHtml(buildCvDocument(source(), config('CV'), marks), new Date())).not.toContain(
      'class="tick"',
    );
  });

  it('sectionIncluded follows the rule table', () => {
    const vis = source().visibility;
    expect(sectionIncluded('SKILLS', { sections: ['SKILLS'], restricted: [] }, vis)).toBe(true);
    expect(sectionIncluded('BIO', { sections: ['BIO'], restricted: [] }, vis)).toBe(false);
    expect(sectionIncluded('BIO', { sections: ['BIO'], restricted: ['BIO'] }, vis)).toBe(true);
    expect(sectionIncluded('BIO', { sections: [], restricted: ['BIO'] }, vis)).toBe(false);
  });
});

describe('CV templates', () => {
  it('escape member text and never make non-http links clickable', () => {
    expect(esc(`<script>alert("x")</script>&'`)).toBe(
      '&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;&amp;&#39;',
    );
    const src = source({
      displayName: '<img src=x onerror=alert(1)>',
      links: [{ label: 'Bad', url: 'javascript:alert(1)' }],
    });
    const html = renderCvHtml(buildCvDocument(src, config('CV'), marks), new Date());
    expect(html).not.toContain('<img src=x');
    expect(html).not.toContain('href="javascript:');
    expect(html).toContain('&lt;img src=x onerror=alert(1)&gt;');
  });

  it('only inline raster avatars as data URIs, and forbid network fetches by CSP', () => {
    const good = renderCvHtml(
      buildCvDocument(
        source({ avatarDataUri: 'data:image/webp;base64,AAAA' }),
        config('CV'),
        marks,
      ),
      new Date(),
    );
    expect(good).toContain('src="data:image/webp;base64,AAAA"');
    const bad = renderCvHtml(
      buildCvDocument(source({ avatarDataUri: 'https://evil.example/x.png' }), config('CV'), marks),
      new Date(),
    );
    expect(bad).not.toContain('evil.example');
    expect(good).toContain("default-src 'none'");
  });

  it.each(FORMATS)('%s: produces a complete A4 document', (format) => {
    const html = renderCvHtml(buildCvDocument(source(), config(format), marks), new Date());
    expect(html.startsWith('<!doctype html>')).toBe(true);
    expect(html).toContain('size: A4');
    expect(html).toContain(FORMAT_SPECS[format].label);
  });
});

describe('share token shape', () => {
  it('accepts base64url tokens of the generated length and nothing else', () => {
    expect(TOKEN_PATTERN.test('a'.repeat(43))).toBe(true);
    expect(TOKEN_PATTERN.test('short')).toBe(false);
    expect(TOKEN_PATTERN.test(`${'a'.repeat(30)}/../etc`)).toBe(false);
  });
});

describe('PDF renderer', () => {
  const cfg = (path: string) => ({ pdfBrowserPath: path }) as unknown as AppConfigService;

  it('reports a clear error when the configured browser does not exist', async () => {
    const r = new PdfRenderer(cfg('C:\\no\\such\\browser.exe'));
    expect(r.isAvailable()).toBe(false);
    await expect(r.render('<p>x</p>')).rejects.toBeInstanceOf(PdfRendererUnavailableError);
  });

  const auto = new PdfRenderer(cfg(''));
  const maybe = auto.isAvailable() ? it : it.skip;
  maybe(
    'prints a real A4 PDF with the detected browser',
    async () => {
      const html = renderCvHtml(buildCvDocument(source(), config('CV'), marks), new Date());
      const pdf = await auto.render(html);
      expect(pdf.subarray(0, 5).toString('latin1')).toBe('%PDF-');
      expect(pdf.length).toBeGreaterThan(1500);
      // A4 is 595 x 842 points (the browser reports 594.96 x 841.92).
      const box = /\/MediaBox \[0 0 ([\d.]+) ([\d.]+)\]/.exec(pdf.toString('latin1'));
      expect(box).not.toBeNull();
      expect(Number(box![1])).toBeCloseTo(595, 0);
      expect(Number(box![2])).toBeCloseTo(842, 0);
    },
    90_000,
  );
});
