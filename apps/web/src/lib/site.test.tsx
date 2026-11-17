import { render, screen } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { JoinCta } from '@/components/join-cta';
import { Logo } from '@/components/logo';
import { storeLinks } from './site';

describe('storeLinks', () => {
  it('is off by default, even if URLs are present', () => {
    expect(storeLinks({ NEXT_PUBLIC_PLAY_STORE_URL: 'https://play.example/x' }).enabled).toBe(
      false,
    );
  });

  it('is on only when the flag is true and at least one URL is set', () => {
    expect(storeLinks({ NEXT_PUBLIC_STORE_LINKS_ENABLED: 'true' }).enabled).toBe(false);
    expect(
      storeLinks({
        NEXT_PUBLIC_STORE_LINKS_ENABLED: 'true',
        NEXT_PUBLIC_PLAY_STORE_URL: 'https://play.example/x',
      }).enabled,
    ).toBe(true);
  });
});

describe('JoinCta', () => {
  it('shows a status line and no links while store links are off', () => {
    render(<JoinCta links={{ enabled: false }} />);
    expect(screen.getByRole('status')).toHaveTextContent('launching soon');
    expect(screen.queryByRole('link')).toBeNull();
  });

  it('renders one link per configured store when on', () => {
    render(<JoinCta links={{ enabled: true, playStore: 'https://play.example/x' }} />);
    expect(screen.getByRole('link', { name: /google play/i })).toHaveAttribute(
      'href',
      'https://play.example/x',
    );
    expect(screen.queryByRole('link', { name: /app store/i })).toBeNull();
  });
});

describe('Logo', () => {
  it('is exposed as a single labelled image', () => {
    render(<Logo />);
    expect(screen.getByRole('img', { name: 'Atarah' })).toHaveAttribute(
      'src',
      '/brand/atarah-logo-notagline-color.svg',
    );
  });
});
