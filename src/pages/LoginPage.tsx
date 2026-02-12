import { useState, useEffect, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useAuth } from '../contexts/AuthContext';
import { apiFetch } from '../services/api';

interface LoginPageProps {
  onComplete: () => void;
}

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID ?? '';

const ease: [number, number, number, number] = [0.25, 0.1, 0.25, 1];
const fadeUp = {
  hidden: { opacity: 0, y: 16 },
  visible: { opacity: 1, y: 0, transition: { duration: 0.4, ease } },
};
const stagger = {
  hidden: {},
  visible: { transition: { staggerChildren: 0.08, delayChildren: 0.05 } },
};

export function LoginPage({ onComplete }: LoginPageProps) {
  const { login, continueAsGuest } = useAuth();
  const [email, setEmail] = useState('');
  const [codeSent, setCodeSent] = useState(false);
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Initialize Google Sign-In
  useEffect(() => {
    if (!GOOGLE_CLIENT_ID) return;

    const script = document.createElement('script');
    script.src = 'https://accounts.google.com/gsi/client';
    script.async = true;
    script.onload = () => {
      window.google?.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: handleGoogleResponse,
      });
      window.google?.accounts.id.renderButton(
        document.getElementById('google-signin-btn')!,
        {
          theme: 'filled_black',
          size: 'large',
          width: 320,
          shape: 'pill',
          text: 'continue_with',
        }
      );
    };
    document.head.appendChild(script);

    return () => { script.remove(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const handleGoogleResponse = useCallback(async (response: { credential: string }) => {
    setLoading(true);
    setError('');
    try {
      const data = await apiFetch<{ token: string; user: { id: string; email: string; name: string; avatarUrl: string } }>(
        '/auth/google',
        { method: 'POST', body: JSON.stringify({ idToken: response.credential }) }
      );
      await login(data.token, data.user);
      onComplete();
    } catch {
      setError('Google sign-in failed. Please try again.');
    } finally {
      setLoading(false);
    }
  }, [login, onComplete]);

  const handleSendCode = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email.trim()) return;

    setLoading(true);
    setError('');
    try {
      await apiFetch('/auth/magic-link', {
        method: 'POST',
        body: JSON.stringify({ email: email.trim() }),
      });
      setCodeSent(true);
    } catch {
      setError('Failed to send code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyCode = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!code.trim()) return;

    setLoading(true);
    setError('');
    try {
      const data = await apiFetch<{ token: string; user: { id: string; email: string; name: string; avatarUrl: string } }>(
        '/auth/verify',
        { method: 'POST', body: JSON.stringify({ email: email.trim(), code: code.trim() }) }
      );
      await login(data.token, data.user);
      onComplete();
    } catch {
      setError('Invalid or expired code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleGuest = () => {
    continueAsGuest();
    onComplete();
  };

  return (
    <div className="min-h-dvh bg-black flex items-center justify-center">
      <motion.div
        className="max-w-[400px] w-full px-6 py-12 flex flex-col items-center text-center"
        variants={stagger}
        initial="hidden"
        animate="visible"
      >
        {/* Header */}
        <motion.div variants={fadeUp} className="mb-2">
          <svg viewBox="0 0 48 48" width="56" height="56">
            <rect width="48" height="48" rx="12" fill="#007AFF" opacity="0.15" />
            <text x="24" y="32" textAnchor="middle" fontSize="24">⚖️</text>
          </svg>
        </motion.div>

        <motion.h1 variants={fadeUp} className="text-[28px] font-bold text-white mb-2">
          Sign In
        </motion.h1>
        <motion.p variants={fadeUp} className="text-[15px] text-white/50 mb-8 max-w-[300px]">
          Sign in to save scenarios and sync across your devices.
        </motion.p>

        {/* Google Sign-In */}
        {GOOGLE_CLIENT_ID && (
          <motion.div variants={fadeUp} className="mb-6 w-full flex justify-center min-h-11">
            <div id="google-signin-btn" />
          </motion.div>
        )}

        {/* Divider */}
        {GOOGLE_CLIENT_ID && (
          <motion.div variants={fadeUp} className="flex items-center gap-3 mb-6 w-full max-w-[320px]">
            <div className="flex-1 h-px bg-white/10" />
            <span className="text-[13px] text-white/30">or</span>
            <div className="flex-1 h-px bg-white/10" />
          </motion.div>
        )}

        {/* Email / Code */}
        <motion.div variants={fadeUp} className="w-full max-w-[320px] mb-6">
          <AnimatePresence mode="wait">
            {!codeSent ? (
              <motion.form
                key="email"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}
                onSubmit={handleSendCode}
              >
                <input
                  type="email"
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  placeholder="Email address"
                  className="w-full px-4 py-3.5 bg-white/5 border border-white/10 rounded-xl text-white text-[16px] placeholder:text-white/30 outline-none focus:border-ios-blue/50 transition-colors mb-3"
                  disabled={loading}
                />
                <button
                  type="submit"
                  disabled={loading || !email.trim()}
                  className="w-full py-3.5 bg-ios-blue rounded-xl text-white text-[16px] font-semibold disabled:opacity-40 transition-opacity"
                >
                  {loading ? 'Sending...' : 'Send Sign-In Code'}
                </button>
              </motion.form>
            ) : (
              <motion.form
                key="code"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                transition={{ duration: 0.2 }}
                onSubmit={handleVerifyCode}
              >
                <p className="text-white/50 text-[14px] leading-relaxed mb-4 text-center">
                  We sent a 6-digit code to <span className="text-white/70 font-medium">{email}</span>
                </p>
                <input
                  type="text"
                  inputMode="numeric"
                  autoComplete="one-time-code"
                  maxLength={6}
                  value={code}
                  onChange={e => setCode(e.target.value.replace(/\D/g, ''))}
                  placeholder="000000"
                  className="w-full px-4 py-4 bg-white/5 border border-white/10 rounded-xl text-white text-center text-[28px] font-bold tracking-[0.3em] placeholder:text-white/15 outline-none focus:border-ios-blue/50 transition-colors mb-3"
                  disabled={loading}
                  autoFocus
                />
                <button
                  type="submit"
                  disabled={loading || code.length !== 6}
                  className="w-full py-3.5 bg-ios-blue rounded-xl text-white text-[16px] font-semibold disabled:opacity-40 transition-opacity mb-3"
                >
                  {loading ? 'Verifying...' : 'Verify Code'}
                </button>
                <button
                  type="button"
                  onClick={() => { setCodeSent(false); setCode(''); setError(''); }}
                  className="w-full text-[14px] text-white/30 hover:text-white/50 transition-colors"
                >
                  Use a different email
                </button>
              </motion.form>
            )}
          </AnimatePresence>
        </motion.div>

        {/* Error */}
        {error && (
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-ios-red text-[13px] mb-4"
          >
            {error}
          </motion.p>
        )}

        {/* Guest */}
        <motion.button
          variants={fadeUp}
          onClick={handleGuest}
          className="text-[15px] text-white/40 hover:text-white/60 transition-colors"
        >
          Continue as Guest
        </motion.button>

        <motion.p variants={fadeUp} className="text-[11px] text-white/20 mt-8 max-w-[280px]">
          Guest mode works fully offline but scenarios won't be saved or synced across devices.
        </motion.p>
      </motion.div>
    </div>
  );
}

// Google Identity Services types
declare global {
  interface Window {
    google?: {
      accounts: {
        id: {
          initialize: (config: { client_id: string; callback: (response: { credential: string }) => void }) => void;
          renderButton: (element: HTMLElement, options: Record<string, unknown>) => void;
        };
      };
    };
  }
}
