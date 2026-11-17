import type { ReactNode } from 'react';
import { ContentTabs } from './content-tabs';

export default function ContentLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <ContentTabs />
      {children}
    </>
  );
}
