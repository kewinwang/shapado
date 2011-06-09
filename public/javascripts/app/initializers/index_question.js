$(document).ready(function() {

  var languages_filter = $(".languages_filter form")
  languages_filter.find(".buttons").hide();
  languages_filter.find("#language_filter").change(function(){
    submit = languages_filter.find(".buttons .change_language");
    submit.trigger("click");
  });

  var extraParams = Utils.url_vars();
  extraParams['format'] = 'js';

  $(".quick_question #ask_question").searcher({
    url : "/questions/related_questions.js",
    target : $(".questions-index"),
    fields : $(".quick_question #ask_question input#question_title"),
    behaviour : "live",
    timeout : 500,
    extraParams : extraParams,
    success: function(data) {
      $('#additional_info .pagination').html(data.pagination);
    }
  });

  $(".flag-link-index").live("click", function(event) {
    var link = $(this).parents("article.unanswered").find("h2 a");
    if(link) {
      window.location= link.attr("href")+"#to_flag"
    }
    return false;
  });


  $(".question form.vote-up-form input[name=vote_up]").live("click", function(event) {
    var btn_name = $(this).attr("name");
    var form = $(this).parents("form");
    $.post(form.attr("action"), form.serialize()+"&"+btn_name+"=1", function(data){
      if(data.success){
        if(data.vote_type == "vote_down") {
          form.html("<img src='/images/dialog-ok-apply.png'/>")
        } else {
          form.html("<img src='/images/dialog-ok-apply.png'/>")
        }
        Messages.show(data.message, "notice")
      } else {
        Messages.show(data.message, "error")
      }
    }, "json");
    return false;
  });
});