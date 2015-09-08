$(document).ready(function(){
    player_hits();
    player_stays();
    dealer_hit();
  });

function player_hits() {
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

function player_stays() {
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

function dealer_hit() {
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
