## Licensed to Hortonworks, inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  The ASF licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
## http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing,
## software distributed under the License is distributed on an
## "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
## KIND, either express or implied.  See the License for the
## specific language governing permissions and limitations
## under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

${ commonheader(_('Hbase'), 'hbase', user) | n,unicode }
<div class="container-fluid">
  <form method="POST" action="#">
    ${ csrf_token_field | n }
    <p>
      <label>${_('Table name')}</label>
      <input type="text" name="table_name" required="required"  />
      <input type="hidden" name="data" data-bind="value: jsonData()"
    </p>
    <p class="span-9">
      <div class="btn-group">
          <a href="#cf_popup" role="button"  data-toggle="modal"
             class="btn btn-primary btn-mini">${_('Add Column Family ')}<i class="icon-plus-sign icon-white"></i></a>&nbsp;
          <button class="btn btn-warning btn-mini" data-bind="click: removeCF">${_('Delete Column Family ')}
          <i class="icon-remove icon-white"></i></button>
          </div>

      <table class="table table-bordered">
        <caption><h2>${_('Column families')}</h2></caption>
        <thead>
          <tr>
            <td><input type="checkbox" data-bind="click: selectAllCFs" /></td>
            <td>${_('Name')}</td>
            <td>${_('Options')}</td>
          </tr>
        </thead>
        <tbody data-bind="foreach: cf">
          <tr>
            <td><input type="checkbox" data-bind="checked: toRemove" class="remove_cf" /></td>
            <td data-bind="text: name"></td>
            <td data-bind="html: options()"></td>
          </tr>
        </tbody>
      </table>
    </p>
    
     <input type="submit" value="${_('Create table')}" />
  </form>
</div>

<div id="cf_popup" class="modal hide fade" tabindex="-1" role="dialog"
     aria-labelledby="myModalLabel" aria-hidden="true">
<form data-bind="submit: addCF" id="cf_form">
  <div class="modal-header">
    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">x</button>
    <h3 id="myModalLabel">${_('Add column family')}</h3>
  </div>
  <div class="modal-body">
    <p class="span-4">
      
      <label>${_('Name')}</label>
      <input type="text" data-bind="value: cfNameText" />

      <label>${_('Maximum Versions')}</label>
      <input type="number" name="max_versions" min="1"
      data-bind="value: maxVersionsValue" />

      <label>${_('Compression')}</label>
      <select data-bind="value: compressionTypeValue">
        <option>None</option>
        <option value="LZO">LZO</option>
        <option value="GZip">GZip</option>
        <option value="SNAPPY">Snappy</option>
      </select>
      <label class="checkbox">
        <input type="checkbox" data-bind="checked: inMemoryValue">${_(' In memory')}
      </label>
    </p>
    <p class="span-3">
      <label>${_('Time to live (seconds)')}</label>
      <input type="number" name="time_to_live" min="1" data-bind="value: ttlValue"/>

      <label>${_('Bloom filter number hashes')}</label>
      <input type="number" name="max_hashes" min="1" data-bind="value: bloomFilterNumHashesVal" />

      <label>${_('Bloom filter type')}</label>
      <select data-bind="value: bloomFilterTypeValue">
        <option>None</option>
        <option>ROW</option>
        <option>ROWCOL</option>
      </select>

        <label class="checkbox">
        <input type="checkbox" data-bind="checked: blockCacheValue">${_(' Block cache enabled')}
      </label>
    </p>
  </div>
  <div class="modal-footer">
    <button class="btn" data-dismiss="modal" aria-hidden="true">${_('Close')}</button>
    <button class="btn btn-primary" type="submit">${_('Add')}</button>
  </div>
</form>
</div>
 
<script src="/static/ext/js/knockout-min.js" type="text/javascript"
        charset="utf-8"></script>
<script src="/hbase/static/js/knockout.validation.js" type="text/javascript" charset="utf-8"></script>
<script src="/hbase/static/js/create_table.js" type="text/javascript"
        charset="utf-8"></script>
<script src="/hbase/static/js/json2.js" type="text/javascript" charset="utf-8"></script>
<script src="/hbase/static/js/common.js" type="text/javascript"></script>
${ commonfooter(messages) | n,unicode }
