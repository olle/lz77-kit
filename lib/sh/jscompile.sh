#!/usr/bin/env python

# jscompile
#
# http://code.google.com/p/js-ria-tools/
# 
# This script reads a file of file names pointing to JavaScript files, 
# concatenates the contents of those files and saves a minified (using 
# jsmin - code and license below) and un-minified versions.
# 
# Written by Steven Kollars
# 
# Copyright (c) 2007-2008 Rackspace (www.rackspace.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy 
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights 
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
# copies of the Software, and to permit persons to whom the Software is 
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in 
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
#
# jsmin
#
# This code is original from jsmin by Douglas Crockford, it was translated to
# Python by Baruch Even. The original code had the following copyright and
# license.
#
# jsmin.c
#    2007-05-22
#
# Copyright (c) 2002 Douglas Crockford  (www.crockford.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# The Software shall be used for Good, not Evil.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

from StringIO import StringIO

def jsmin(js):
    ins = StringIO(js)
    outs = StringIO()
    JavascriptMinify().minify(ins, outs)
    str = outs.getvalue()
    if len(str) > 0 and str[0] == '\n':
        str = str[1:]
    return str

def isAlphanum(c):
    """return true if the character is a letter, digit, underscore,
           dollar sign, or non-ASCII character.
    """
    return ((c >= 'a' and c <= 'z') or (c >= '0' and c <= '9') or
            (c >= 'A' and c <= 'Z') or c == '_' or c == '$' or c == '\\' or (c is not None and ord(c) > 126));

class UnterminatedComment(Exception):
    pass

class UnterminatedStringLiteral(Exception):
    pass

class UnterminatedRegularExpression(Exception):
    pass

class JavascriptMinify(object):

    def _outA(self):
        self.outstream.write(self.theA)
    def _outB(self):
        self.outstream.write(self.theB)

    def _get(self):
        """return the next character from stdin. Watch out for lookahead. If
           the character is a control character, translate it to a space or
           linefeed.
        """
        c = self.theLookahead
        self.theLookahead = None
        if c == None:
            c = self.instream.read(1)
        if c >= ' ' or c == '\n':
            return c
        if c == '': # EOF
            return '\000'
        if c == '\r':
            return '\n'
        return ' '

    def _peek(self):
        self.theLookahead = self._get()
        return self.theLookahead

    def _next(self):
        """get the next character, excluding comments. peek() is used to see
           if a '/' is followed by a '/' or '*'.
        """
        c = self._get()
        if c == '/':
            p = self._peek()
            if p == '/':
                c = self._get()
                while c > '\n':
                    c = self._get()
                return c
            if p == '*':
                c = self._get()
                while 1:
                    c = self._get()
                    if c == '*':
                        if self._peek() == '/':
                            self._get()
                            return ' '
                    if c == '\000':
                        raise UnterminatedComment()

        return c

    def _action(self, action):
        """do something! What you do is determined by the argument:
           1   Output A. Copy B to A. Get the next B.
           2   Copy B to A. Get the next B. (Delete A).
           3   Get the next B. (Delete B).
           action treats a string as a single character. Wow!
           action recognizes a regular expression if it is preceded by ( or , or =.
        """
        if action <= 1:
            self._outA()

        if action <= 2:
            self.theA = self.theB
            if self.theA == "'" or self.theA == '"':
                while 1:
                    self._outA()
                    self.theA = self._get()
                    if self.theA == self.theB:
                        break
                    if self.theA <= '\n':
                        raise UnterminatedStringLiteral()
                    if self.theA == '\\':
                        self._outA()
                        self.theA = self._get()


        if action <= 3:
            self.theB = self._next()
            if self.theB == '/' and (self.theA == '(' or self.theA == ',' or
                                     self.theA == '=' or self.theA == ':' or
                                     self.theA == '[' or self.theA == '?' or
                                     self.theA == '!' or self.theA == '&' or
                                     self.theA == '|' or self.theA == ';' or
                                     self.theA == '{' or self.theA == '}' or
                                     self.theA == '\n'):
                self._outA()
                self._outB()
                while 1:
                    self.theA = self._get()
                    if self.theA == '/':
                        break
                    elif self.theA == '\\':
                        self._outA()
                        self.theA = self._get()
                    elif self.theA <= '\n':
                        raise UnterminatedRegularExpression()
                    self._outA()
                self.theB = self._next()


    def _jsmin(self):
        """Copy the input to the output, deleting the characters which are
           insignificant to JavaScript. Comments will be removed. Tabs will be
           replaced with spaces. Carriage returns will be replaced with linefeeds.
           Most spaces and linefeeds will be removed.
        """
        self.theA = '\n'
        self._action(3)

        while self.theA != '\000':
            if self.theA == ' ':
                if isAlphanum(self.theB):
                    self._action(1)
                else:
                    self._action(2)
            elif self.theA == '\n':
                if self.theB in ['{', '[', '(', '+', '-']:
                    self._action(1)
                elif self.theB == ' ':
                    self._action(3)
                else:
                    if isAlphanum(self.theB):
                        self._action(1)
                    else:
                        self._action(2)
            else:
                if self.theB == ' ':
                    if isAlphanum(self.theA):
                        self._action(1)
                    else:
                        self._action(3)
                elif self.theB == '\n':
                    if self.theA in ['}', ']', ')', '+', '-', '"', '\'']:
                        self._action(1)
                    else:
                        if isAlphanum(self.theA):
                            self._action(1)
                        else:
                            self._action(3)
                else:
                    self._action(1)

    def minify(self, instream, outstream):
        self.instream = instream
        self.outstream = outstream
        self.theA = '\n'
        self.theB = None
        self.theLookahead = None

        self._jsmin()
        self.instream.close()

# End of jsmin code
        
# Start of jscompile code

import os
import sys
import getopt


class JSCompiler(object):
    def __init__(self):
        # Various Options
        self.all = False
        self.lint = False
        self.slint = False
        self.lint_file = None
        self.run = True
        self.prompt = True
        self.preprocess = False
        self.build = 'build.txt'
        self.prod = 'all.js'
        self.debug = 'all-debug.js'
        
        self.ignore_dirs = ['.svn']
        
        self.source_list = []
        self.include_files = []
        
    def compile(self, path):
        print "\nStart Compiling\n"
        
        build = os.path.join(path, self.build)
        
        if not self.parse_configuration_file(build):
            return
            
        prod = os.path.join(path, self.prod)
        debug = os.path.join(path, self.debug)
        
        print "\nProduction file:\n %s\n" % prod
        print "Debug file:\n %s\n" % debug
        
        self.expand_source_list(path)
        
        all_data = []
        for file in self.include_files:
            try:
                jf = open(file)
                try:
                    all_data.append(jf.read())
                finally:
                    jf.close()
            except IOError:
                print "Couldn't open file %s" % file
                
        all_data = "\n".join(all_data)
                
        print "Creating debug file"
        df = open(debug, 'w')
        df.write(all_data)
        df.close()
        
        if self.preprocess:
            print "Processing data"
            print os.popen("jsprocessor %s" % debug).read()
            
            # The preprocessor can't handle STDIN/STDOUT (it was easier 
            # for me to just make it modify the file) so we have to read
            # the file back in to get the changes.
            try:
                df = open(debug)
                try:
                    all_data = df.read()
                finally:
                    df.close()
            except IOError:
                print "Couldn't open file %s" % debug
                
        print "Creating production file"
        pf = open(prod, 'w')
        pf.write(jsmin(all_data))
        pf.close()
        
        if self.lint or self.slint:
            print "\nRunning lint..."
            if self.preprocess:
                # If we are preprocessing, we can't run the original files
                # through the lint process.  We have to lint the post-
                # processed data.
                lint_files = debug
            else:
                lint_files = " ".join([file for file in self.include_files])
            if self.lint:
                lint_cmd = "jslint"
            elif self.slint:
                lint_cmd = "spiderlint"
            lint_results = os.popen("%s %s" % (lint_cmd, lint_files)).read()
            if self.lint_file:
                lint_file = os.path.join(path, self.lint_file)
                try:
                    lf = open(lint_file, 'w')
                    try:
                        lf.write(lint_results)
                        print "Lint results were saved to %s" % lint_file
                    finally:
                        lf.close()
                except IOError:
                    print "Couldn't save lint results to %s" % lint_file
            else:
                print lint_results
            print "Done Linting\n"
        
        print "\nDone Compiling\n"
        
    def parse_configuration_file(self, build_file):
        print "Configuration file:\n %s\n" % build_file
        try:
            cf = open(build_file)
            try:
                lines = cf.readlines()
            finally:
                cf.close()
                
        except IOError:
            print "Couldn't read configuration file"
            return False
            
        for line in lines:
            clean_line = line.replace('\n', '').replace('\r', '').strip()
            if clean_line == '':
                pass # Ignore empty lines
                
            elif clean_line.startswith('//'): 
                pass # Ignore comments
                
            elif clean_line.startswith('production'):
                self.prod = clean_line[10:].strip()
                print "Set production file to %s" % self.prod
                
            elif clean_line.startswith('debug'):
                self.debug = clean_line[5:].strip()
                print "Set debug file to %s" % self.debug
                
            elif clean_line.startswith('lint'):
                self.lint = True
                print "Turned linting on"
                self.lint_file = clean_line[4:].strip()
                print "Set lint report file to %s" % self.lint_file
                
            elif clean_line.startswith('spiderlint'):
                self.slint = True
                print "Turned linting on"
                self.lint_file = clean_line[10:].strip()
                print "Set lint report file to %s" % self.lint_file
                
            elif clean_line.startswith('preprocess'):
                self.preprocess = True
                print "Turned preprocessing on"
                
            elif clean_line.startswith('noprompt'):
                self.prompt = False
                print "Turned prompts off"
                
            elif clean_line.startswith('execute'):
                if not self.run:
                    continue
                    
                command = clean_line[7:].strip()
                self.execute_command(command)
                
            else:
                self.source_list.append(clean_line)
                
        return True
                
    def execute_command(self, command):
        allow_command = False
        if self.prompt:
            answer = raw_input(
                "Would you like to allow the following " + 
                "command to run?\n %s\n[Y/n] " % command)
            if answer.lower().startswith('y'):
                allow_command = True
            
        if allow_command:
            print "Executing command:\n %s\n" % command
            print os.popen(command).read()
            print "Done Executing\n"
        else:
            print "Skipping command:\n %s\n" % command
            
    def expand_source_list(self, path):
        def add_file(self, file):
            if not file.endswith('.js'):
                print "Ignoring file %s" % file
                return
            
            print "Source file %s" % file
            self.include_files.append(file)
            
        for source in self.source_list:
            file = os.path.join(path, source)
            if os.path.isfile(file):
                add_file(self, file)
                
            elif os.path.isdir(file):
                for root, dirs, files in os.walk(file):
                    for f in files:
                        add_file(self, os.path.join(root, f))
                    for dir in self.ignore_dirs:
                        if dir in dirs:
                            dirs.remove(dir)
                
            else:
                print "Invalid file %s" % source
                
    def run_one(self, path):
        print "Directory:\n %s" % path
        if os.path.isfile(os.path.join(path, self.build)):
            self.compile(path)
        else:
            print "No configuration file found"
            
    def run_all(self, path):
        print "Directory:\n %s" % path
        files = os.listdir(path)
        for file in files:
            abs_path = os.path.join(path, file)
            if os.path.isdir(abs_path) and file not in self.ignore_dirs:
                self.run_all(abs_path)
            elif os.path.isfile(abs_path) and file == self.build:
                self.compile(path)
                
                
def usage():
    print """\
Usage: 
 jscompile [-h|--help] [-a|--all] [-l|--lint <file>] [-s|--spiderlint <file>] 
   [-X|--noexecute] [-P|--noprompt] [-b|--build <file>] [-p|--prod <file>] 
   [-d|--debug <file>]
  
Used without any options, this script will search the current directory for 
a build file (defaults to 'build.txt'), parse that file to get a list of 
JavaScript files, concatenate the contents of those files and then save a 
production (defaults to 'all.js', minified using jsmin) and a debug (defaults
to 'all-debug.js', unminified) version of the output.

Using the all flag will cause the script to perform its operations on the 
current directory and any subdirectories (ignoring .svn directories).

Using the lint or spiderlint flags will cause the script to run each 
JavaScript file through jslint or spiderlint before it is compiled. 

Using the noexecute flag will cause the script to ignore any execute 
statements found in the build file.

Using the noprompt flag will cause the script to not prompt before running any
execute statements.

Passing values for the build, prod or debug flags will tell the script to 
use the passed values instead of the default values.


Options: 
 -h, --help        Displays this message.
 -a, --all         Look in the current directory and any subdirectories for 
                      build files.
 -l, --lint        Run jslint on all files (JSLint w/ Rhino).
 -s, --spiderlint  Run spiderlint on all files (JSLint w/ SpiderMonkey).
 -X, --noexecute   Ignore any execute statements.
 -P, --noprompt    Do not prompt before running any execute statements.
 -b, --build       Name of the build file.
 -p, --prod        Name of the target production file.
 -d, --debug       Name of the target debug file.

 
Build Files:

A build file is a simple text file that should specify one JavaScript file or
one directory, relative to the build file's location, per line. 
Subdirectories of specified directories will also be searched.  Files that
don't end in '.js' will be ignored.

Empty lines are ignored.

Lines beginning with '//' are treated as comments and ignored.

The following statements can also be added to the build file and will override 
any default settings or settings that were passed in on the command line.

production <file>
 The target production file

debug <file>
 The target debug file

lint <file>
 Run the JavaScript files through jslint (JSLint w/ Rhino)

spiderlint <file>
 Run the JavaScript files through spiderlint (JSLint w/ SpiderMonkey)

noprompt
 Don't prompt before running any execute statements

execute <command>
 Run the specified command.  The command can be any command that can be 
 executed from the command line.
"""

def main():
    try:
        opts, args = getopt.getopt(
                sys.argv[1:], 
                "has:l:XPb:p:d:", 
                ["help", "all", "spiderlint=", "lint=", "noexecute", 
                    "noprompt", "build=", "prod=", "debug="])
    except getopt.GetoptError:
        usage()
        sys.exit(2)
    
    compiler = JSCompiler()
    path = os.getcwd()
    
    for o, a in opts:
        if o in ('-h', '--help'):
            usage()
            sys.exit()
        elif o in ('-a', '--all'):
            compiler.all = True
        elif o in ('-l', '--lint'):
            compiler.lint = True
            compiler.lint_file = a
        elif o in ('-s', '--spiderlint'):
            compiler.slint = True
            compiler.lint_file = a
        elif o in ('-b', '--build'):
            compiler.build = a
        elif o in ('-p', '--prod'):
            compiler.prod = a
        elif o in ('-d', '--debug'):
            compiler.debug = a
        elif o in ('-X', '--noexecute'):
            compiler.run = False
        elif o in ('-P', '--noprompt'):
            compiler.prompt = False
    
    print "jscompile starting..."

    if compiler.all:
        print "Looking at current directory and subdirectories"
        compiler.run_all(path)
    else: 
        print "Looking at current directory"
        compiler.run_one(path)
        
    print "Done"

if __name__ == "__main__":
    main()
    
# End of jscompile code
    
