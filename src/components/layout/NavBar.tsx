import type { ReactNode } from 'react';

interface NavBarProps {
  title: string;
  onBack?: () => void;
  rightAction?: ReactNode;
}

export function NavBar({ title, onBack, rightAction }: NavBarProps) {
  return (
    <nav className="sticky top-0 z-50 backdrop-blur-xl bg-ios-gray-6/80 dark:bg-black/80 border-b border-ios-separator dark:border-[#38383A]">
      <div className="flex items-center justify-between h-11 px-4">
        {onBack ? (
          <button
            onClick={onBack}
            className="text-ios-blue text-[17px] min-w-[44px] min-h-[44px] flex items-center active:opacity-60"
          >
            ‹ Back
          </button>
        ) : (
          <div className="w-11" />
        )}
        <h1 className="text-[17px] font-semibold text-black dark:text-white truncate mx-4">
          {title}
        </h1>
        {rightAction ?? <div className="w-11" />}
      </div>
    </nav>
  );
}
