import { motion } from 'framer-motion';

interface LandingPageProps {
  onEnter: () => void;
}

const features = [
  {
    icon: '⚖️',
    title: 'Weight & Balance',
    desc: 'Real-time CG calculations with visual envelope chart',
  },
  {
    icon: '✈️',
    title: '4 Aircraft',
    desc: 'Cessna 172M, Bonanza A36, Cherokee Six, Navajo Chieftain',
  },
  {
    icon: '📋',
    title: 'Sourced Data',
    desc: 'Every value traced to POH, TCDS, or FAA documents',
  },
  {
    icon: '📡',
    title: 'Works Offline',
    desc: 'PWA — install it, use it on the ramp with no signal',
  },
];

const stagger = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.1, delayChildren: 0.3 } },
};

const ease: [number, number, number, number] = [0.25, 0.1, 0.25, 1];

const fadeUp = {
  hidden: { opacity: 0, y: 24 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.6, ease } },
};

const scaleFade = {
  hidden: { opacity: 0, scale: 0.92 },
  visible: { opacity: 1, scale: 1, transition: { duration: 0.7, ease } },
};

function AircraftSilhouette() {
  return (
    <motion.svg
      viewBox="0 0 400 120"
      className="landing-silhouette"
      initial={{ opacity: 0, x: -60 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 1.2, ease: [0.25, 0.1, 0.25, 1], delay: 0.2 }}
    >
      {/* Simplified Cessna-style profile */}
      <g fill="none" strokeLinecap="round" strokeLinejoin="round">
        {/* Fuselage */}
        <path
          d="M40 60 Q60 52 120 50 L280 48 Q320 46 350 50 L360 54 Q362 58 358 60 L340 62 Q320 64 280 62 L120 60 Q60 62 40 60Z"
          stroke="rgba(0, 122, 255, 0.4)"
          strokeWidth="1.5"
          fill="rgba(0, 122, 255, 0.03)"
        />
        {/* Wing */}
        <path
          d="M160 50 L130 18 Q128 14 132 14 L210 14 Q214 14 212 18 L190 50"
          stroke="rgba(0, 122, 255, 0.35)"
          strokeWidth="1.2"
          fill="rgba(0, 122, 255, 0.02)"
        />
        {/* Tail vertical */}
        <path
          d="M330 48 L322 24 Q320 20 324 20 L348 20 Q352 20 350 24 L342 48"
          stroke="rgba(0, 122, 255, 0.35)"
          strokeWidth="1.2"
          fill="rgba(0, 122, 255, 0.02)"
        />
        {/* Tail horizontal */}
        <path
          d="M320 50 L308 38 Q306 36 310 36 L355 36 Q358 36 356 38 L345 50"
          stroke="rgba(0, 122, 255, 0.3)"
          strokeWidth="1"
          fill="rgba(0, 122, 255, 0.02)"
        />
        {/* Prop */}
        <line x1="38" y1="46" x2="38" y2="74" stroke="rgba(0, 122, 255, 0.5)" strokeWidth="1.5" />
        {/* Wheel struts */}
        <line x1="140" y1="62" x2="140" y2="80" stroke="rgba(0, 122, 255, 0.25)" strokeWidth="1" />
        <line x1="300" y1="62" x2="300" y2="76" stroke="rgba(0, 122, 255, 0.25)" strokeWidth="1" />
        {/* Wheels */}
        <circle cx="140" cy="82" r="4" stroke="rgba(0, 122, 255, 0.3)" strokeWidth="1" />
        <circle cx="300" cy="78" r="3" stroke="rgba(0, 122, 255, 0.3)" strokeWidth="1" />
        {/* Engine */}
        <rect x="30" y="52" width="12" height="16" rx="3" stroke="rgba(0, 122, 255, 0.3)" strokeWidth="1" fill="rgba(0, 122, 255, 0.02)" />
      </g>
    </motion.svg>
  );
}

function HorizonLine() {
  return (
    <motion.div
      className="landing-horizon"
      initial={{ scaleX: 0 }}
      animate={{ scaleX: 1 }}
      transition={{ duration: 1.0, ease: [0.25, 0.1, 0.25, 1], delay: 0.1 }}
    />
  );
}

export function LandingPage({ onEnter }: LandingPageProps) {
  return (
    <motion.div
      className="landing-page"
      exit={{ opacity: 0, scale: 1.02 }}
      transition={{ duration: 0.3, ease }}
    >
      {/* Background grid */}
      <div className="landing-grid" />

      {/* Glow */}
      <div className="landing-glow" />

      <motion.div
        className="landing-content"
        variants={stagger}
        initial="hidden"
        animate="visible"
      >
        {/* Aircraft silhouette */}
        <AircraftSilhouette />

        {/* Horizon line */}
        <HorizonLine />

        {/* Icon + badge */}
        <motion.div variants={fadeUp} className="landing-badge-row">
          <div className="landing-icon">
            <svg viewBox="0 0 48 48" width="48" height="48">
              <rect width="48" height="48" rx="12" fill="#007AFF" opacity="0.15" />
              <text x="24" y="32" textAnchor="middle" fontSize="24">⚖️</text>
            </svg>
          </div>
          <span className="landing-version">v1.0.0</span>
        </motion.div>

        {/* Title */}
        <motion.h1 variants={fadeUp} className="landing-title">
          PreFlight<br />
          <span className="landing-title-accent">W&B</span>
        </motion.h1>

        {/* Subtitle */}
        <motion.p variants={fadeUp} className="landing-subtitle">
          Weight & balance calculator for general aviation.
          Sourced data, real-time CG envelope, works offline.
        </motion.p>

        {/* CTA */}
        <motion.button
          variants={scaleFade}
          onClick={onEnter}
          className="landing-cta"
          whileHover={{ scale: 1.03 }}
          whileTap={{ scale: 0.97 }}
        >
          <span className="landing-cta-text">Let's Fly</span>
          <span className="landing-cta-arrow">→</span>
        </motion.button>

        {/* Features grid */}
        <motion.div variants={stagger} className="landing-features">
          {features.map((f) => (
            <motion.div key={f.title} variants={fadeUp} className="landing-feature-card">
              <span className="landing-feature-icon">{f.icon}</span>
              <span className="landing-feature-title">{f.title}</span>
              <span className="landing-feature-desc">{f.desc}</span>
            </motion.div>
          ))}
        </motion.div>

        {/* Divider */}
        <motion.div variants={fadeUp} className="landing-divider" />

        {/* GitHub / repo info */}
        <motion.div variants={fadeUp} className="landing-repo">
          <div className="landing-repo-header">
            <svg viewBox="0 0 16 16" width="18" height="18" fill="currentColor" className="landing-github-icon">
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
            </svg>
            <span className="landing-repo-name">larpey/PreFlight-W-B</span>
          </div>
          <p className="landing-repo-desc">
            Open-source PWA for GA pilots. 4 aircraft with FAA-sourced specifications,
            real-time CG envelope visualization, and safety warnings.
            Built with React, TypeScript, and Framer Motion.
          </p>
          <a
            href="https://github.com/larpey/PreFlight-W-B"
            target="_blank"
            rel="noopener noreferrer"
            className="landing-repo-link"
          >
            View on GitHub →
          </a>
        </motion.div>

        {/* Footer */}
        <motion.p variants={fadeUp} className="landing-footer">
          Not for flight planning. Always verify with your aircraft's actual W&B records.
        </motion.p>
      </motion.div>
    </motion.div>
  );
}
