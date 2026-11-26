// src/services/dashboard.js — endpoints for templates/dashboard_api.py.
// Factories return useCall instances: call them only during component setup.
import { useCall } from 'frappe-ui'
import { method, downloadMethod } from './api' // vue-architecture/templates/api.js

const M = 'myapp.api.dashboard.' // ← your app's module path

export const dashboardApi = {
  filterOptions: (options = {}) =>
    useCall({ url: method(M + 'get_filter_options'), cacheKey: 'dashboard-filter-options', ...options }),

  // Filters are sent as one JSON string, so arrays and dates survive the GET query string.
  summary: (options = {}) => useCall({ url: method(M + 'get_dashboard'), ...options }),

  drilldown: (options = {}) => useCall({ url: method(M + 'get_drilldown'), immediate: false, ...options }),

  exportCsv: (params) => downloadMethod(M + 'export_drilldown', params, `${params.bucket}.csv`),
}
