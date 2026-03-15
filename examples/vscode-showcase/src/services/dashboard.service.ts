/**
 * Dashboard service — widget management, layout persistence, activity feed
 *
 * @see docs/specs/dashboard/design.md#service-layer
 * @see docs/specs/dashboard/tasks.md#22-implement-dashboard-service
 */

import { User } from '../models/user.model';
import { Widget, DashboardLayout, ActivityEntry } from '../models/dashboard.model';
import { getNotificationService } from './notification.service';

export function getDashboardService(db: unknown) {
  const notificationService = getNotificationService(db);
  return {
    async getWidgets(userId: string): Promise<Widget[]> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async updateLayout(userId: string, layout: unknown): Promise<DashboardLayout> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async getActivityFeed(userId: string, limit = 50): Promise<ActivityEntry[]> {
      // Implementation placeholder
      throw new Error('Not implemented');
    },

    async addWidget(userId: string, widgetType: string, position: number): Promise<Widget> {
      // TODO: Implement widget creation with default config
      // @see docs/specs/dashboard/tasks.md#23-implement-widget-crud
      throw new Error('Not implemented');
    },

    async removeWidget(userId: string, widgetId: string): Promise<void> {
      throw new Error('Not implemented');
    },
  };
}
