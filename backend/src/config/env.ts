import 'dotenv/config';
export const env = {
  port: Number(process.env.PORT ?? 4000),
  corsOrigin: process.env.CORS_ORIGIN ?? '*',
  downloadPriceUgx: Number(process.env.DOWNLOAD_PRICE_UGX ?? 700),
};
