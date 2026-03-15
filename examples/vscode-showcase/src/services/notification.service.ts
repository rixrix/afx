/**
 * Notification service — in-app notification delivery and management
 *
 * @see docs/specs/notifications/spec.md#fr-1-notification-types
 */

import { User } from '../models/user.model';
import { Notification, NotificationPreference } from '../models/notification.model';
import { createLogger } from '../utils/logger';
import { getAuthService } from './auth.service';

export function getNotificationService(db: unknown) {
  const authService = getAuthService(db);
  return {
    async getNotifications(userId: string, limit = 20): Promise<Notification[]> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async markAsRead(notificationId: string): Promise<void> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async markAllAsRead(userId: string): Promise<void> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async getUnreadCount(userId: string): Promise<number> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },
  };
}
