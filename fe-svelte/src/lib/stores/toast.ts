import { writable } from 'svelte/store';

export type ToastType = 'success' | 'error' | 'info' | 'warning';

export interface ToastMessage {
  id: number;
  message: string;
  type: ToastType;
}

const { subscribe, update } = writable<ToastMessage[]>([]);

let nextId = 0;

export const toast = {
  subscribe,
  show: (message: string, type: ToastType = 'info', duration: number = 3000) => {
    const id = ++nextId;
    update(toasts => [...toasts, { id, message, type }]);
    setTimeout(() => {
      update(toasts => toasts.filter(t => t.id !== id));
    }, duration);
  },
  success: (message: string) => toast.show(message, 'success'),
  error: (message: string) => toast.show(message, 'error'),
  warning: (message: string) => toast.show(message, 'warning'),
  info: (message: string) => toast.show(message, 'info'),
};
