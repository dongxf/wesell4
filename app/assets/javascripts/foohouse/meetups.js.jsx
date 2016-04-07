/** @jsx React.DOM */
var Meetup = React.createClass({
  render: function () {
    return (
      <div className="Meetup">
        <h2 className="MeetupName">
          {this.props.name}
        </h2>
        {this.props.comment}
      </div>
    );
  }
});

var ready = function () {
  React.render(
    <Meetup name="Richard" comment="This is a meetup "/>,
    document.getElementById('meetups')
  );
};

$(document).ready(ready);
