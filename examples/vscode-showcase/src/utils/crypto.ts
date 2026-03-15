/**
 * Cryptographic utilities — password hashing, token generation
 *
 * @see docs/specs/user-auth/research/0002-password-hashing.md
 * @see docs/specs/user-auth/design.md#service-layer
 */

import { isStrongPassword } from './validation';

export async function hashPassword(password: string): Promise<string> {
  // NOTE: Uses argon2id as per ADR — see research doc
  // @see docs/specs/user-auth/research/0002-password-hashing.md
  throw new Error('Not implemented');
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
  throw new Error('Not implemented');
}

export function generateTokenId(): string {
  throw new Error('Not implemented');
}

export function hashToken(token: string): string {
  throw new Error('Not implemented');
}
