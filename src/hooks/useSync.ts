import { useState, useCallback, useEffect, useRef } from 'react';
import { syncScenarios } from '../services/sync';
import { useAuth } from '../contexts/AuthContext';
import { useOnlineStatus } from './useOnlineStatus';

type SyncStatus = 'idle' | 'syncing' | 'synced' | 'error';

export function useSync() {
  const [status, setStatus] = useState<SyncStatus>('idle');
  const [lastSynced, setLastSynced] = useState<string | null>(null);
  const { isAuthenticated } = useAuth();
  const isOnline = useOnlineStatus();
  const syncingRef = useRef(false);

  const sync = useCallback(async () => {
    if (!isAuthenticated || !isOnline || syncingRef.current) return;

    syncingRef.current = true;
    setStatus('syncing');

    try {
      await syncScenarios();
      setStatus('synced');
      setLastSynced(new Date().toISOString());
    } catch {
      setStatus('error');
    } finally {
      syncingRef.current = false;
    }
  }, [isAuthenticated, isOnline]);

  // Auto-sync when coming online
  useEffect(() => {
    if (isOnline && isAuthenticated) {
      sync();
    }
  }, [isOnline, isAuthenticated, sync]);

  return { status, lastSynced, sync };
}
