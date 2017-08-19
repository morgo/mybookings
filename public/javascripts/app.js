function submitOrder() {

  $.post( "/bookings/" + getParameterByName('id'), {
    first_name:    $("#first_name").val(),
    last_name:     $("#last_name").val(),
    email_address: $("#email_address").val(),
    tickets:       $("#tickets_hidden").val()
  })
    .done(function( data ) {
      alert(data);
      window.location='/';
    });

}

function getParameterByName(name) {
  url = window.location.href;
  name = name.replace(/[\[\]]/g, "\\$&");
  var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
      results = regex.exec(url);
  if (!results) return null;
  if (!results[2]) return '';
  return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function renderEvents() {

  var html = '<div class="card-columns">';

  for(var i=0; i < events.length; i++) {

    html += `<div class="card">
      <a href="book.html?id=${events[i].id}"><img class="card-img-top img-fluid" src="${events[i].thumbnail}" alt="Card image cap"></a>
      <div class="card-block">
        <h4 class="card-title"><a href="book.html?id=${events[i].id}">${events[i].name}</a></h4>`

    if (events[i].distance) {
      html += `<p class="distance"><i class="fa fa-map-marker" aria-hidden="true"></i>  
      ${Math.floor(Number(events[i].distance) * 0.000621371)} miles away</p>`
    }

    html += `<p class="card-text">${events[i].description}</p>

      <footer>
        <small>
          ${events[i].event_date} @ <cite title="Source Title">${events[i].venue_name}</cite>
        </small>
      </footer>

      </div>
    </div>`;

  }

  html += '</div>' // end card-columns

  $("#main").html(html);

}

function renderEvent() {

  console.log(event)

  $(".event-date").text(event.event.event_date);
  $(".venue-name").text(event.event.venue_name);
  $(".event-name").text(event.event.name);
  $(".event-description").html(event.event.description_extended);
  $(".page-header").css('background-image', `url(${event.event.thumbnail})`)

  renderTable();

}

function renderTable() {

  var html = `
    <table class="table" id="seat-selection">
    <tr>
     <td colspan="20" class="header">Front of Venue</td>
    </tr>`;

  /*
   In our naive implimentation, all venues are exactly 20 seats wide
   and 10 rows deep.  The database schema does not impose such a limitation,
   but this makes it easier to visually represent seats.
  */

  for(r=1;r<=10;r++) {
    html += "<tr>"
    for (s=1;s<=20;s++) {

      /*
       Check for an exact match on ticket at this 
       row + seat location. If there is no match,
       it either means that the ticket was sold,
       or not made available for sale.
      */

      var results = event.tickets.filter(function (e) { return e.vrow == r && e.vseat == s; });

      if (results.length == 1) {
        html += `<td class="available"><span>${results[0].ticket_id}</span></td>`
      } else {
        html += `<td class="taken"><span></span></td>`
      }
    }
    html += "</tr>"
  }

  html += `<tr>
     <td colspan="20" class="header">Back of Venue</td>
    </tr>
    </table>`;

  $("#seat-selection").html(html)

}

/*
 Clicking on a seat toggles it between selected
 and available again.  This does not apply to the
 header TD or taken seats.
*/

$("#seat-selection").on("click", "td", function() {

  if (!($(this).hasClass("taken") || $(this).hasClass("header"))) {
    $(this).toggleClass("selected");
    updateSeatSelection();
  }

});

/*
 Update the hidden field which keeps track of 
 which seats we would like to book.
*/

function updateSeatSelection() {

  var tickets = [];

  $("#seat-selection td.selected").each(function() {
    tickets[tickets.length] = $(this).text();
  });

  $("h4 span").html("Ordering " + tickets.length + " tickets(s)");
  $("#tickets_hidden").val(tickets.join());

}

function refreshEvents() {

  mode = Cookies.get('mode');
  x    = Cookies.get('x');
  y    = Cookies.get('y');

  if (mode=='loc' && Number(x) && Number(y)) {

    $.getJSON( `/bookings?x=${x}&y=${y}`, function( data ) {

      events = data;
      $("#mode-location").addClass('btn-primary');
      $("#mode-location").removeClass('btn-secondary');
      $("#mode-date").removeClass('btn-primary');
      $("#mode-date").addClass('btn-secondary');

      renderEvents();

    });

  } else {

    $.getJSON( "/bookings", function( data ) {

      events = data;
      $("#mode-location").removeClass('btn-primary');
      $("#mode-location").addClass('btn-secondary');
      $("#mode-date").addClass('btn-primary');
      $("#mode-date").removeClass('btn-secondary');

      renderEvents();

    });


  }

}

/*
 Change the display mode between calendar-sort
 and location-sort.
*/

$("#mode").on("click", "button", function() {

  if ($(this).text().trim() == 'Date') {

    Cookies.set('mode', 'date', { expires: 7 });
    Cookies.set('loc', {}, { expires: 7 });
    refreshEvents();

  } else if(navigator.geolocation) {

    /* Attempt to use navigator.geolocation */
    navigator.geolocation.getCurrentPosition(function(p) {

      Cookies.set('mode', 'loc', { expires: 7 });
      Cookies.set('x', p.coords.latitude, { expires: 7 });
      Cookies.set('y', p.coords.longitude, { expires: 7 });
      refreshEvents();

    });

  } else {
    alert("Your browser does not support geolocation");  
  }

});

