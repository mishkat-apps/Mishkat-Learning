const https = require('https');

const apiKey = 'AIzaSyDcdGLbKvWN1imZq0qTIDNsfoVZ7ZwmotM';
const projectId = 'mishkat-learning-555';
const uid = 'opRxlWwXj7aMNkiScEn9nOSKryp1';
const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?key=${apiKey}`;

const data = JSON.stringify({
    fields: {
        displayName: { stringValue: 'admin' },
        email: { stringValue: 'admin@mishkatlearning.com' },
        role: { stringValue: 'admin' },
        rank: { stringValue: 'Master' },
        enrolledCoursesCount: { integerValue: '0' },
        studyTimeMinutes: { integerValue: '0' },
        certificates: { arrayValue: { values: [] } },
        createdAt: { timestampValue: new Date().toISOString() }
    }
});

const options = {
    method: 'PATCH', // Update or Create
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

const req = https.request(url, options, (res) => {
    let body = '';
    res.on('data', (chunk) => body += chunk);
    res.on('end', () => {
        console.log(body);
    });
});

req.on('error', (e) => {
    console.error(e);
});

req.write(data);
req.end();
