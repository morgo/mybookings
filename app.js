var express    = require('express');
var bodyParser = require('body-parser');

var app        = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(express.static('public'));

/* ======================================================== */

const booking = require('./lib/booking.js')

app.get('/bookings', (req, res, next) => {

  const mode     = (req.query.x && req.query.y) ? 'location' : 'date';
  const location = [req.query.y, req.query.x];

  return booking.findAll(mode, location, (err, events) => {

    if (err) {
      return next(err)
    }

    res.send(events)

  })
})

app.get('/bookings/:id', (req, res, next) => {

  const eventId = req.params.id

  if (!eventId) {
    return next(new Error('No eventId specified'))
  }

  booking.findOne(eventId, (err, booking) => {

    if (err) {
     return next(err)
    }

    res.send(booking)

  })
})

app.post('/bookings/:id', (req, res, next) => {

  const order = {
    tickets:      req.body.tickets,
    firstName:    req.body.first_name,
    lastName:     req.body.last_name,
    emailAddress: req.body.email_address
  }

  booking.orderTickets(order, (err, booking) => {

    if (err) {
      res.redirect('/bookings/' + req.params.id + '?error=order_not_completed')
    }

    res.send('Order complete')

  })
})


/* ======================================================== */

module.exports = app;

