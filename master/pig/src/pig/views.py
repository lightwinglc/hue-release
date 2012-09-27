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

from desktop.lib.django_util import render

import os
from datetime import date

#from django.test.client import Client
from django.template import RequestContext
from django.contrib.auth.decorators import login_required
#from django.core.files.uploadedfile import SimpleUploadedFile
#from django.core.paginator import Paginator, EmptyPage, InvalidPage
from django.shortcuts import render_to_response, redirect
from django.http import HttpResponse
from django import forms

from pig.models import PigScript
from django.contrib.auth.models import User
from CommandPy import CommandPy
from PigShell import PigShell

class PigScriptForm(forms.Form):
    title = forms.CharField(max_length=100, required=False)
    text = forms.CharField(widget=forms.Textarea, required=False)


def index(request, text = False):
    pig_script = PigScript.objects.filter(creater=request.user)

    form = PigScriptForm()
    if request.method == 'POST':
        form = PigScriptForm(request.POST)
        if form.is_valid():
            data = form.cleaned_data
            data['creater'] = request.user
            ps = PigScript.objects.create(**data)
            return redirect(one_script, ps.id)

    return render('index.mako', request, dict(form = form, pig_script = pig_script, text = text))


def one_script(request, obj_id, text = False):
    pig_script = PigScript.objects.filter(creater=request.user)
    instance = PigScript.objects.filter(id=obj_id)
    if request.method == 'POST':
        form = PigScriptForm(request.POST)
        if form.is_valid():
            instance.update(**form.cleaned_data)
            if request.POST.get('submit') == 'Execute':
                f1 = open('pig.pig', 'w')
                f1.write(instance[0].text)
                f1.close()
                pig = CommandPy('pig -x local pig.pig')
                text = pig.returnCode() or pig.last_error
            if request.POST.get('submit') in ['Explain', 'Describe', 'Dump']:
                command = request.POST.get('submit').upper()
                f1 = open('pig.pig', 'w')
                f1.write(instance[0].text)
                f1.close()
                pig = PigShell('pig -x local pig.pig')
                text = pig.ShowCommands(command=command) or pig.last_error
    form = PigScriptForm(instance.values('title', 'text')[0])
    return render('edit_script.mako', request, dict(form=form, instance=instance[0], pig_script=pig_script, text=text))


def delete(request, obj_id):
    instance = PigScript.objects.get(id=obj_id)
    text = instance.title + ' Deleted'
    instance.delete()
    return index(request, text = text)
