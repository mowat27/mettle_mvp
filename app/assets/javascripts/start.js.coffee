
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

  disable_step = (step) ->
    step().addClass("disabled").find("input").attr("disabled", true)


  mark_step_in_progress = (step) ->
    step().find(".loading-file").show()

  mark_step_completed = (step) ->
    step().removeClass("current").addClass("complete")
    step().find(".loading-file").hide()
    step().find(".file-load-ok").show()
    step().find("input").attr("disabled", true)

  mark_step_failed = (step, error) ->
    error_html = """
<span>
  ERROR: Could not read file - was it properly formed? <a href=#>show details</a>
  <p class='error-details' style="display: inline;">#{error.name}: #{error.message}</p>
</span>
"""
    error = $(error_html)
    error.find(".error-details").hide()
    error.find("a").click (evt) ->
      error.find(".error-details").toggle()

    step().find(".loading-file").hide()
    step().find(".file-load-failed").replaceWith(error).show()
    step().removeClass("current").addClass("error")

  switch_to_load_files()
  disable_step compare_files_step
  disable_step load_actual_step
  start_step load_expected_step

  $("#expected_csv_input").change (evt) ->
    comparison.load_results "expected", evt.target.files,
      on_start: ->
        mark_step_in_progress load_expected_step
      on_success: ->
        mark_step_completed load_expected_step
        start_step load_actual_step
      on_error: (error) ->
        mark_step_failed load_expected_step, error

  $("#actual_csv_input").change (evt) ->
    comparison.load_results "actual", evt.target.files,
      on_start: ->
        mark_step_in_progress load_actual_step
      on_success: ->
        mark_step_completed load_actual_step
        start_step compare_files_step
      on_error: (error) ->
        mark_step_failed load_actual_step, error

  $("#compare-button").click (evt) ->
    comparison.compare()
    results = root.run_tests(JSON.parse(comparison.to_json()))
    test_table = new root.ResultsTable("test", results)
    $("#results_table_test").empty().append(test_table.to_jquery())
    compare_files_step().removeClass("current").addClass("complete")
    switch_to_results()

