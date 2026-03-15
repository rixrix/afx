/**
 * Dashboard API routes — widget data, layout preferences, activity feed
 *
 * @see docs/specs/dashboard/design.md#api-endpoints
 * @see docs/specs/dashboard/tasks.md#21-implement-widget-api
 */

import { getDashboardService } from '../services/dashboard.service';
import { requireAuth, AuthenticatedRequest } from '../middleware/auth.middleware';
import { registerAuthRoutes } from './auth.routes';

export function registerDashboardRoutes(app: unknown, db: unknown) {
  const dashboardService = getDashboardService(db);

  return {
    async handleGetWidgets(req: { headers: Record<string, string> }) {
      const authed = requireAuth(req);
      return dashboardService.getWidgets(authed.auth.userId);
    },

    async handleUpdateLayout(req: { headers: Record<string, string>; body: { layout: unknown } }) {
      const authed = requireAuth(req);
      return dashboardService.updateLayout(authed.auth.userId, req.body.layout);
    },

    async handleGetActivity(req: { headers: Record<string, string> }) {
      const authed = requireAuth(req);
      return dashboardService.getActivityFeed(authed.auth.userId);
    },
  };
}
