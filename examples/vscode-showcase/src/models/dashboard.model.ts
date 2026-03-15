/**
 * Dashboard data models — widgets, layouts, activity feed
 *
 * @see docs/specs/dashboard/design.md#data-model
 */

import { User } from './user.model';

export interface Widget {
  id: string;
  userId: string;
  type: 'tasks_summary' | 'recent_activity' | 'stats_chart' | 'quick_actions';
  title: string;
  config: Record<string, unknown>;
  position: number;
  createdAt: Date;
}

export interface DashboardLayout {
  id: string;
  userId: string;
  columns: number;
  widgetOrder: string[];
  updatedAt: Date;
}

export interface ActivityEntry {
  id: string;
  userId: string;
  action: 'created' | 'updated' | 'completed' | 'commented';
  entityType: 'task' | 'spec' | 'discussion';
  entityId: string;
  summary: string;
  timestamp: Date;
}
