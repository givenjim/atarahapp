import { embedUrlFor } from './embed';

describe('embedUrlFor', () => {
  it.each([
    ['https://youtu.be/dQw4w9WgXcQ', 'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ'],
    [
      'https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=10',
      'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
    ],
    [
      'https://m.youtube.com/watch?v=dQw4w9WgXcQ',
      'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
    ],
    [
      'https://youtube.com/shorts/dQw4w9WgXcQ',
      'https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ',
    ],
    ['https://vimeo.com/123456789', 'https://player.vimeo.com/video/123456789'],
    ['https://player.vimeo.com/video/123456789', 'https://player.vimeo.com/video/123456789'],
  ])('embeds %s', (link, embed) => {
    expect(embedUrlFor(link)).toBe(embed);
  });

  it.each([
    'https://example.com/watch?v=dQw4w9WgXcQ',
    'https://evil-youtube.com/watch?v=dQw4w9WgXcQ',
    'https://youtube.com.evil.test/watch?v=dQw4w9WgXcQ',
    'http://youtu.be/dQw4w9WgXcQ',
    'https://youtube.com/watch',
    'https://youtube.com/watch?v=<script>',
    'https://vimeo.com/channels/staffpicks',
    'javascript:alert(1)',
    'not a url',
  ])('does not embed %s', (link) => {
    expect(embedUrlFor(link)).toBeNull();
  });
});
