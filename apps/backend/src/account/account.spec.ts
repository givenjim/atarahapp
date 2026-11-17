import { inflateRawSync } from 'node:zlib';
import { deviceStartsVerified, twoStepVerdict } from '../access/two-step.policy';
import { maskContact } from './account.service';
import { zip } from './zip';

describe('two-step sign-in on a new device', () => {
  const base = { enabled: true, enforced: true };

  it('does nothing when the member has not turned it on, or the platform switch is off', () => {
    expect(twoStepVerdict({ ...base, enabled: false, aal: 'aal1', device: null })).toBe('OK');
    expect(twoStepVerdict({ ...base, enforced: false, aal: 'aal1', device: null })).toBe('OK');
  });

  it('asks for the second step on an unknown device or one that never passed it', () => {
    expect(twoStepVerdict({ ...base, aal: 'aal1', device: null })).toBe('CHALLENGE');
    expect(twoStepVerdict({ ...base, aal: 'aal1', device: { verifiedAt: null } })).toBe(
      'CHALLENGE',
    );
  });

  it('lets a trusted device through', () => {
    expect(twoStepVerdict({ ...base, aal: 'aal1', device: { verifiedAt: new Date() } })).toBe('OK');
  });

  it('trusts the device once the session passed the second step (AAL2)', () => {
    expect(twoStepVerdict({ ...base, aal: 'aal2', device: { verifiedAt: null } })).toBe(
      'MARK_VERIFIED',
    );
    expect(twoStepVerdict({ ...base, aal: 'aal2', device: { verifiedAt: new Date() } })).toBe('OK');
    expect(twoStepVerdict({ ...base, aal: 'aal2', device: null })).toBe('OK');
  });

  it('a new device starts trusted unless two-step is on and the session has not passed it', () => {
    expect(deviceStartsVerified(false, 'aal1')).toBe(true);
    expect(deviceStartsVerified(true, 'aal1')).toBe(false);
    expect(deviceStartsVerified(true, 'aal2')).toBe(true);
  });
});

describe('maskContact', () => {
  it('hides most of an email or a phone number', () => {
    expect(maskContact('jomo.kimani@gmail.com')).toBe('jo***@gmail.com');
    expect(maskContact('+254712345678')).toBe('+2547*****678');
  });
});

/** Reads the central directory of a ZIP and returns each entry's name and content. */
function unzip(buf: Buffer): Record<string, Buffer> {
  const end = buf.lastIndexOf(Buffer.from([0x50, 0x4b, 0x05, 0x06]));
  const count = buf.readUInt16LE(end + 10);
  let p = buf.readUInt32LE(end + 16);
  const out: Record<string, Buffer> = {};
  for (let i = 0; i < count; i += 1) {
    const method = buf.readUInt16LE(p + 10);
    const size = buf.readUInt32LE(p + 20);
    const nameLen = buf.readUInt16LE(p + 28);
    const local = buf.readUInt32LE(p + 42);
    const name = buf.subarray(p + 46, p + 46 + nameLen).toString('utf8');
    const nLocal = buf.readUInt16LE(local + 26);
    const xLocal = buf.readUInt16LE(local + 28);
    const body = buf.subarray(local + 30 + nLocal + xLocal, local + 30 + nLocal + xLocal + size);
    out[name] = method === 8 ? inflateRawSync(body) : body;
    p += 46 + nameLen;
  }
  return out;
}

describe('zip writer', () => {
  it('round-trips text, binary and unicode names, deflating what compresses', () => {
    const text = Buffer.from(JSON.stringify({ hello: 'world '.repeat(200) }));
    const bin = Buffer.from([0, 1, 2, 3, 250, 251, 252, 253]);
    const out = unzip(
      zip([
        { name: 'a.json', data: text },
        { name: 'media/é.bin', data: bin },
        { name: 'empty.txt', data: Buffer.alloc(0) },
      ]),
    );
    expect(Object.keys(out)).toEqual(['a.json', 'media/é.bin', 'empty.txt']);
    expect(out['a.json']!.equals(text)).toBe(true);
    expect(out['media/é.bin']!.equals(bin)).toBe(true);
    expect(out['empty.txt']!.length).toBe(0);
  });

  it('starts with the local file header signature and ends with the end-of-directory record', () => {
    const z = zip([{ name: 'x', data: Buffer.from('x') }]);
    expect(z.readUInt32LE(0)).toBe(0x04034b50);
    expect(z.readUInt32LE(z.length - 22)).toBe(0x06054b50);
  });
});
