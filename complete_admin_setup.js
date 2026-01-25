const https = require('https');

const apiKey = 'AIzaSyDcdGLbKvWN1imZq0qTIDNsfoVZ7ZwmotM';
const projectId = 'mishkat-learning-555';
const email = 'admin@mishkatlearning.com';
const password = 'admin@1357';

function post(url, data, headers = {}) {
    return new Promise((resolve, reject) => {
        const options = {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...headers
            }
        };
        const req = https.request(url, options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => resolve({ body: JSON.parse(body), statusCode: res.statusCode }));
        });
        req.on('error', reject);
        req.write(JSON.stringify(data));
        req.end();
    });
}

function patch(url, data, headers = {}) {
    return new Promise((resolve, reject) => {
        const options = {
            method: 'PATCH',
            headers: {
                'Content-Type': 'application/json',
                ...headers
            }
        };
        const req = https.request(url, options, (res) => {
            let body = '';
            res.on('data', (chunk) => body += chunk);
            res.on('end', () => resolve({ body: JSON.parse(body), statusCode: res.statusCode }));
        });
        req.on('error', reject);
        req.write(JSON.stringify(data));
        req.end();
    });
}

async function run() {
    try {
        console.log('Signing in...');
        const signInUrl = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${apiKey}`;
        const signInRes = await post(signInUrl, { email, password, returnSecureToken: true });

        if (signInRes.statusCode !== 200) {
            console.error('Sign in failed:', signInRes.body);
            return;
        }

        const idToken = signInRes.body.idToken;
        const uid = signInRes.body.localId;
        console.log('Signed in. UID:', uid);

        console.log('Creating Firestore document...');
        const firestoreUrl = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?key=${apiKey}`;
        const firestoreData = {
            fields: {
                displayName: { stringValue: 'admin' },
                email: { stringValue: email },
                role: { stringValue: 'admin' },
                rank: { stringValue: 'Master Seeker' },
                enrolledCoursesCount: { integerValue: '0' },
                studyTimeMinutes: { integerValue: '0' },
                certificates: { arrayValue: { values: [] } },
                createdAt: { timestampValue: new Date().toISOString() }
            }
        };

        const firestoreRes = await patch(firestoreUrl, firestoreData, {
            'Authorization': `Bearer ${idToken}`
        });

        if (firestoreRes.statusCode === 200) {
            console.log('Firestore document created successfully!');
        } else {
            console.error('Firestore creation failed:', firestoreRes.body);
        }
    } catch (e) {
        console.error('Error:', e);
    }
}

run();
