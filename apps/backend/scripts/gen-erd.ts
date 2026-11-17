/**
 * Writes docs/DATABASE-ERD.md: a Mermaid entity-relationship diagram of every Prisma model (tables, key columns,
 * relations), generated from the Prisma schema so it never drifts. Run: pnpm --filter @atarah/backend db:erd
 */
import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { Prisma } from '@prisma/client';

const models = Prisma.dmmf.datamodel.models;
const typeOf = (t: string): string => t.replace(/[^A-Za-z0-9_]/g, '_');
const lines: string[] = ['erDiagram'];

for (const m of models) {
  lines.push(`  ${m.dbName ?? m.name} {`);
  for (const f of m.fields) {
    if (f.kind === 'object') continue;
    const marks = [
      f.isId ? 'PK' : '',
      f.isUnique ? 'UK' : '',
      f.relationName && f.kind === 'scalar' ? 'FK' : '',
    ]
      .filter(Boolean)
      .join(',');
    lines.push(`    ${typeOf(f.type)} ${f.name}${marks ? ` ${marks}` : ''}`);
  }
  lines.push('  }');
}

const table = new Map(models.map((m) => [m.name, m.dbName ?? m.name]));
for (const m of models) {
  for (const f of m.fields) {
    if (f.kind !== 'object' || !f.relationFromFields || f.relationFromFields.length === 0) continue;
    const to = table.get(f.type);
    if (!to) continue;
    const required = f.relationFromFields.every(
      (n) => m.fields.find((x) => x.name === n)?.isRequired,
    );
    lines.push(`  ${to} ${required ? '||' : '|o'}--o{ ${table.get(m.name)} : "${f.name}"`);
  }
}

const out = resolve(__dirname, '../../../docs/DATABASE-ERD.md');
mkdirSync(dirname(out), { recursive: true });
writeFileSync(
  out,
  `# Database ER diagram\n\nGenerated from \`apps/backend/prisma/schema\` by \`pnpm --filter @atarah/backend db:erd\` (${models.length} tables). Do not edit by hand.\n\`users.id\` also references \`auth.users.id\` in Supabase Auth (a foreign key created in SQL, not shown here).\n\n\`\`\`mermaid\n${lines.join('\n')}\n\`\`\`\n`,
);
console.log(`ER diagram written to ${out} (${models.length} tables)`);
