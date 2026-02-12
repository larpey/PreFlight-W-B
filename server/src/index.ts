import app from './app.js';

const PORT = parseInt(process.env.PORT ?? '3001', 10);

app.listen(PORT, () => {
  console.log(`PreFlight API running on port ${PORT}`);
});
