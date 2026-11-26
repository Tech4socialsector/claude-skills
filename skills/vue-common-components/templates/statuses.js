// src/config/statuses.js — status word → Badge theme, used by StatusBadge.vue.
// frappe-ui 1.x Badge themes: gray | blue | green | amber | red | violet
//   green  = done / positive        red    = negative / stopped
//   amber  = waiting on someone     blue   = in progress, on track
//   violet = special / attention    gray   = neutral / unknown (fallback)
//
// Common workflow words are pre-filled. Add your project's statuses in PROJECT, using the
// exact spelling stored in the database.

const GREEN = ['Approved', 'Completed', 'Complete', 'Active', 'Paid', 'Verified', 'Accepted', 'Published', 'Closed', 'Resolved', 'Enabled', 'Success']
const RED = ['Rejected', 'Cancelled', 'Canceled', 'Declined', 'Expired', 'Failed', 'Overdue', 'Withdrawn', 'Disabled', 'Blocked']
const AMBER = ['Pending', 'Draft', 'Under Review', 'Pending Approval', 'On Hold', 'Awaiting Response', 'Partially Paid', 'Unpaid']
const BLUE = ['Open', 'Submitted', 'In Progress', 'Sent', 'Scheduled', 'Confirmed', 'Processing', 'Replied']

// Project-specific statuses — add here:
const PROJECT = {
  // 'Admitted': 'green',
  // 'Escalated': 'violet',
}

export const STATUS_TONES = {
  ...Object.fromEntries(GREEN.map((s) => [s, 'green'])),
  ...Object.fromEntries(RED.map((s) => [s, 'red'])),
  ...Object.fromEntries(AMBER.map((s) => [s, 'amber'])),
  ...Object.fromEntries(BLUE.map((s) => [s, 'blue'])),
  ...PROJECT,
}
