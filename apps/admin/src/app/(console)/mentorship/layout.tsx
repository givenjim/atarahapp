import type { ReactNode } from 'react';
import { MentorshipTabs } from './mentorship-tabs';

export default function MentorshipLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <MentorshipTabs />
      {children}
    </>
  );
}
