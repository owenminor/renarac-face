const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 3000;

// State file
const STATE_FILE = '/home/owenm/clawd/renarac-face/state.json';

// Initialize state if needed
if (!fs.existsSync(STATE_FILE)) {
    fs.writeFileSync(STATE_FILE, JSON.stringify({
        mood: 'focused',
        lastActivity: new Date().toISOString(),
        activities: [],
        stats: {
            skills: 6,
            emails: 3,
            ideas: 0
        }
    }, null, 2));
}

const mimeTypes = {
    '.html': 'text/html',
    '.js': 'application/javascript',
    '.css': 'text/css',
    '.json': 'application/json',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.svg': 'image/svg+xml'
};

const server = http.createServer((req, res) => {
    // API endpoints
    if (req.url === '/api/state' && req.method === 'GET') {
        const state = JSON.parse(fs.readFileSync(STATE_FILE));
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(state));
        return;
    }

    if (req.url === '/api/state' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const updates = JSON.parse(body);
            const state = JSON.parse(fs.readFileSync(STATE_FILE));
            Object.assign(state, updates);
            state.lastActivity = new Date().toISOString();
            fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(state));
        });
        return;
    }

    if (req.url === '/api/activity' && req.method === 'POST') {
        let body = '';
        req.on('data', chunk => body += chunk);
        req.on('end', () => {
            const { text, icon } = JSON.parse(body);
            const state = JSON.parse(fs.readFileSync(STATE_FILE));
            state.activities.unshift({ text, icon, time: new Date().toISOString() });
            state.activities = state.activities.slice(0, 10); // Keep last 10
            state.lastActivity = new Date().toISOString();
            state.stats = { ...state.stats, ideas: (state.stats.ideas || 0) + 1 };
            fs.writeFileSync(STATE_FILE, JSON.stringify(state, null, 2));
            res.writeHead(200, { 'Content-Type': 'application/json' });
            res.end(JSON.stringify(state));
        });
        return;
    }

    // Serve static files
    let filePath = req.url === '/' ? '/index.html' : req.url;
    filePath = path.join(__dirname, filePath);

    const ext = path.extname(filePath);
    const contentType = mimeTypes[ext] || 'text/plain';

    fs.readFile(filePath, (err, content) => {
        if (err) {
            res.writeHead(404);
            res.end('Not found');
        } else {
            res.writeHead(200, { 'Content-Type': contentType });
            res.end(content);
        }
    });
});

server.listen(PORT, () => {
    console.log(`Renarac Face Server running at http://localhost:${PORT}`);
});
