'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';
import { createGroupAction, updateGroupAction } from '@/app/community-actions';
import { FormDialog } from '@/components/ui/form-dialog';
import { GROUP_TYPES, validateGroup } from '@/lib/moderation';

interface Initial {
  id: string;
  name: string;
  description: string;
  visibility: string;
  isOfficial: boolean;
}

/** Create an official group, or edit one (the address and type are fixed once created). */
export function GroupForm({ mode, initial }: { mode: 'create' | 'edit'; initial?: Initial }) {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const [name, setName] = useState(initial?.name ?? '');
  const [slug, setSlug] = useState('');
  const [type, setType] = useState<string>(GROUP_TYPES[0]);
  const [description, setDescription] = useState(initial?.description ?? '');
  const [visibility, setVisibility] = useState(initial?.visibility ?? 'OPEN');
  const [isOfficial, setIsOfficial] = useState(initial?.isOfficial ?? true);
  const [error, setError] = useState<string | null>(null);
  const [pending, start] = useTransition();
  const creating = mode === 'create';

  const close = () => {
    setOpen(false);
    setError(null);
  };

  const submit = () => {
    const problem = validateGroup({ name, slug, description }, creating);
    if (problem) return setError(problem);
    start(async () => {
      const input = { name, slug, type, description, visibility, isOfficial };
      const res = creating
        ? await createGroupAction(input)
        : await updateGroupAction(initial!.id, input);
      if (res.ok) {
        close();
        if (creating) {
          setName('');
          setSlug('');
          setDescription('');
        }
        router.refresh();
      } else {
        setError(res.error);
      }
    });
  };

  return (
    <>
      <button
        type="button"
        className={`button ${creating ? '' : 'secondary'}`.trim()}
        onClick={() => setOpen(true)}
      >
        {creating ? 'New group' : 'Edit group'}
      </button>
      <FormDialog
        open={open}
        title={creating ? 'New group' : 'Edit group'}
        submitLabel={creating ? 'Create group' : 'Save changes'}
        pending={pending}
        error={error}
        onSubmit={submit}
        onCancel={close}
      >
        <label className="field">
          Name
          <input
            className="input"
            value={name}
            maxLength={80}
            onChange={(e) => setName(e.target.value)}
          />
        </label>
        {creating ? (
          <>
            <label className="field">
              Address (optional)
              <input
                className="input"
                value={slug}
                placeholder="defaults to the name"
                onChange={(e) => setSlug(e.target.value)}
              />
            </label>
            <label className="field">
              Type
              <select className="select" value={type} onChange={(e) => setType(e.target.value)}>
                {GROUP_TYPES.map((t) => (
                  <option key={t} value={t}>
                    {t.charAt(0) + t.slice(1).toLowerCase()}
                  </option>
                ))}
              </select>
            </label>
          </>
        ) : null}
        <label className="field">
          Description
          <textarea
            className="textarea"
            value={description}
            maxLength={600}
            onChange={(e) => setDescription(e.target.value)}
          />
        </label>
        <label className="field">
          Visibility
          <select
            className="select"
            value={visibility}
            onChange={(e) => setVisibility(e.target.value)}
          >
            <option value="OPEN">Open: anyone can join</option>
            <option value="PRIVATE">Private</option>
          </select>
        </label>
        <label className="field">
          <span>
            <input
              type="checkbox"
              checked={isOfficial}
              onChange={(e) => setIsOfficial(e.target.checked)}
            />{' '}
            Official group (run by Atarah)
          </span>
        </label>
      </FormDialog>
    </>
  );
}
