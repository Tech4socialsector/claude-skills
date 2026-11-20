// src/utils/notify.js — readable error messages + toast shortcuts.
// Toasts render through <FrappeUIProvider> in App.vue (mount it exactly once).
import { toast } from 'frappe-ui'

/**
 * Best human-readable message from anything thrown by useCall/submit (FrappeResponseError),
 * callMethod (Error with `messages`), a plain Error, or a string.
 */
export function errorMessage(err, fallback = 'Something went wrong. Please try again.') {
  if (!err) return fallback
  if (typeof err === 'string') return err
  const first = Array.isArray(err.messages) ? err.messages.filter(Boolean)[0] : ''
  const text = String(first || err.message || '')
  // Strip any HTML the server put in the message.
  return text.replace(/<[^>]*>/g, '').trim() || fallback
}

export const notify = {
  success: (message, options) => toast.success(message, options),
  info: (message, options) => toast.info(message, options),
  warning: (message, options) => toast.warning(message, options),
  error: (err, fallback) => toast.error(errorMessage(err, fallback)),
}
