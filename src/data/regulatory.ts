export const regulatoryReferences: Record<string, {
  title: string;
  text: string;
  url: string;
}> = {
  'FAR 91.103': {
    title: 'Preflight Action',
    text: 'Each pilot in command shall, before beginning a flight, become familiar with all available information concerning that flight, including for flights not in the vicinity of an airport, weather reports and forecasts, fuel requirements, alternatives available if the planned flight cannot be completed, and any known traffic delays of which the pilot in command has been advised by ATC. For any flight, runway lengths at airports of intended use, and the following takeoff and landing distance data: for civil aircraft for which an approved Airplane or Rotorcraft Flight Manual containing takeoff and landing distance data is required, the takeoff and landing distance data contained therein.',
    url: 'https://www.ecfr.gov/current/title-14/chapter-I/subchapter-F/part-91/subpart-B/subject-group-ECFRe4c59b5f5506932/section-91.103',
  },
  'FAR 23.23': {
    title: 'Load Distribution Limits',
    text: 'Ranges of weights and centers of gravity within which the airplane may be safely operated must be established. If a weight and center of gravity combination is allowable only within certain load distribution limits that could be inadvertently exceeded, these limits and the corresponding weight and center of gravity combinations must be accounted for in the Airplane Flight Manual.',
    url: 'https://www.ecfr.gov/current/title-14/part-23',
  },
  'AC 120-27F': {
    title: 'Aircraft Weight and Balance Control',
    text: 'This Advisory Circular provides guidance and acceptable methods for complying with the requirements for weight and balance control of aircraft operated under 14 CFR Parts 91, 121, 125, and 135.',
    url: 'https://www.faa.gov/regulations_policies/advisory_circulars',
  },
};

export const disclaimer = `IMPORTANT: This calculator is a supplemental planning tool only. It does NOT replace the official Pilot's Operating Handbook (POH) or aircraft-specific weight and balance records.

Per FAR 91.103, the pilot in command is solely responsible for determining the aircraft is within approved weight and balance limits before each flight.

Always verify calculations against your aircraft's actual empty weight, CG, and loading data from the most recent weight and balance record. Aircraft empty weights and CG positions shown here are TYPICAL values and will differ from your specific aircraft.

This tool uses simplified CG envelopes. Always refer to the actual POH loading chart for your aircraft.`;
