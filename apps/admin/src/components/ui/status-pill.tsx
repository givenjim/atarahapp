const TONES: Record<string, { tone: '' | 'success' | 'warning' | 'danger'; label: string }> = {
  ACTIVE: { tone: 'success', label: 'Active' },
  PENDING_VERIFICATION: { tone: 'warning', label: 'Pending verification' },
  SUSPENDED: { tone: 'danger', label: 'Suspended' },
  DEACTIVATED: { tone: '', label: 'Deactivated' },
  DELETED: { tone: '', label: 'Deleted' },
};

export function StatusPill({ status }: { status: string }) {
  const t = TONES[status] ?? { tone: '' as const, label: status };
  return <span className={`pill ${t.tone}`.trim()}>{t.label}</span>;
}
