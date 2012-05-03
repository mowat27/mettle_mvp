(function() {
  var DataSet, Diff, Index, Row, source_dir, _;

  console.log("RUNNING!!!");

  source_dir = "../../app/assets/javascripts";

  Diff = require("" + source_dir + "/diff.js");

  Row = Diff.Row;

  DataSet = Diff.DataSet;

  Index = Diff.Index;

  _ = require("" + source_dir + "/underscore.js")._;

  describe("Diff", function() {
    beforeEach(function() {
      var to_string;
      this.empty_data_set = new DataSet([]);
      to_string = function(obj) {
        if ((obj != null) && (obj.toString != null)) {
          return obj.toString();
        } else {
          return "" + obj;
        }
      };
      return this.addMatchers({
        toEquals: function(expected) {
          var errors;
          errors = [];
          this.message = function() {
            var error, result, _i, _len;
            result = "Objects should be equal using #equals: \n";
            result += "expected: " + (to_string(expected)) + "\n";
            result += "  actual: " + (to_string(this.actual)) + "\n\n";
            result += "Errors: ";
            for (_i = 0, _len = errors.length; _i < _len; _i++) {
              error = errors[_i];
              result += "" + error + "\n";
            }
            return result;
          };
          if (this.actual.equals == null) {
            errors.push("#equals not defined on actual");
          }
          if (!this.actual.equals(expected)) errors.push("data doesn't match");
          return errors.length === 0;
        },
        toIsEqual: function(expected) {
          var errors;
          errors = [];
          this.message = function() {
            var error, result, _i, _len;
            result = "Objects should be equal using #equals: \n";
            result += "expected: " + (to_string(expected)) + "\n";
            result += "  actual: " + (to_string(this.actual)) + "\n\n";
            result += "Errors: ";
            for (_i = 0, _len = errors.length; _i < _len; _i++) {
              error = errors[_i];
              result += "" + error + "\n";
            }
            return result;
          };
          if (!_.isEqual(this.actual, expected)) errors.push("data doesn't match");
          return errors.length === 0;
        },
        toNotEquals: function(expected) {
          var errors;
          errors = [];
          this.message = function() {
            var error, result, _i, _len;
            result = "Objects should not be equal using #equals: \n";
            result += "expected: " + (to_string(expected)) + "\n";
            result += "  actual: " + (to_string(this.actual)) + "\n\n";
            result += "Errors: ";
            for (_i = 0, _len = errors.length; _i < _len; _i++) {
              error = errors[_i];
              result += "" + error + "\n";
            }
            return result;
          };
          if (this.actual.equals == null) {
            errors.push("#equals not defined on actual");
          }
          if (this.actual.equals(expected)) errors.push("objects are the same");
          return errors.length === 0;
        },
        toNotIsEqual: function(expected) {
          var errors;
          errors = [];
          this.message = function() {
            var error, result, _i, _len;
            result = "Objects should not be equal using #equals: \n";
            result += "expected: " + (to_string(expected)) + "\n";
            result += "  actual: " + (to_string(this.actual)) + "\n\n";
            result += "Errors: ";
            for (_i = 0, _len = errors.length; _i < _len; _i++) {
              error = errors[_i];
              result += "" + error + "\n";
            }
            return result;
          };
          if (_.isEqual(this.actual, expected)) {
            errors.push("objects are the same");
          }
          return errors.length === 0;
        },
        toBehaveLikeARow: function() {
          this.message = function() {
            return "" + this.actual + " is not a row";
          };
          if (!((this.actual != null) && (this.actual.values != null))) {
            return false;
          }
          return true;
        },
        toHaveValues: function(expected_values) {
          var expected;
          this.message = function() {
            var actual_values, _ref;
            actual_values = (_ref = this.actual.values) != null ? _ref : "undefined";
            return "expected row with values [" + expected_values + "] got [" + actual_values + "]";
          };
          expected = new Row(expected_values);
          return this.actual.equals(expected);
        },
        toBeARowWithValues: function(expected_values) {
          expect(this.actual).toBeDefined();
          expect(expected_values).toBeDefined();
          expect(this.actual).toBehaveLikeARow();
          expect(this.actual).toHaveValues(expected_values);
          return true;
        },
        toHaveRowsWithValues: function(values) {
          var i, value;
          expect(this.actual.rows).toBeDefined();
          expect(this.actual.rows.length).toEqual(values.length);
          for (i in values) {
            value = values[i];
            expect(this.actual.rows[i]).toBeARowWithValues(values[i]);
          }
          return true;
        }
      });
    });
    describe("intersection", function() {
      beforeEach(function() {
        var data_set_ac, data_set_all;
        this.column_names = ["col1", "col2", "col3"];
        this.data = [["a", "b", "c"], ["a", "d", "c"], ["a", "b", "e"]];
        data_set_all = new DataSet(this.data);
        data_set_ac = new DataSet(this.data.slice(0, 2));
        this.index = new Index(["col1", "col3"], this.column_names, data_set_all);
        this.other = new Index(["col1", "col3"], this.column_names, data_set_all);
        this.other2 = new Index(["col1", "col3"], this.column_names, data_set_ac);
        this.keygroup_ac = new DataSet([this.data[0], this.data[1]]);
        return this.keygroup_ae = new DataSet([this.data[2]]);
      });
      describe("with 2 identical indexes", function() {
        it("finds a perfect intersection", function() {
          var matches;
          matches = [];
          Diff.intersection(this.index, this.other, {
            on_match: function(key, lhs, rhs) {
              return matches.push([key, lhs, rhs]);
            }
          });
          return expect(matches).toIsEqual([[new Row(["a", "e"]), this.keygroup_ae, this.keygroup_ae], [new Row(["a", "c"]), this.keygroup_ac, this.keygroup_ac]]);
        });
        return it("does nothing when on_match() is not provided", function() {
          var matches;
          matches = [];
          Diff.intersection(this.index, this.other);
          return expect(matches).toIsEqual([]);
        });
      });
      describe("when extra rows on the lhs", function() {
        it("calls on_unmatched_lhs() for unmatched lhs rows", function() {
          var rejects;
          rejects = [];
          Diff.intersection(this.index, this.other2, {
            on_unmatched_lhs: function(key, rows) {
              return rejects = [key, rows];
            }
          });
          return expect(rejects).toIsEqual([new Row(["a", "e"]), this.keygroup_ae]);
        });
        return it("does nothing when on_unmatched_lhs() is not defined", function() {
          var rejects;
          rejects = [];
          return Diff.intersection(this.index, this.other2, function() {
            return {
              on_match: function() {
                return null;
              }
            };
          });
        });
      });
      return describe("when extra rows on the rhs", function() {
        it("calls on_unmatched_rhs() for unmatched rhs rows", function() {
          var rejects;
          rejects = [];
          Diff.intersection(this.other2, this.index, {
            on_unmatched_rhs: function(key, rows) {
              return rejects = [key, rows];
            }
          });
          return expect(rejects).toIsEqual([new Row(["a", "e"]), this.keygroup_ae]);
        });
        return it("does nothing when on_unmatched_rhs() is not defined", function() {
          var rejects;
          rejects = [];
          return Diff.intersection(this.other2, this.index, function() {
            return {
              on_match: function() {
                return null;
              }
            };
          });
        });
      });
    });
    describe("Diff.cartesian", function() {
      beforeEach(function() {
        this.numbers = [[1], [2]];
        this.numbers_ds = new DataSet(this.numbers);
        this.letters = [["a"], ["b"]];
        return this.letters_ds = new DataSet(this.letters);
      });
      it("calculates and empty array for 2 empty data sets", function() {
        var result;
        result = Diff.cartesian(this.empty_data_set, this.empty_data_set);
        return expect(result).toIsEqual([]);
      });
      it("calculates a match for 2 single-row data sets", function() {
        var expected, result;
        result = Diff.cartesian(new DataSet([[1]]), new DataSet([["a"]]));
        expected = [[new Row([1]), new Row(["a"])]];
        return expect(result).toIsEqual(expected);
      });
      return it("calculates the product of 2 multi-row data sets", function() {
        var expected, result;
        result = Diff.cartesian(this.numbers_ds, this.letters_ds);
        expected = [[new Row([1]), new Row(["a"])], [new Row([1]), new Row(["b"])], [new Row([2]), new Row(["a"])], [new Row([2]), new Row(["b"])]];
        return expect(result).toIsEqual(expected);
      });
    });
    describe("Diff.Comparison", function() {
      beforeEach(function() {
        this.column_names = ["col1", "col2", "col3"];
        this.values = [["a", "b", "c"], ["a", "b", "e"]];
        this.data_set = new DataSet(this.values);
        this.row1 = {
          col1: {
            expected: "a",
            actual: "a"
          },
          col2: {
            expected: "b",
            actual: "b"
          },
          col3: {
            expected: "e",
            actual: "e"
          }
        };
        return this.row2 = {
          col1: {
            expected: "a",
            actual: "a"
          },
          col2: {
            expected: "b",
            actual: "b"
          },
          col3: {
            expected: "c",
            actual: "c"
          }
        };
      });
      describe("with identical data sets", function() {
        beforeEach(function() {
          this.comparison = new Comparison(["col1", "col3"]);
          this.comparison.expected.column_names = this.column_names;
          this.comparison.expected.data_set = this.data_set;
          this.comparison.actual.column_names = this.column_names;
          this.comparison.actual.data_set = this.data_set;
          return this.comparison.compare();
        });
        return it("merges 2 data sets into a single JSON document", function() {
          var expected;
          expected = {
            column_names: ["col1", "col2", "col3"],
            results: [this.row1, this.row2]
          };
          expected = JSON.stringify(expected);
          return expect(this.comparison.to_json()).toEqual(expected);
        });
      });
      describe("with differently ordered data sets", function() {
        beforeEach(function() {
          var other;
          other = new root.DataSet(this.values.reverse());
          this.comparison = new Comparison(this.column_names);
          this.comparison.expected.column_names = this.column_names;
          this.comparison.expected.data_set = this.data_set;
          this.comparison.actual.column_names = this.column_names;
          this.comparison.actual.data_set = other;
          return this.comparison.compare();
        });
        return it("merges 2 data sets into a single JSON document", function() {
          var expected;
          expected = {
            column_names: ["col1", "col2", "col3"],
            results: [this.row1, this.row2]
          };
          expected = JSON.stringify(expected);
          return expect(this.comparison.to_json()).toEqual(expected);
        });
      });
      return describe("with multiple values for a key", function() {
        beforeEach(function() {
          var other;
          this.values.push(["a", "b", "c"]);
          other = new root.DataSet(this.values);
          this.comparison = new Comparison(this.column_names);
          this.comparison.expected.column_names = this.column_names;
          this.comparison.expected.data_set = this.data_set;
          this.comparison.actual.column_names = this.column_names;
          this.comparison.actual.data_set = other;
          return this.comparison.compare();
        });
        return it("merges 2 data sets into a single JSON document", function() {
          var expected;
          expected = {
            column_names: ["col1", "col2", "col3"],
            results: [this.row1, this.row2, this.row2]
          };
          expected = JSON.stringify(expected);
          return expect(this.comparison.to_json()).toEqual(expected);
        });
      });
    });
    describe("Diff.DataSet", function() {
      beforeEach(function() {
        this.column_names = ["col1", "col2", "col3"];
        this.values = [["a", "b", "c"], ["a", "d", "c"], ["a", "b", "e"]];
        return this.data_set = new DataSet(this.values);
      });
      describe("creating from JSON", function() {
        return it("creates a dataset from JSON", function() {
          var expected, json;
          json = "{\n  \"column_names\" : [\"col1\",\"col2\",\"col3\"],\n  \"row_data\" : [\n    {\"col1\" : \"a\", \"col2\" : \"b\", \"col3\" : \"c\"},\n    {\"col1\" : \"a\", \"col2\" : \"d\", \"col3\" : \"c\"},\n    {\"col1\" : \"a\", \"col2\" : \"b\", \"col3\" : \"e\"}\n  ]\n}";
          expected = new DataSet(this.values);
          return expect(DataSet.create_from_json(json)).toEquals(expected);
        });
      });
      describe("#is_empty", function() {
        it("is not empty when it holds no rows", function() {
          this.data_set = this.empty_data_set;
          return expect(this.data_set.is_empty()).toBeTruthy();
        });
        return it("is not empty when it holds rows", function() {
          return expect(this.data_set.is_empty()).toBeFalsy();
        });
      });
      describe("#equals", function() {
        it("is equal when compared to an identical set", function() {
          expect(this.data_set).toEquals(new DataSet(this.values));
          return expect(this.data_set).toIsEqual(new DataSet(this.values));
        });
        it("is not equal when compared to an empty data set", function() {
          return expect(this.data_set).toNotEquals(this.empty_data_set);
        });
        it("is not equal when compared to a smaller data set", function() {
          return expect(this.data_set).toNotEquals(new DataSet(this.values.slice(0, 2)));
        });
        it("is not equal when compared to a larger data set", function() {
          return expect(this.data_set).toNotEquals(new DataSet(this.values.push(["x", "x", "x"])));
        });
        it("is not equal when the rows do not match", function() {
          var new_values, other;
          new_values = [["a", "b", "c"], ["a", "d", "c"], ["a", "XXXXX", "e"]];
          other = new DataSet(new_values);
          return expect(this.data_set).toNotEquals(other);
        });
        return it("is not equal when compared to an object that has no rows", function() {
          return expect(this.data_set).toNotEquals("foo");
        });
      });
      it("can be built from a 2 dimensional array of values", function() {
        return expect(this.data_set).toHaveRowsWithValues(this.values);
      });
      it("can be built from an array of Rows", function() {
        var array, rows;
        rows = (function() {
          var _i, _len, _ref, _results;
          _ref = this.values;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            array = _ref[_i];
            _results.push(new Row(array));
          }
          return _results;
        }).call(this);
        this.data_set = new DataSet(rows);
        return expect(this.data_set).toHaveRowsWithValues(this.values);
      });
      it("creates a slice through its rows", function() {
        var expected_values, result;
        result = this.data_set.slice(this.column_names, ["col1", "col3"]);
        expected_values = [["a", "c"], ["a", "c"], ["a", "e"]];
        return expect(result).toEquals(new DataSet(expected_values));
      });
      return it("filters rows by key value", function() {
        var all_values, i, result, these_values, _results;
        result = this.data_set.filter(this.column_names, ["col1", "col2"], new Row(["a", "b"]));
        this.actual = result;
        all_values = [["a", "b", "c"], ["a", "b", "e"]];
        expect(this.actual.rows).toBeDefined();
        expect(this.actual.rows.length).toEqual(all_values.length);
        _results = [];
        for (i in all_values) {
          these_values = all_values[i];
          _results.push(expect(this.actual.rows[i]).toHaveValues(these_values));
        }
        return _results;
      });
    });
    describe("Diff.Index", function() {
      beforeEach(function() {
        var data_set;
        this.column_names = ["col1", "col2", "col3"];
        this.data = [["a", "b", "c"], ["a", "d", "c"], ["a", "b", "e"]];
        data_set = new DataSet(this.data);
        this.index = new Index(["col1", "col3"], this.column_names, data_set);
        this.other = new Index(["col1", "col3"], this.column_names, data_set);
        return this.other2 = new Index(["col1", "col3"], this.column_names, new DataSet(this.data.slice(0, 2)));
      });
      it("returns the key values", function() {
        return expect(this.index.key_values()).toEquals(new DataSet([["a", "e"], ["a", "c"]]));
      });
      describe("#get", function() {
        it("returns a data set containing rows matching a key", function() {
          var first_entry, second_entry;
          first_entry = this.index.get(new Row(["a", "c"]));
          expect(first_entry).toEquals(new DataSet(this.data.slice(0, 2)));
          second_entry = this.index.get(new Row(["a", "e"]));
          return expect(second_entry).toEquals(new DataSet([this.data[2]]));
        });
        return it("returns an empty data set when no match found", function() {
          var result;
          result = this.index.get(new Row(["x", "x"]));
          return expect(result).toEquals(this.empty_data_set);
        });
      });
      describe("#merge", function() {
        return it("calculates the matches between 2 indexes", function() {
          var expected, lhs_index, result, rhs_index;
          expected = {
            key: ["col1", "col3"],
            values: new Row(["a", "c"]),
            rows: {
              lhs: new Row(["a", "b", "c"]),
              rhs: new Row(["a", "x", "c"])
            }
          };
          lhs_index = new Index(["col1", "col3"], this.column_names, new DataSet([["a", "b", "c"]]));
          rhs_index = new Index(["col1", "col3"], this.column_names, new DataSet([["a", "x", "c"]]));
          result = lhs_index.merge(rhs_index);
          expect(_.isEqual(expected, result)).toBeTruthy();
          return expect(result).toEqual(expected);
        });
      });
      return describe("#intersection", function() {
        return it("calculates a data set containing matching keys", function() {
          var index2, result;
          index2 = new Index(["col1", "col3"], this.column_names, new DataSet([["a", "b", "c"]]));
          result = this.index.intersection(index2);
          return expect(result).toEquals(new DataSet([["a", "c"]]));
        });
      });
    });
    return describe("Diff.Row", function() {
      beforeEach(function() {
        this.column_names = ["a", "b", "c", "d", "e"];
        return this.row = new Row(["v0", "v1", "v2", "v3", "v4"]);
      });
      describe("#equals", function() {
        it("is true when both rows contain the same values", function() {
          var other;
          other = new Row(["v0", "v1", "v2", "v3", "v4"]);
          return expect(this.row).toEquals(other);
        });
        it("is false when the rows contain different values", function() {
          var other;
          other = new Row(["v4", "v3", "v2", "v1", "v0"]);
          return expect(this.row).toNotEquals(other);
        });
        it("is false when other is shorter than this row", function() {
          var other;
          other = new Row(["v0", "v1", "v2"]);
          return expect(this.row).toNotEquals(other);
        });
        it("is false when other is longer than this row", function() {
          var other;
          other = new Row(["v0", "v1", "v2", "v3", "v4", "v5"]);
          return expect(this.row).toNotEquals(other);
        });
        return it("is false when the comparison object is not a Row", function() {
          var other;
          other = ["v0", "v1", "v2", "v3", "v4"];
          return expect(this.row).toNotEquals(other);
        });
      });
      describe("#get", function() {
        it("finds the value for a given column", function() {
          return expect(this.row.get(this.column_names, "b")).toEqual("v1");
        });
        return it("returns 'notfound' when the column does not exist", function() {
          return expect(this.row.get(this.column_names, "x")).toEqual("notfound");
        });
      });
      return describe("#slice", function() {
        return it("slices a row by column name", function() {
          var result;
          result = this.row.slice(this.column_names, ["a", "c"]);
          return expect(result).toEquals(new Row(["v0", "v2"]));
        });
      });
    });
  });

}).call(this);
