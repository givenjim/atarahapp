import type { ReactNode } from 'react';
import { LearnTabs } from './learn-tabs';

export default function LearningLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <LearnTabs />
      {children}
    </>
  );
}
