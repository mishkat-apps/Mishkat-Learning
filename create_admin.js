const https = require('https');
const fs = require('fs');

const apiKey = 'AIzaSyDcdGLbKvWN1imZq0qTIDNsfoVZ7ZwmotM';
const url = `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${apiKey}`;

const data = JSON.stringify({
    email: 'admin@mishkatlearning.com',
    password: 'admin@1357',
    returnSecureToken: true
});

const options = {
    method: 'POST',
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
