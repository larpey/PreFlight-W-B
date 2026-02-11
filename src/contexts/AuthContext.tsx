import { createContext, useContext, useState, useEffect, useCallback, type ReactNode } from 'react';
import { getDB } from '../db';

interface AuthUser {
  id: string;
  email: string;
  name?: string;
  avatarUrl?: string;
}

interface AuthState {
  user: AuthUser | null;
  isAuthenticated: boolean;
  isGuest: boolean;
  isLoading: boolean;
  login: (token: string, user: AuthUser) => Promise<void>;
  logout: () => Promise<void>;
  continueAsGuest: () => void;
}

const AuthContext = createContext<AuthState | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [isGuest, setIsGuest] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  // Load saved session on mount
  useEffect(() => {
    (async () => {
      try {
        const db = await getDB();
        const session = await db.get('auth', 'session');
        if (session?.token && session.user) {
          setUser(session.user);
        }
      } catch {
        // IndexedDB not available — continue as guest
      } finally {
        setIsLoading(false);
      }
    })();
  }, []);

  const login = useCallback(async (token: string, authUser: AuthUser) => {
    const db = await getDB();
    await db.put('auth', { key: 'session', token, user: authUser });
    setUser(authUser);
    setIsGuest(false);
  }, []);

  const logout = useCallback(async () => {
    try {
      const db = await getDB();
      await db.delete('auth', 'session');
    } catch {
      // Ignore IndexedDB errors on logout
    }
    setUser(null);
    setIsGuest(false);
  }, []);

  const continueAsGuest = useCallback(() => {
    setIsGuest(true);
  }, []);

  return (
    <AuthContext.Provider value={{
      user,
      isAuthenticated: !!user,
      isGuest,
      isLoading,
      login,
      logout,
      continueAsGuest,
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth(): AuthState {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
}
