import type { ReactNode } from 'react';
import { MarketplaceTabs } from './marketplace-tabs';

export default function MarketplaceLayout({ children }: { children: ReactNode }) {
  return (
    <>
      <MarketplaceTabs />
      {children}
    </>
  );
}
