// src/services/api.js — transport helpers. Only files in services/ (and stores/router
// for the imperative call) import from here.
import { call } from 'frappe-ui'

/** URL for a whitelisted method, for useCall({ url }). Frappe v15+ /api/v2 endpoint. */
export function method(path) {
  return `/api/v2/method/${path}`
}

/**
 * Imperative call for code that runs OUTSIDE component setup (Pinia stores, router guards).
 * Inside setup, use useCall via a service instead. Resolves with the method's return value;
 * rejects with an Error carrying `messages` (server messages) and `exc_type`.
 */
export function callMethod(path, params = {}) {
  return call(path, params)
}

/**
 * POST to a whitelisted method that responds with a file
 * (frappe.local.response.type = "download" / "pdf") and save it.
 */
export async function downloadMethod(path, params = {}, fallbackName = 'download') {
  const headers = { 'Content-Type': 'application/json; charset=utf-8' }
  if (window.csrf_token && window.csrf_token !== '{{ csrf_token }}') {
    headers['X-Frappe-CSRF-Token'] = window.csrf_token
  }
  const res = await fetch(`/api/method/${path}`, {
    method: 'POST',
    headers,
    credentials: 'same-origin',
    body: JSON.stringify(params),
  })
  if (!res.ok) {
    const error = new Error(`${path} failed`)
    error.messages = serverMessages(await res.json().catch(() => ({})))
    throw error
  }
  saveBlob(await res.blob(), fileNameFrom(res.headers.get('Content-Disposition')) || fallbackName)
}

/** Save a Blob (or a data: URL) under a file name. */
export function saveBlob(blobOrUrl, fileName) {
  const isBlob = typeof blobOrUrl !== 'string'
  const link = document.createElement('a')
  link.href = isBlob ? URL.createObjectURL(blobOrUrl) : blobOrUrl
  link.download = fileName
  document.body.appendChild(link)
  link.click()
  link.remove()
  // Revoke later: some browsers start the download after click() returns.
  if (isBlob) setTimeout(() => URL.revokeObjectURL(link.href), 10000)
}

function serverMessages(body) {
  try {
    if (body._server_messages) {
      return JSON.parse(body._server_messages).map((m) => {
        try {
          return JSON.parse(m).message
        } catch {
          return m
        }
      })
    }
  } catch {
    /* fall through */
  }
  return body.exception ? [body.exception] : []
}

function fileNameFrom(disposition) {
  if (!disposition) return ''
  const match = /filename\*?=(?:UTF-8'')?"?([^";]+)"?/i.exec(disposition)
  return match ? decodeURIComponent(match[1]) : ''
}
