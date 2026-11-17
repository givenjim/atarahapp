import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { UpdateAccountPreferencesDto } from './preferences.dto';
import { PreferencesService } from './preferences.service';

const errorsFor = (body: object) =>
  validateSync(plainToInstance(UpdateAccountPreferencesDto, body)).map((e) => e.property);

describe('UpdateAccountPreferencesDto', () => {
  it('accepts valid and partial bodies', () => {
    expect(errorsFor({})).toEqual([]);
    expect(
      errorsFor({
        appearance: 'DARK',
        locale: 'sw',
        timeZone: 'Africa/Nairobi',
        marketingOptIn: true,
      }),
    ).toEqual([]);
    expect(errorsFor({ locale: 'en-KE' })).toEqual([]);
  });
  it('rejects bad values', () => {
    expect(errorsFor({ appearance: 'SEPIA' })).toEqual(['appearance']);
    expect(errorsFor({ locale: 'English!' })).toEqual(['locale']);
    expect(errorsFor({ timeZone: 'Mars/Olympus' })).toEqual(['timeZone']);
    expect(errorsFor({ marketingOptIn: 'yes' })).toEqual(['marketingOptIn']);
  });
});

describe('PreferencesService', () => {
  const upsert = jest.fn(async (args: { create: object }) => args.create);
  const service = new PreferencesService({ memberPreference: { upsert } } as never);
  beforeEach(() => upsert.mockClear());

  it('get creates with defaults and changes nothing on an existing row', async () => {
    await service.get('u1');
    expect(upsert).toHaveBeenCalledWith(
      expect.objectContaining({ create: { userId: 'u1' }, update: {} }),
    );
  });
  it('update writes only the supplied fields', async () => {
    await service.update('u1', { appearance: 'DARK' });
    const arg = upsert.mock.calls[0]![0] as unknown as { update: object };
    expect(arg.update).toEqual({ appearance: 'DARK' });
  });
});
