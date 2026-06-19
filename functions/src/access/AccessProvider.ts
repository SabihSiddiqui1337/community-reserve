/**
 * Door-hardware abstraction (PROJECT-BRIEF §8). Real lock vendors (Kisi, Brivo,
 * Igloohome, …) plug in behind this interface later. The reservation already
 * carries pinHash / qrToken / accessCredentialId, so a vendor implementation
 * maps a booking window to a time-bound credential.
 */

export interface AccessReservation {
  reservationId: string;
  communityId: string;
  amenityId: string;
  startTime: Date;
  endTime: Date;
}

export interface AccessCredential {
  accessCredentialId: string;
  provider: string;
}

export interface AccessProvider {
  /** Issue a time-bound credential for a confirmed reservation. */
  provisionCredential(reservation: AccessReservation): Promise<AccessCredential>;

  /** Revoke on release / expiry / cancellation. */
  revokeCredential(reservation: AccessReservation): Promise<void>;
}
