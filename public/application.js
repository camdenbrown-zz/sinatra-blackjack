$(document).ready(function(){
    player_hits();
    player_stays();
    dealer_hit();
  });

function playerHits() {
  $(document).on('click', "form#hit_form button", function() {
    alert("player hits!");
    $.ajax({
      type: "Post",
      url: "/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });

    return false;
  });
}

function playerStays() {
  $(document).on('click', "form#stay_form button", function() {
    alert("player stays!");
    $.ajax({
      type: "Post",
      url: "/stay"
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });

    return false;
  });
}

function dealerHits() {
  $(document).on('click', "form#dealer_hit button", function() {
    alert("Dealer hits!");
    $.ajax({
      type: "Post",
      url: "/game/dealer/hit"
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });

    return false;
  });
}
