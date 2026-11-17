import type { Metadata, Viewport } from 'next';
import localFont from 'next/font/local';
import type { ReactNode } from 'react';
import { appearanceInitScript } from '@/lib/appearance';
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
  title: { default: 'Atarah Admin', template: '%s · Atarah Admin' },
  robots: { index: false, follow: false },
  icons: {
    icon: [
      { url: '/brand/favicon-16.png', sizes: '16x16', type: 'image/png' },
      { url: '/brand/favicon-32.png', sizes: '32x32', type: 'image/png' },
      { url: '/brand/favicon-64.png', sizes: '64x64', type: 'image/png' },
    ],
  },
};

export const viewport: Viewport = {
  themeColor: [
    { media: '(prefers-color-scheme: light)', color: '#FFFFFF' },
    { media: '(prefers-color-scheme: dark)', color: '#0F0D2B' },
  ],
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en" className={plusJakarta.variable} suppressHydrationWarning>
      <head>
        {/* Applies a stored appearance choice before first paint (no flash). */}
        <script dangerouslySetInnerHTML={{ __html: appearanceInitScript }} />
      </head>
      <body style={{ fontFamily: 'var(--font-plus-jakarta), var(--at-font-family)' }}>
        {children}
      </body>
    </html>
  );
}
