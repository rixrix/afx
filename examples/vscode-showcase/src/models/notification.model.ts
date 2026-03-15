/**
 * Notification data models — notification entity and preferences
 *
 * @see docs/specs/notifications/spec.md#fr-1-notification-types
 * @see docs/specs/notifications/spec.md#fr-3-notification-preferences
 */

import { User } from './user.model';

export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  read: boolean;
  actionUrl?: string;
  createdAt: Date;
}

export type NotificationType =
  | 'task_assigned'
  | 'task_complete'
  | 'mention'
  | 'system'
  | 'deadline_warning';

export interface NotificationPreference {
  userId: string;
  channel: 'in_app' | 'email';
  type: NotificationType;
  enabled: boolean;
}
