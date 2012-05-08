root = global ? window

$ ->
  if !file_api_supported()
    alert "Sorry - the File API is not supported so this page doesn't work"
  else
    run_page()
    $("#compare-button").click()

file_api_supported = ->
  window.File && window.FileReader && window.FileList && window.Blob

comparison = new root.Diff.Comparison(["freebase_id"])

run_page = ->
  $("#expected_csv_input").change (evt) ->
    comparison.load_results("expected", evt.target.files)

  $("#actual_csv_input").change (evt) ->
    comparison.load_results("actual", evt.target.files)

  $("#compare-button").click ->
    comparison.compare()
    results = root.run_tests(JSON.parse(comparison.to_json()))
    test_table = new root.ResultsTable("test", results)
    $("#results_table_test").empty().append(test_table.to_jquery())