#!/usr/bin/env rhino
/*
jstest

http://code.google.com/p/js-ria-tools/

The following license applies to only the Rhino harness code.  The assertion 
functions were taken from the JsUnit project, which is licensed under the MPL  
terms that are located below this license notice.

Written by Steven Kollars

Copyright (c) 2008 Rackspace (www.rackspace.com)

Permission is hereby granted, free of charge, to any person obtaining a copy 
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights 
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
copies of the Software, and to permit persons to whom the Software is 
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


jstest uses assertion functions taken from the JsUnit project 
http://www.jsunit.net

The JsUnit project is licensed as follows:

***** BEGIN LICENSE BLOCK *****
- Version: MPL 1.1/GPL 2.0/LGPL 2.1
-
- The contents of this file are subject to the Mozilla Public License Version
- 1.1 (the "License"); you may not use this file except in compliance with
- the License. You may obtain a copy of the License at
- http://www.mozilla.org/MPL/
-
- Software distributed under the License is distributed on an "AS IS" basis,
- WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
- for the specific language governing rights and limitations under the
- License.
-
- The Original Code is Edward Hieatt code.
-
- The Initial Developer of the Original Code is
- Edward Hieatt, edward@jsunit.net.
- Portions created by the Initial Developer are Copyright (C) 2003
- the Initial Developer. All Rights Reserved.
-
- Author Edward Hieatt, edward@jsunit.net
-
- Alternatively, the contents of this file may be used under the terms of
- either the GNU General Public License Version 2 or later (the "GPL"), or
- the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
- in which case the provisions of the GPL or the LGPL are applicable instead
- of those above. If you wish to allow use of your version of this file only
- under the terms of either the GPL or the LGPL, and not to allow others to
- use your version of this file under the terms of the MPL, indicate your
- decision by deleting the provisions above and replace them with the notice
- and other provisions required by the LGPL or the GPL. If you do not delete
- the provisions above, a recipient may use your version of this file under
- the terms of any one of the MPL, the GPL or the LGPL.
-
- ***** END LICENSE BLOCK *****
*/

// Start of jsUnit Core
var JSUNIT_UNDEFINED_VALUE;
var JSUNIT_VERSION = 2.2;

/**
 + * A more functional typeof
 + * @param Object o
 + * @return String
 + */
function _trueTypeOf(something) {
    var result = typeof something;
    try {
        switch (result) {
            case 'string':
            case 'boolean':
            case 'number':
                break;
            case 'object':
            case 'function':
                switch (something.constructor)
                        {
                    case String:
                        result = 'String';
                        break;
                    case Boolean:
                        result = 'Boolean';
                        break;
                    case Number:
                        result = 'Number';
                        break;
                    case Array:
                        result = 'Array';
                        break;
                    case RegExp:
                        result = 'RegExp';
                        break;
                    case Function:
                        result = 'Function';
                        break;
                    default:
                        var m = something.constructor.toString().match(/function\s*([^( ]+)\(/);
                        if (m)
                            result = m[1];
                        else
                            break;
                }
                break;
        }
    }
    finally {
        result = result.substr(0, 1).toUpperCase() + result.substr(1);
        return result;
    }
}

function _displayStringForValue(aVar) {
    var result = '<' + aVar + '>';
    if (!(aVar === null || aVar === JSUNIT_UNDEFINED_VALUE)) {
        result += ' (' + _trueTypeOf(aVar) + ')';
    }
    return result;
}

function fail(failureMessage) {
    throw new JsUnitException("Call to fail()", failureMessage);
}

function error(errorMessage) {
    var errorObject = new Object();
    errorObject.description = errorMessage;
    errorObject.stackTrace = getStackTrace();
    throw errorObject;
}

function argumentsIncludeComments(expectedNumberOfNonCommentArgs, args) {
    return args.length == expectedNumberOfNonCommentArgs + 1;
}

function commentArg(expectedNumberOfNonCommentArgs, args) {
    if (argumentsIncludeComments(expectedNumberOfNonCommentArgs, args))
        return args[0];

    return null;
}

function nonCommentArg(desiredNonCommentArgIndex, expectedNumberOfNonCommentArgs, args) {
    return argumentsIncludeComments(expectedNumberOfNonCommentArgs, args) ?
           args[desiredNonCommentArgIndex] :
           args[desiredNonCommentArgIndex - 1];
}

function _validateArguments(expectedNumberOfNonCommentArgs, args) {
    if (!( args.length == expectedNumberOfNonCommentArgs ||
           (args.length == expectedNumberOfNonCommentArgs + 1 && typeof(args[0]) == 'string') ))
        error('Incorrect arguments passed to assert function');
}

function _assert(comment, booleanValue, failureMessage) {
    if (!booleanValue)
        throw new JsUnitException(comment, failureMessage);
}

function assert() {
    _validateArguments(1, arguments);
    var booleanValue = nonCommentArg(1, 1, arguments);

    if (typeof(booleanValue) != 'boolean')
        error('Bad argument to assert(boolean)');

    _assert(commentArg(1, arguments), booleanValue === true, 'Call to assert(boolean) with false');
}

function assertTrue() {
    _validateArguments(1, arguments);
    var booleanValue = nonCommentArg(1, 1, arguments);

    if (typeof(booleanValue) != 'boolean')
        error('Bad argument to assertTrue(boolean)');

    _assert(commentArg(1, arguments), booleanValue === true, 'Call to assertTrue(boolean) with false');
}

function assertFalse() {
    _validateArguments(1, arguments);
    var booleanValue = nonCommentArg(1, 1, arguments);

    if (typeof(booleanValue) != 'boolean')
        error('Bad argument to assertFalse(boolean)');

    _assert(commentArg(1, arguments), booleanValue === false, 'Call to assertFalse(boolean) with true');
}

function assertEquals() {
    _validateArguments(2, arguments);
    var var1 = nonCommentArg(1, 2, arguments);
    var var2 = nonCommentArg(2, 2, arguments);
    _assert(commentArg(2, arguments), var1 === var2, 'Expected ' + _displayStringForValue(var1) + ' but was ' + _displayStringForValue(var2));
}

function assertNotEquals() {
    _validateArguments(2, arguments);
    var var1 = nonCommentArg(1, 2, arguments);
    var var2 = nonCommentArg(2, 2, arguments);
    _assert(commentArg(2, arguments), var1 !== var2, 'Expected not to be ' + _displayStringForValue(var2));
}

function assertNull() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), aVar === null, 'Expected ' + _displayStringForValue(null) + ' but was ' + _displayStringForValue(aVar));
}

function assertNotNull() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), aVar !== null, 'Expected not to be ' + _displayStringForValue(null));
}

function assertUndefined() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), aVar === JSUNIT_UNDEFINED_VALUE, 'Expected ' + _displayStringForValue(JSUNIT_UNDEFINED_VALUE) + ' but was ' + _displayStringForValue(aVar));
}

function assertNotUndefined() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), aVar !== JSUNIT_UNDEFINED_VALUE, 'Expected not to be ' + _displayStringForValue(JSUNIT_UNDEFINED_VALUE));
}

function assertNaN() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), isNaN(aVar), 'Expected NaN');
}

function assertNotNaN() {
    _validateArguments(1, arguments);
    var aVar = nonCommentArg(1, 1, arguments);
    _assert(commentArg(1, arguments), !isNaN(aVar), 'Expected not NaN');
}

function assertObjectEquals() {
    _validateArguments(2, arguments);
    var var1 = nonCommentArg(1, 2, arguments);
    var var2 = nonCommentArg(2, 2, arguments);
    var type;
    var msg = commentArg(2, arguments)?commentArg(2, arguments):'';
    var isSame = (var1 === var2);
    //shortpath for references to same object
    var isEqual = ( (type = _trueTypeOf(var1)) == _trueTypeOf(var2) );
    if (isEqual && !isSame) {
        switch (type) {
            case 'String':
            case 'Number':
                isEqual = (var1 == var2);
                break;
            case 'Boolean':
            case 'Date':
                isEqual = (var1 === var2);
                break;
            case 'RegExp':
            case 'Function':
                isEqual = (var1.toString() === var2.toString());
                break;
            default: //Object | Array
                var i;
                if (isEqual = (var1.length === var2.length))
                    for (i in var1)
                        assertObjectEquals(msg + ' found nested ' + type + '@' + i + '\n', var1[i], var2[i]);
        }
        _assert(msg, isEqual, 'Expected ' + _displayStringForValue(var1) + ' but was ' + _displayStringForValue(var2));
    }
}

assertArrayEquals = assertObjectEquals;

function assertEvaluatesToTrue() {
    _validateArguments(1, arguments);
    var value = nonCommentArg(1, 1, arguments);
    if (!value)
        fail(commentArg(1, arguments));
}

function assertEvaluatesToFalse() {
    _validateArguments(1, arguments);
    var value = nonCommentArg(1, 1, arguments);
    if (value)
        fail(commentArg(1, arguments));
}

function assertHashEquals() {
    _validateArguments(2, arguments);
    var var1 = nonCommentArg(1, 2, arguments);
    var var2 = nonCommentArg(2, 2, arguments);
    for (var key in var1) {
        assertNotUndefined("Expected hash had key " + key + " that was not found", var2[key]);
        assertEquals(
                "Value for key " + key + " mismatch - expected = " + var1[key] + ", actual = " + var2[key],
                var1[key], var2[key]
                );
    }
    for (var key in var2) {
        assertNotUndefined("Actual hash had key " + key + " that was not expected", var1[key]);
    }
}

function assertRoughlyEquals() {
    _validateArguments(3, arguments);
    var expected = nonCommentArg(1, 3, arguments);
    var actual = nonCommentArg(2, 3, arguments);
    var tolerance = nonCommentArg(3, 3, arguments);
    assertTrue(
            "Expected " + expected + ", but got " + actual + " which was more than " + tolerance + " away",
            Math.abs(expected - actual) < tolerance
            );
}

function assertContains() {
    _validateArguments(2, arguments);
    var contained = nonCommentArg(1, 2, arguments);
    var container = nonCommentArg(2, 2, arguments);
    assertTrue(
            "Expected '" + container + "' to contain '" + contained + "'",
            container.indexOf(contained) != -1
            );
}

function JsUnitException(comment, message) {
    this.isJsUnitException = true;
    this.comment = comment;
    this.jsUnitMessage = message;
}

// End of jsUnit Core

// Start of jstest Rhino harness

// This is where all the test cases go
var TestCase = {};

(function (args) {
    if (!args[0]) {
        print([
            "Usage:",
            " jstest <config>",
            "",
            "",
            "Config Files:",
            "",
            "A config file is a simple text file that should specify one JavaScript file per",
            "line.",
            "",
            "Empty lines are ignored.",
            "",
            "Lines beginning with '//' are treated as comments and ignored.",
            "",
            "",
            "Writing Tests:",
            "",
            "A test case is any object that is placed in the global TestCase variable.",
            "",
            "For example:",
            "TestCase.MyTest = {",
            "    ...",
            "};",
            "",
            "Inside your test case, any method that starts with 'test' will be run as a test.",
            "",
            "In your tests, the following assertion functions will be available:",
            " assert([comment], booleanValue) ",
            " assertTrue([comment], booleanValue) ",
            " assertFalse([comment], booleanValue) ",
            " assertEquals([comment], value1, value2) ",
            " assertNotEquals([comment], value1, value2) ",
            " assertNull([comment], value) ",
            " assertNotNull([comment], value) ",
            " assertUndefined([comment], value) ",
            " assertNotUndefined([comment], value) ",
            " assertNaN([comment], value) ",
            " assertNotNaN([comment], value) ",
            " fail(comment) ",
            "",
            "You can also provide a setUp and tearDown method in your test cases. The setUp ",
            "method will be called before each test is run and the tearDown method will be ",
            "called after each test is run.",
            "",
            "For example:",
            "TestCase.MyTest = {",
            "    setUp: function () {",
            "        this.user = new User();",
            "    },",
            "",
            "    ...",
            "",
            "    tearDown: function () {",
            "        this.user = null;",
            "    }",
            "};",
        ].join("\n"));
        quit(1);
    }
    
    // ignore lines that start with '//'
    // ignore blank lines
    // all other lines should be JS files
    
    print("jstest starting...");
    var config = readFile(args[0]);
    if (!config) {
        print("Couldn't open config file", args[0]);
        quit(1);
    }
    
    // Load all of the files from the config file
    config = config.replace(/\\r\\n/g, "\n");
    var configLines = config.split("\n");
    var i, line;
    for (i = 0; i < configLines.length; i += 1) {
        line = configLines[i].replace(/^\s*(\S*(\s+\S+)*)\s*$/, "$1");
        if (line !== '' && line.indexOf('//') !== 0) {
            load(line);
        }
    }
    
    var obj, tcase, su, td, meth, tests = 0, successes = 0, failures = 0, errors = 0;
    for (obj in TestCase) {
        tcase = TestCase[obj];
        if (typeof(tcase) === 'object') {
            // Run all of the test methods for it.
            su = tcase.setUp || function () {};
            td = tcase.tearDown || function () {};
            for (meth in tcase) {
                if (meth.indexOf('test') === 0 && 
                        typeof(tcase[meth]) === 'function' && 
                        tcase.hasOwnProperty(meth)) {
                    tests += 1;
                    su.call(tcase);
                    try {
                        tcase[meth].call(tcase);
                        successes += 1;
                    } catch (e) {
                        print('\n--------------------------------------------------------------------------------\n');
                        if (e.isJsUnitException) {
                            print('FAILURE:', obj + '.' + meth);
                            if (e.comment) {
                                print(e.comment);
                            }
                            if (e.jsUnitMessage) {
                                print(e.jsUnitMessage);
                            }
                            failures += 1;
                        } else {
                            print('ERROR:', obj + '.' + meth);
                            print(e.description || e);
                            errors += 1;
                        }
                    }
                    td.call(tcase);
                }
            }
        }
    }
    
    print('\n--------------------------------------------------------------------------------\n');
    print("Tests run:", tests);
    print("Successes:", successes);
    print("Failures: ", failures);
    print("Errors:   ", errors);
    
    print("\nDone");
    quit();
})(arguments);

// End of jstest Rhino harness