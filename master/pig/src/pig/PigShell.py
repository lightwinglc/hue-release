## Licensed to the Apache Software Foundation (ASF) under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.
from CommandPy import CommandPy

class PigShell(CommandPy):

    commandOutput = ('DESCRIBE', 'EXPLAIN', 'DUMP',
                     'ILLUSTRATE', 'STORE', 'CAT')

    def ShowCommands(self, command, limit = None):
        """
        This method get 1 parameter. (EXPLAIN or DESCRIBE)
        Return code with one of this commands
        return False - means that in file no variables
        """
        if command not in self.commandOutput:
            return False
            
        last_variable = self.getLastVariable()
        if not last_variable:
            return False

        fl = open(self.file_path, 'r')
        code = self.validate(fl.readlines())
        fl.close()
        if limit:
            from random import randint
            new_var = ''.join([chr(randint(65,90)) for x in range(1, 11)])
            code.append('%s = LIMIT %s %d;\n' % (new_var, last_variable, limit))
            last_variable = new_var
        code.append('%s %s;\n' % (command, last_variable))
        code = '\n'.join(code)

        # Create temporary file
        file_name = self.createPigFile(self.file_path, code)
        temp_path = self.shell_path[:-1]
        temp_path.append(file_name)
        self.shell_path = temp_path
        returnCommand = self.returnCode()

        # delete temporary file
        self.deletePigFile(file_name)

        return returnCommand

    def validate(self, text):
        """
        This method delete all output command
        Return filter text
        """
        return [t for t in text if t.split(' ')[0].upper() not in self.commandOutput]


    def createPigFile(self, name, text):
        """
        Create temporary pig script file
        Return temporary file name
        """
        from time import time
        file_name = self.file_path[:-4]
        new_file = '%s_%d.pig' % (file_name, int(time()))
        a = open(new_file, 'w')
        a.write(text)
        a.close()
        return new_file

    def deletePigFile(self, name):
        """
        Delete pig script file
        """
        from os import remove
        remove(name)

    def getLastVariable(self):
        """
        This method find last declared variable in PIG file script
        """
        fl = open(self.file_path, 'r')
        code = fl.readlines()[::-1]
        last_variable = ''
        for c in code:
            try:
                var_index = c.index('=')
                if c[var_index - 1] not in ['<', '!', '>'] and c[var_index + 1] not in ['=']:
                    last_variable = c[:var_index - 1].strip()
                    break
            except ValueError:
                continue

        fl.close()

        return last_variable
