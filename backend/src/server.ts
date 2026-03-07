import { buildApp } from './app.js';
import { config } from './config/index.js';

async function main() {
    const app = await buildApp();

    try {
        await app.listen({ port: config.port, host: config.host });
        console.info(`🚀 Backend server running at http://localhost:${config.port}`);
    } catch (error) {
        app.log.error(error);
        process.exit(1);
    }
}

main();
