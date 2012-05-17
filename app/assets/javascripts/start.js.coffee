root = global ? window

on_try_it_page = ->
  $("#upload_files").length != 0

browser_not_supported = ->
  browser = BrowserDetect.browser
  false

$ ->
  if on_try_it_page() && (browser_not_supported() || !file_api_supported())
    $("#header").append("<div id='errors'>Sorry, your browser is not supported. <a href=/browser>Find out more here<a>.</div>")
    $("#upload_files").find("input").attr("disabled", true)
  else
    run_page()

file_api_supported = ->
  window.File && window.FileReader && window.FileList && window.Blob

comparison = new root.Diff.Comparison(["banana"])

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

  choose_pk_step = ->
    $(".step:eq(2)")

  compare_files_step = ->
    $(".step:eq(3)")

  create_primary_key_checkboxes = (column_names) ->
    for column_name in column_names
      checkbox_html = "<input type='checkbox' id='cb#{column_name}' value='#{column_name}' class='pk_checkbox' /> <label for='cb#{column_name}'>#{column_name}</label>"
      choose_pk_step().append( $(checkbox_html) )
      $('.pk_checkbox').click ->
        choose_pk_step().removeClass("current").addClass("complete")
        start_step compare_files_step

  selected_primary_keys = ->
    result = []
    for checkbox in $('.pk_checkbox:checked')
      result.push checkbox.value

    result

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
        create_primary_key_checkboxes comparison.column_names()
        start_step choose_pk_step
      on_error: (error) ->
        mark_step_failed load_actual_step, error

  $("#compare-button").click (evt) ->
    comparison.key = selected_primary_keys()
    comparison.compare()
    results = root.run_tests(JSON.parse(comparison.to_json()))
    test_table = new root.ResultsTable("test", results)
    $("#results_table_test").empty().append(test_table.to_jquery())
    compare_files_step().removeClass("current").addClass("complete")
    switch_to_results()

  $("#nav").find("a").each ->
    $(this).addClass("current") if $(this).attr("href") == window.location.pathname

