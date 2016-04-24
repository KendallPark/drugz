import Ember from 'ember';
import $ from 'jquery';

export default Ember.Component.extend({
  drug: "",
  data: [],
  currentSectionIndex: 0,
  currentSectionTitle: "",
  currentSection: {},
  submitted: false,
  disabled: false,
  percentCorrect: Ember.computed("currentSectionIndex", "data", function() {
    return (this.get("currentSectionIndex") + 1)/this.get("data").length * 100;
  }),
  questionNumber: Ember.computed("currentSectionIndex", function() {
    return this.get("currentSectionIndex") + 1;
  }),
  init() {
    this._super(...arguments);
    $.getJSON("/api/quizzes", function(response) {
      var data = response;
      this.set("data", data);
      this.set("currentSectionIndex", 0);
      this.set("currentSection", this.data[this.currentSectionIndex]);
      this.set("currentSectionTitle", this.currentSection.title);
    }.bind(this));
  },
  actions: {
    submit: function() {
      this.toggleProperty("submitted");
      this.toggleProperty("disabled");
    },
    nextSection: function() {
      var currentIndex = this.get("currentSectionIndex");
      if (this.get("data").length !== this.get("currentSectionIndex")) {
        currentIndex += 1;
        this.set("submitted", false);
        this.set("disabled", false);
        this.set("currentSectionIndex", currentIndex);
        this.set("currentSection", this.get("data")[currentIndex]);
        this.set("currentSectionTitle", this.get("data")[currentIndex].title);
      }
    },
    prevSection: function() {
      var currentIndex = this.get("currentSectionIndex");
      if (this.get("currentSectionIndex") !== 0) {
        currentIndex -= 1;
        this.set("submitted", true);
        this.set("disabled", true);
        this.set("currentSectionIndex", currentIndex);
        this.set("currentSection", this.get("data")[currentIndex]);
        this.set("currentSectionTitle", this.get("data")[currentIndex].title);
      }
    }
  }
});
