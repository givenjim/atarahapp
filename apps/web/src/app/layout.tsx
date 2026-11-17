import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import type { ReactNode } from 'react';
import { siteUrl } from '@/lib/site';
import './globals.css';

const plusJakarta = localFont({
  src: [
    { path: '../fonts/PlusJakartaSans-Regular.ttf', weight: '400' },
    { path: '../fonts/PlusJakartaSans-Medium.ttf', weight: '500' },
    { path: '../fonts/PlusJakartaSans-SemiBold.ttf', weight: '600' },
    { path: '../fonts/PlusJakartaSans-Bold.ttf', weight: '700' },
    { path: '../fonts/PlusJakartaSans-ExtraBold.ttf', weight: '800' },
  ],
  display: 'swap',
  variable: '--font-plus-jakarta',
});

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl()),
  title: { default: 'Atarah — Create · Connect · Grow', template: '%s · Atarah' },
  description:
    'Atarah is the creative operating layer for Kenyan creatives: one identity, many connected possibilities.',
  openGraph: { siteName: 'Atarah', type: 'website', locale: 'en_KE' },
  icons: {
    icon: [
      { url: '/brand/favicon-16.png', sizes: '16x16', type: 'image/png' },
      { url: '/brand/favicon-32.png', sizes: '32x32', type: 'image/png' },
      { url: '/brand/favicon-64.png', sizes: '64x64', type: 'image/png' },
    ],
  },
};

export const viewport: Viewport = { themeColor: '#FFFFFF', width: 'device-width', initialScale: 1 };

/** The public holding page always uses the light appearance (data-theme="light" pins it). */
export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" data-theme="light" className={plusJakarta.variable}>
      <body style={{ fontFamily: `var(--font-plus-jakarta), var(--at-font-family)` }}>
        {children}
      </body>
    </html>
  );
}
