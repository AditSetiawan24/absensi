import { writable } from 'svelte/store';

function createLocationStore() {
  const getHash = () => {
    if (typeof window === 'undefined') return '/';
    const hash = window.location.hash || '';
    const clean = hash.replace(/^#\/?/, '/').split('?')[0] || '/';
    return clean.startsWith('/') ? clean : '/' + clean;
  };
  
  const { subscribe, set } = writable(getHash());

  const update = () => set(getHash());

  if (typeof window !== 'undefined') {
    window.addEventListener('hashchange', update);
    window.addEventListener('popstate', update);
  }

  return {
    subscribe,
    update
  };
}

export const location = createLocationStore();

