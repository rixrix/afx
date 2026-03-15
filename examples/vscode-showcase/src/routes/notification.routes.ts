/**
 * Notification API routes — list, read, count endpoints
 *
 * @see docs/specs/notifications/spec.md#fr-1-notification-types
 * @see docs/specs/notifications/research/0001-notification-delivery.md
 */

import { getNotificationService } from '../services/notification.service';
import { requireAuth } from '../middleware/auth.middleware';
import { registerAuthRoutes } from './auth.routes';

export function registerNotificationRoutes(app: unknown, db: unknown) {
  const notificationService = getNotificationService(db);

  return {
    async handleList(req: { headers: Record<string, string>; query: { limit?: string } }) {
      const authed = requireAuth(req);
      const limit = Number(req.query.limit) || 20;
      return notificationService.getNotifications(authed.auth.userId, limit);
    },

    async handleMarkRead(req: { headers: Record<string, string>; params: { id: string } }) {
      requireAuth(req);
      return notificationService.markAsRead(req.params.id);
    },

    async handleMarkAllRead(req: { headers: Record<string, string> }) {
      const authed = requireAuth(req);
      return notificationService.markAllAsRead(authed.auth.userId);
    },

    async handleUnreadCount(req: { headers: Record<string, string> }) {
      const authed = requireAuth(req);
      return notificationService.getUnreadCount(authed.auth.userId);
    },
  };
}
