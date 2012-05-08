equality_matchers =
  toEquals: (expected)->
    errors = []
    @message = ->
      result = "Objects should be equal using #equals: \n"
      result += "expected: #{to_string(expected)}\n"
      result += "  actual: #{to_string(@actual)}\n\n"
      result += "Errors: "
      result += "#{error}\n" for error in errors
      result
    errors.push("#equals not defined on actual") unless @actual.equals?
    errors.push("data doesn't match") unless @actual.equals(expected)
    errors.length == 0

  toIsEqual: (expected)->
      errors = []
      @message = ->
        result = "Objects should be equal using #equals: \n"
        result += "expected: #{to_string(expected)}\n"
        result += "  actual: #{to_string(@actual)}\n\n"
        result += "Errors: "
        result += "#{error}\n" for error in errors
        result
      errors.push("data doesn't match") unless _.isEqual(@actual, expected)
      errors.length == 0

    toNotEquals: (expected)->
      errors = []
      @message = ->
        result = "Objects should not be equal using #equals: \n"
        result += "expected: #{to_string(expected)}\n"
        result += "  actual: #{to_string(@actual)}\n\n"
        result += "Errors: "
        result += "#{error}\n" for error in errors
        result
      errors.push("#equals not defined on actual") unless @actual.equals?
      errors.push("objects are the same") if @actual.equals(expected)
      errors.length == 0

    toNotIsEqual: (expected)->
      errors = []
      @message = ->
        result = "Objects should not be equal using #equals: \n"
        result += "expected: #{to_string(expected)}\n"
        result += "  actual: #{to_string(@actual)}\n\n"
        result += "Errors: "
        result += "#{error}\n" for error in errors
        result
      errors.push("objects are the same") if _.isEqual(@actual, expected)
      errors.length == 0


diff_matchers =
  toBehaveLikeARow: ->
    @message = ->
      "#{@actual} is not a row"
    return false unless @actual? && @actual.values?
    true

  toHaveValues: (expected_values) ->
    @message = ->
      actual_values = @actual.values ? "undefined"
      "expected row with values [#{expected_values}] got [#{actual_values}]"
    expected = new root.Diff.Row(expected_values)
    @actual.equals(expected)

  toBeARowWithValues: (expected_values) ->
    expect(@actual).toBeDefined()
    expect(expected_values).toBeDefined()
    expect(@actual).toBehaveLikeARow()
    expect(@actual).toHaveValues(expected_values)
    true

  toHaveRowsWithValues: (values) ->
    expect(@actual.rows).toBeDefined()
    expect(@actual.rows.length).toEqual(values.length)
    expect(@actual.rows[i]).toBeARowWithValues(values[i]) for i, value of values
    true

beforeEach ->
  @empty_data_set = new root.Diff.DataSet []

  to_string = (obj) ->
    if obj? && obj.toString?
        obj.toString()
    else
        "#{obj}"

  @addMatchers(equality_matchers)
  @addMatchers(diff_matchers)

