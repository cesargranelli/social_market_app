/**
 * Executado pelo Jest antes de qualquer módulo (setupFiles).
 *
 * Espelha a configuração que o runtime/test lab injeta: o modo offline do
 * firebase-functions-test exige FIREBASE_CONFIG para que initializeApp()
 * funcione sem credenciais reais.
 */
process.env.FIREBASE_CONFIG = JSON.stringify({
  projectId: 'social-market-tests',
});
process.env.GCLOUD_PROJECT = 'social-market-tests';
