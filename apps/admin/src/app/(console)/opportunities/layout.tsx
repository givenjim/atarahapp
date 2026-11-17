import type { ReactNode } from 'react';
import { OppTabs } from './opp-tabs';

export default function OpportunitiesLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <OppTabs />
      {children}
    </>
  );
}
