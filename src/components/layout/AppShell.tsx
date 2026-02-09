import { type ReactNode, useState, useEffect } from 'react';
import { useOnlineStatus } from '../../hooks/useOnlineStatus';

function OfflineBanner() {
  return (
    <div className="bg-ios-orange text-white text-center text-[12px] py-1 px-4 font-medium">
      Offline — using cached data
    </div>
  );
}

function InstallBanner() {
  const [show, setShow] = useState(false);
  const [dismissed, setDismissed] = useState(false);

  useEffect(() => {
    // Only show on iOS Safari when not already installed as PWA
    const isIOS = /iPhone|iPad|iPod/.test(navigator.userAgent);
    const isStandalone =
      ('standalone' in navigator && (navigator as { standalone?: boolean }).standalone) ||
      window.matchMedia('(display-mode: standalone)').matches;
    const wasDismissed = sessionStorage.getItem('install-banner-dismissed');

    if (isIOS && !isStandalone && !wasDismissed) {
      setShow(true);
    }
  }, []);

  if (!show || dismissed) return null;

  return (
    <div className="bg-ios-blue/10 dark:bg-ios-blue/20 border-b border-ios-blue/20 px-4 py-3 flex items-start gap-3">
      <div className="flex-1">
        <div className="text-[13px] font-medium text-ios-text dark:text-white">
          Install as App
        </div>
        <div className="text-[11px] text-ios-gray-1 mt-0.5">
          Tap the share button, then "Add to Home Screen" for the full app experience.
        </div>
      </div>
      <button
        onClick={() => {
          setDismissed(true);
          sessionStorage.setItem('install-banner-dismissed', '1');
        }}
        className="text-ios-blue text-[13px] min-w-[44px] min-h-[44px] flex items-center justify-center active:opacity-60"
      >
        ✕
      </button>
    </div>
  );
}

export function AppShell({ children }: { children: ReactNode }) {
  const isOnline = useOnlineStatus();

  return (
    <div className="min-h-screen bg-ios-gray-6 dark:bg-black safe-top safe-bottom">
      {!isOnline && <OfflineBanner />}
      <InstallBanner />
      {children}
    </div>
  );
}
