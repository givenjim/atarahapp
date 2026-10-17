import { type EmailMessage } from './messaging';

export type CodeMessageKind = 'verify' | 'reset' | 'two-step';

const COPY: Record<
  CodeMessageKind,
  { subject: string; lead: string; minutesKey: 'code' | 'recovery' }
> = {
  verify: {
    subject: 'Your Atarah verification code',
    lead: 'Use this code to verify your Atarah account.',
    minutesKey: 'code',
  },
  reset: {
    subject: 'Your Atarah password recovery code',
    lead: 'Use this code to reset your Atarah password.',
    minutesKey: 'recovery',
  },
  'two-step': {
    subject: 'Your Atarah sign-in code',
    lead: 'Use this code to finish signing in to Atarah.',
    minutesKey: 'code',
  },
};

/** Branded one-time-code message. Plain text is the source of truth; the HTML mirrors it. */
export function renderCodeMessage(
  kind: CodeMessageKind,
  code: string,
  minutes: number,
): { subject: string; text: string; html: string } {
  const c = COPY[kind];
  const text = [
    c.lead,
    '',
    `Your code is ${code}`,
    `It expires in ${minutes} minutes. If you did not ask for it, you can ignore this message.`,
    '',
    'Atarah · Create · Connect · Grow',
  ].join('\n');
  const html = `<!doctype html><html><body style="margin:0;background:#f6f5fc;font-family:'Plus Jakarta Sans',Arial,sans-serif;color:#15133d">
<div style="max-width:440px;margin:32px auto;background:#fff;border:1px solid #ecebf4;border-radius:20px;padding:28px">
<div style="font-weight:800;font-size:22px">ATARA<span style="color:#5b45f0">H</span></div>
<p style="font-size:15px;line-height:1.6;color:#4a4868">${c.lead}</p>
<div style="font-size:32px;font-weight:800;letter-spacing:.3em;background:#f1eeff;color:#5b45f0;border-radius:14px;padding:16px;text-align:center">${code}</div>
<p style="font-size:13px;line-height:1.6;color:#77758f">It expires in ${minutes} minutes. If you did not ask for it, you can ignore this message.</p>
<p style="font-size:11px;letter-spacing:.14em;color:#a3a1b8">CREATE · CONNECT · GROW</p>
</div></body></html>`;
  return { subject: c.subject, text, html };
}

export function emailFor(
  to: string,
  rendered: { subject: string; text: string; html: string },
): EmailMessage {
  return { to, ...rendered };
}
