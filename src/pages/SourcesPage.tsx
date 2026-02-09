import type { ReactNode } from 'react';
import type { Aircraft, SourceAttribution } from '../types/aircraft';
import { NavBar } from '../components/layout/NavBar';
import { SourcePanel } from '../components/sources/SourcePanel';
import { regulatoryReferences } from '../data/regulatory';

interface SourcesPageProps {
  aircraft: Aircraft;
  onBack: () => void;
}

function SourceSection({ title, children }: { title: string; children: ReactNode }) {
  return (
    <section>
      <h2 className="text-[13px] font-medium text-ios-gray-1 uppercase tracking-wide mb-2 px-1">
        {title}
      </h2>
      <div className="space-y-3">{children}</div>
    </section>
  );
}

function SpecRow({ label, value, unit, source }: {
  label: string;
  value: string | number;
  unit: string;
  source: ReactNode;
}) {
  return (
    <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
      <div className="flex items-center justify-between mb-1">
        <span className="text-[15px] font-medium text-ios-text dark:text-white">{label}</span>
        <span className="text-[15px] tabular-nums text-ios-text dark:text-white">
          {typeof value === 'number' ? value.toLocaleString() : value} {unit}
        </span>
      </div>
      {source}
    </div>
  );
}

export function SourcesPage({ aircraft, onBack }: SourcesPageProps) {
  return (
    <div className="flex flex-col min-h-screen">
      <NavBar title={`Sources: ${aircraft.model}`} onBack={onBack} />

      <div className="flex-1 px-4 py-4 space-y-6">
        {/* Aircraft info */}
        <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
          <div className="text-[17px] font-semibold text-ios-text dark:text-white">
            {aircraft.name}
          </div>
          <div className="text-[13px] text-ios-gray-1 mt-0.5">
            {aircraft.manufacturer}{aircraft.year ? ` · ${aircraft.year}` : ''} · TCDS {aircraft.regulatory.tcdsNumber}
          </div>
          <div className="text-[13px] text-ios-gray-1 mt-0.5">
            Datum: {aircraft.datum}
          </div>
        </div>

        {/* Weight specifications */}
        <SourceSection title="Weight Specifications">
          <SpecRow
            label="Empty Weight"
            value={aircraft.emptyWeight.value}
            unit="lbs"
            source={<InlineSource source={aircraft.emptyWeight.source} />}
          />
          <SpecRow
            label="Max Gross Weight"
            value={aircraft.maxGrossWeight.value}
            unit="lbs"
            source={<InlineSource source={aircraft.maxGrossWeight.source} />}
          />
          <SpecRow
            label="Useful Load"
            value={aircraft.usefulLoad.value}
            unit="lbs"
            source={<InlineSource source={aircraft.usefulLoad.source} />}
          />
        </SourceSection>

        {/* CG Range */}
        <SourceSection title="CG Range">
          <SpecRow
            label="Forward Limit"
            value={aircraft.cgRange.forward.value}
            unit="inches"
            source={<InlineSource source={aircraft.cgRange.forward.source} />}
          />
          <SpecRow
            label="Aft Limit"
            value={aircraft.cgRange.aft.value}
            unit="inches"
            source={<InlineSource source={aircraft.cgRange.aft.source} />}
          />
        </SourceSection>

        {/* Stations */}
        <SourceSection title="Loading Stations">
          {aircraft.stations.map(s => (
            <SpecRow
              key={s.id}
              label={s.name}
              value={`Arm ${s.arm.value}"`}
              unit={s.maxWeight ? `(max ${s.maxWeight} lbs)` : ''}
              source={<InlineSource source={s.arm.source} />}
            />
          ))}
        </SourceSection>

        {/* Fuel */}
        <SourceSection title="Fuel Tanks">
          {aircraft.fuelTanks.map(t => (
            <SpecRow
              key={t.id}
              label={t.name}
              value={`${t.maxGallons.value} gal @ arm ${t.arm.value}"`}
              unit=""
              source={<InlineSource source={t.maxGallons.source} />}
            />
          ))}
        </SourceSection>

        {/* CG Envelope */}
        <SourceSection title="CG Envelope">
          <div className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
            <SourcePanel source={aircraft.cgEnvelope.source} onClose={() => {}} />
          </div>
        </SourceSection>

        {/* Regulatory References */}
        <SourceSection title="Regulatory References">
          {Object.entries(regulatoryReferences).map(([ref, data]) => (
            <div key={ref} className="bg-white dark:bg-[#1C1C1E] rounded-xl px-4 py-3">
              <div className="text-[15px] font-medium text-ios-text dark:text-white">{ref}</div>
              <div className="text-[13px] text-ios-text-secondary dark:text-ios-gray-2 mt-0.5">
                {data.title}
              </div>
              <div className="text-[12px] text-ios-gray-1 mt-1 leading-relaxed">
                {data.text.substring(0, 200)}...
              </div>
              <a
                href={data.url}
                target="_blank"
                rel="noopener noreferrer"
                className="text-[12px] text-ios-blue mt-1 inline-block"
              >
                View Full Text →
              </a>
            </div>
          ))}
        </SourceSection>

        <div className="h-8" />
      </div>
    </div>
  );
}

function InlineSource({ source }: { source: SourceAttribution }) {
  return (
    <div className="text-[11px] text-ios-gray-1 mt-1 flex items-center gap-2 flex-wrap">
      <span className={`w-2 h-2 rounded-full ${
        source.confidence === 'high' ? 'bg-confidence-high' :
        source.confidence === 'medium' ? 'bg-confidence-medium' : 'bg-confidence-low'
      }`} />
      <span>{source.primary.document}</span>
      <span>·</span>
      <span>{source.primary.section}</span>
      {source.notes && (
        <span className="text-ios-orange">· {source.notes.substring(0, 80)}...</span>
      )}
    </div>
  );
}
