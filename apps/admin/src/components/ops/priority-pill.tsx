import { priorityMeta } from '@/lib/ops';

/** Priority as a word (never colour alone). */
export function PriorityPill({ priority }: { priority: string }) {
  const m = priorityMeta(priority);
  return <span className={`pill ${m.tone}`.trim()}>{m.label}</span>;
}
