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

beforeEach ->
  to_string = (obj) ->
    if obj? && obj.toString?
        obj.toString()
    else
        "#{obj}"

  @addMatchers(equality_matchers)

