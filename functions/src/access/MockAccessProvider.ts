import * as logger from "firebase-functions/logger";
import {
  AccessProvider,
  AccessReservation,
  AccessCredential,
} from "./AccessProvider";

/**
 * MVP access provider — logs only, issues no real door credential
 * (PROJECT-BRIEF §8). Swap for a Kisi/Brivo/Igloohome implementation later
 * without touching the reservation flow.
 */
export class MockAccessProvider implements AccessProvider {
  async provisionCredential(
    reservation: AccessReservation
  ): Promise<AccessCredential> {
    const accessCredentialId = `mock-${reservation.reservationId}`;
    logger.info("MockAccessProvider.provision", {
      reservationId: reservation.reservationId,
      window: [reservation.startTime, reservation.endTime],
      accessCredentialId,
    });
    return { accessCredentialId, provider: "mock" };
  }

  async revokeCredential(reservation: AccessReservation): Promise<void> {
    logger.info("MockAccessProvider.revoke", {
      reservationId: reservation.reservationId,
    });
  }
}
