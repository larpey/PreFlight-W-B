import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import authRoutes from './routes/auth.js';
import scenarioRoutes from './routes/scenarios.js';

const app = express();
const PORT = parseInt(process.env.PORT ?? '3001', 10);

// Security
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGIN ?? 'https://preflight.valderis.com',
  credentials: true,
}));
app.use(express.json({ limit: '1mb' }));

// Health check
app.get('/health', (_req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Routes
app.use('/auth', authRoutes);
app.use('/scenarios', scenarioRoutes);

app.listen(PORT, () => {
  console.log(`PreFlight API running on port ${PORT}`);
});

export default app;
