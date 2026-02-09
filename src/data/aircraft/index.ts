import type { Aircraft } from '../../types/aircraft';
import { cessna172m } from './cessna172m';
import { bonanzaA36 } from './bonanzaA36';
import { cherokee6 } from './cherokee6';
import { navajoChieftain } from './navajoChieftain';

export const aircraftDatabase: Aircraft[] = [
  cessna172m,
  bonanzaA36,
  cherokee6,
  navajoChieftain,
];

export function getAircraftById(id: string): Aircraft | undefined {
  return aircraftDatabase.find(a => a.id === id);
}
