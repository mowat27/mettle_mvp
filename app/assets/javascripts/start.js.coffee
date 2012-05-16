
root = global ? window

$ ->
  if !file_api_supported()
    alert "Sorry - the File API is not supported so this page doesn't work"
  else
    run_page()

file_api_supported = ->
  window.File && window.FileReader && window.FileList && window.Blob

comparison = new root.Diff.Comparison(["freebase_id"])

initialize = ->
  $("#results_table_test").hide()

switch_to_results = ->
  $("#results_table_test").show("medium")
  $("#upload_files").hide("medium");

switch_to_load_files = ->
  $("#upload_files").show("medium");
  $("#results_table_test").hide("medium")

run_page = ->
  load_expected_step = ->
    $(".step:eq(0)")

  load_actual_step = ->
    $(".step:eq(1)")

  compare_files_step = ->
    $(".step:eq(2)")


  start_step = (step) ->
    step().addClass("current")
    step().find("input").attr("disabled", false)

  mark_step_in_progress = (step) ->
    step().find(".loading-file").show()

  mark_step_completed = (step) ->
    step().removeClass("current").addClass("complete")
    step().find(".loading-file").hide()
    step().find(".file-load-ok").show()
    step().find("input").attr("disabled", true)

  mark_step_failed = (step) ->
    step().find(".loading-file").hide()
    step().find(".file-load-failed").text(error.message).show()
    step().removeClass("current").addClass("error")

  load_actual_step().find("input").attr("disabled", true)
  compare_files_step().addClass("disabled").find("input").attr("disabled", true)

  switch_to_load_files()
  start_step load_expected_step

  $("#expected_csv_input").change (evt) ->
    comparison.load_results "expected", evt.target.files,
      on_start: ->
        mark_step_in_progress load_expected_step
      on_success: ->
        mark_step_completed load_expected_step
        start_step load_actual_step
      on_error: (error) ->
        mark_step_failed load_expected_step


  $("#actual_csv_input").change (evt) ->
    comparison.load_results "actual", evt.target.files,
      on_start: ->
        mark_step_in_progress load_actual_step
      on_success: ->
        mark_step_completed load_actual_step
        start_step compare_files_step
      on_error: (error) ->
        mark_step_failed load_actual_step

  $("#compare-button").click (evt) ->
    comparison.compare()
    results = root.run_tests(JSON.parse(comparison.to_json()))
    test_table = new root.ResultsTable("test", results)
    $("#results_table_test").empty().append(test_table.to_jquery())
    compare_files_step().removeClass("current").addClass("complete")
    switch_to_results()

  $("#load_files_link").click switch_to_load_files
  $("#show_results_link").click switch_to_results

