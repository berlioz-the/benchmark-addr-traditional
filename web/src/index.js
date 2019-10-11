const express = require('express');
const request = require('request-promise');
const bodyParser = require('body-parser')

const app = express();

app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.use(express.static('public'));
app.set('view engine', 'ejs');

const APP_PEER = {
    host: 'localhost',
    port: 4000
}
APP_PEER.url = `http://${APP_PEER.host}:${APP_PEER.port}`;

app.get('/', function (req, response) {
    var renderData = {
        entries: []
    };

    var options = { url: `${APP_PEER.url}/entries`, json: true, resolveWithFullResponse: true };
    return request(options)
        .then(result => {
            if (result) {
                renderData.entries = result.body;
            }
        })
        .catch(error => {
            console.log("**** ERROR")
            console.log(error)
            if (error instanceof Error) {
                renderData.error = error.stack + error.stack;
            } else {
                renderData.error = JSON.stringify(error, null, 2);
            }
        })
        .then(() => {
            response.render('pages/index', renderData);
        })
        ;
});

app.post('/new-contact', (req, response) => {
    var options = { url: `${APP_PEER.url}/entry`, method: 'POST', body: req.body, json: true };
    return request(options)
        .then(result => {
            if (!result) {
                return response.send({ error: 'No app peers present.' });
            }
            return response.send(result);
        })
        .catch(error => {
            return response.send({ error: error });
        });
});

app.listen(3000, '0.0.0.0', (err) => {
    if (err) {
        return console.log('something bad happened', err)
    }
    console.log(`server is listening on 0.0.0.0:3000`)
})
