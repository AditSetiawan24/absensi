import { writable } from 'svelte/store';

interface SettingsState {
  isDarkMode: boolean;
  isNotificationEnabled: boolean;
}

const storedSettings = localStorage.getItem('settings');
const initialSettings: SettingsState = storedSettings ? JSON.parse(storedSettings) : {
  isDarkMode: false,
  isNotificationEnabled: true
};

export const settingsStore = writable<SettingsState>(initialSettings);

settingsStore.subscribe(value => {
  localStorage.setItem('settings', JSON.stringify(value));
  
  if (typeof document !== 'undefined') {
    if (value.isDarkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }
});
