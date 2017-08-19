var mysql      = require('mysql')

var connection = mysql.createConnection({
   host     : '127.0.0.1',
   port     : 5719,
   user     : 'msandbox',
   password : 'msandbox',
   database : 'mybookings'
})

connection.connect()

exports.findOne = function (eventId, callback) {

  let q = `SELECT events.id, venue_id, events.name, description,
    description_extended, thumbnail, event_date, 
    venues.name as venue_name
    FROM events
    INNER JOIN venues ON events.venue_id=venues.id
    WHERE events.id = ${connection.escape(eventId)}`

  connection.query(q, (err, event) => {

    if (err) {
      return callback(err)
    }

    /*
     Get the full inventory of available tickets.
     Any ticket not returned is assumed sold.
    */

    let q = `SELECT tickets.id AS ticket_id, vrow, vseat
      FROM tickets
      INNER JOIN seats ON seats.id=tickets.seat_id
      WHERE order_id is NULL 
      AND event_id = ${connection.escape(eventId)}
      ORDER BY seats.vrow, seats.vseat`;

    return connection.query(q, (err, tickets) => {

      return callback(null, {
        event: event[0],
        tickets: tickets
      })

    })

  })

}


exports.findAll = function (mode, location, callback) {

  if (mode == 'location') {

    var q = `SELECT events.id, venue_id, events.name, description,
      thumbnail, event_date, venues.name as venue_name,
      st_distance_sphere(venues.location,
      POINT(
        ${connection.escape(location[0])},
        ${connection.escape(location[1])}
      )) AS distance
      FROM events
      INNER JOIN venues ON events.venue_id=venues.id
      ORDER BY distance`

  } else {

    var q = `SELECT events.id, venue_id, events.name, description, 
      thumbnail, event_date, venues.name as venue_name
      FROM events
      INNER JOIN venues ON events.venue_id=venues.id
      ORDER BY event_date`

  }

  return connection.query(q, (err, data) => {

    if (err) {
      return callback(err)
    }

    return callback(null, data)

  })
}

exports.orderTickets = function (order, callback) {

  order.tickets = String(order.tickets).replace('[^0-9,]', '') // sanitize

  connection.beginTransaction((err) => {

    if (err) {
      return callback(err)
    }

    let q = `SELECT * FROM tickets
      WHERE id IN (${order.tickets})
      AND order_id IS NULL FOR UPDATE`

    connection.query(q, (err,results) => {

       if (err) {
        return callback(err)
       }

      /*
       Create the Initial Order
      */

      let q = `INSERT INTO orders 
        (first_name, last_name, email_address)
        VALUES (
          ${connection.escape(order.firstName)},
          ${connection.escape(order.lastName)},
          ${connection.escape(order.emailAddress)}
        )`

      connection.query(q, (err,results) => {

        if (err) {
          return callback(err)
        }

        const orderId = results.insertId

        let q = `UPDATE tickets
          SET order_id = ${orderId} 
          WHERE id IN (${order.tickets})`

        connection.query(q, (err,results) => {

          if (err) {
            return callback(err)
          }

          connection.commit((err) => {

            if (err) {
              return callback(err)
            }

            return callback(null, orderId) // return insertId to caller

          }) // commit
        }) // update tickets
      }) // insert order
    }) // select FOR UPDATE
  }) // beginTransaction
}