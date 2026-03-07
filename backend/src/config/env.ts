import dotenv from 'dotenv';

dotenv.config({ path: '../.env' });

export const config = {
    port: Number(process.env.BACKEND_PORT) || 3001,
    host: process.env.BACKEND_HOST || '0.0.0.0',
    nodeEnv: process.env.NODE_ENV || 'development',
} as const;
