## Licensed to Cloudera, Inc. under one
## or more contributor license agreements.  See the NOTICE file
## distributed with this work for additional information
## regarding copyright ownership.  Cloudera, Inc. licenses this file
## to you under the Apache License, Version 2.0 (the
## "License"); you may not use this file except in compliance
## with the License.  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
<%!
from desktop.views import commonheader, commonfooter
from django.utils.translation import ugettext as _
%>

<%namespace name="layout" file="layout.mako" />
<%namespace name="util" file="util.mako" />
<%namespace name="comps" file="beeswax_components.mako" />

${ commonheader(_('Query Results'), app_name, user, '100px') | n,unicode }
${layout.menubar(section='query')}

<style>
  #collapse {
    float: right;
    cursor: pointer;
  }

  #expand {
    display: none;
    cursor: pointer;
    position: absolute;
    background-color: #01639C;
    padding: 3px;
    -webkit-border-top-right-radius: 5px;
    -webkit-border-bottom-right-radius: 5px;
    -moz-border-radius-topright: 5px;
    -moz-border-radius-bottomright: 5px;
    border-top-right-radius: 5px;
    border-bottom-right-radius: 5px;
    opacity: 0.5;
    left: -4px;
  }

  #expand:hover {
    opacity: 1;
    left: 0;
  }

  .resultTable td, .resultTable th {
    white-space: nowrap;
  }

  .noLeftMargin {
    margin-left: 0!important;
  }

</style>

<div class="container-fluid">
  <h1>${_('Query Results:')} ${ util.render_query_context(query_context) }</h1>
  <div id="expand"><i class="icon-chevron-right icon-white"></i></div>
    <div class="row-fluid">
        <div class="span3">
            <div class="well sidebar-nav">
        <a id="collapse" class="btn btn-small"><i class="icon-chevron-left" rel="tooltip" title="${_('Collapse this panel')}"></i></a>
                <ul class="nav nav-list">
                    % if download_urls:
                    <li class="nav-header">${_('Downloads')}</li>
                    <li><a target="_blank" href="${download_urls["csv"]}">${_('Download as CSV')}</a></li>
                    <li><a target="_blank" href="${download_urls["xls"]}">${_('Download as XLS')}</a></li>
                    <li>
                      <label class="checkbox">
                          <input type="checkbox" class="vn-enable">
                          <a>${_('Enable visualization')}</a>
                      </label>
                    </li>
                    % endif
                    %if can_save:
                    <li><a data-toggle="modal" href="#saveAs">${_('Save')}</a></li>
                    % endif

                    <%
                      n_jobs = hadoop_jobs and len(hadoop_jobs) or 0
                      mr_jobs = (n_jobs == 1) and _('MR Job') or _('MR Jobs')
                    %>
                     % if n_jobs > 0:
                        <li class="nav-header">${mr_jobs} (${n_jobs})</li>
                        % for jobid in hadoop_jobs:
                            <li><a href="${url("jobbrowser.views.single_job", job=jobid.replace('application', 'job'))}">${ jobid.replace("application_", "") }</a></li>
                        % endfor
                    % endif
                </ul>
            </div>

          % if not query.is_finished() and query and query.design:
            <div id="multiStatementsQuery" class="alert">
              <button type="button" class="close" data-dismiss="alert">&times;</button>
              <strong>${_('Multi-statement query')}</strong></br>
              ${_('Hue stopped as one of your query contains some results.') }
              ${_('Click on') }
              <form action="${ url(app_name + ':watch_query', query.id) }?context=${ query.design.get_query_context() }" method="POST"> ${ csrf_token_field | n } 
                <input type="submit" value="${ _("next") }"/ class="btn btn-danger">
              </form>
              ${_('for continuing the execution of the remaining statements.') }
            </div>
          % endif

          <div id="jumpToColumnAlert" class="alert hide">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong>${_('Did you know?')}</strong>
            ${_('If the result contains a large number of columns, click a row to select a column to jump to.') }
            ${ _('As you type into the field, a drop-down list displays column names that match the string.')}
          </div>
        </div>

        <div class="span9">
      <ul class="nav nav-tabs">
        <li class="active"><a href="#results" data-toggle="tab">
            %if error:
                  ${_('Error')}
            %else:
                  ${_('Results')}
            %endif
        </a></li>
        <li><a href="#query" data-toggle="tab">${_('Query')}</a></li>
        <li><a href="#log" data-toggle="tab">${_('Log')}</a></li>
        % if not error:
        <li><a href="#columns" data-toggle="tab">${_('Columns')}</a></li>
        % if download_urls:
        <!--Visualization --><li><a href="#visualizations" data-toggle="tab" style="display: none;">${_('Visualizations') }</a></li><!--/Visualization -->
        % endif
        % endif
      </ul>

      <div class="tab-content">
        <div class="active tab-pane" id="results">
            % if error:
              <div class="alert alert-error">
                <h3>${_('Error!')}</h3>
                <pre>${ error_message }</pre>
                % if expired and query_context:
                    <div class="well">
                        ${ _('The query result has expired.') }
                        ${ _('You can rerun it from ') } ${ util.render_query_context(query_context) }
                    </div>
                % endif
              </div>
            % else:
            % if expected_first_row != start_row:
                <div class="alert"><strong>${_('Warning:')}</strong> ${_('Page offset may have incremented since last view.')}</div>
            % endif
            <table class="table table-striped table-condensed resultTable" cellpadding="0" cellspacing="0" data-tablescroller-min-height-disable="true" data-tablescroller-enforce-height="true">
            <thead>
            <tr>
              <th>&nbsp;</th>
              % for col in columns:
                <th>${col}</th>
              % endfor
            </tr>
            </thead>
            <tbody>
              % for i, row in enumerate(results):
              <tr>
                <td>${start_row + i}</td>
                % for item in row:
                  <td>${ item }</td>
                % endfor
              </tr>
              % endfor
            </tbody>
            </table>
            <div class="pagination pull-right">
              <ul>
              % if start_row != 0:
                      <li class="prev"><a title="${_('Beginning of List')}" href="${ url(app_name + ':view_results', query.id, 0) }${'?context=' + context_param or '' | n}">&larr; ${_('Beginning of List')}</a></li>
              % endif
              % if has_more and len(results) == 100:
                  <li><a title="${_('Next page')}" href= "${ url(app_name + ':view_results', query.id, next_row) }${'?context=' + context_param or '' | n }">${_('Next Page')} &rarr;</a></li>
              % endif
              </ul>
            </div>
            % endif
        </div>

        <div class="tab-pane" id="query">
          <pre>${ query.get_current_statement() }</pre>
        </div>

        <div class="tab-pane" id="log">
          <pre>${ log }</pre>
        </div>

        % if not error and download_urls.get("csv"):
        <div class="tab-pane" id="columns">
          <table class="table table-striped table-condensed" cellpadding="0" cellspacing="0">
            <thead>
              <tr><th>${_('Name')}</th></tr>
            </thead>
            <tbody>
              % for col in columns:
                <tr><td>${col}</td></tr>
              % endfor
            </tbody>
          </table>
        </div>
        % if columns:
        <!--- Visualization -->
        <link href="/pig/static/css/codemirror.css" rel="stylesheet">
        <link href="/beeswax/static/css/visualization.css" rel="stylesheet">
        <script src="/pig/static/js/codemirror.js"></script>
        <script src="/beeswax/static/js/visualization.js"></script>
        <script src="/beeswax/static/js/htmlmixed.js"></script>
        <script src="/beeswax/static/js/xml.js"></script>
        <script src="/beeswax/static/js/css.js"></script>
        <script src="/beeswax/static/js/javascript.js"></script>
        <script src="/beeswax/static/js/lib/jquery.csv-0.71.min.js"></script>
        <div class="tab-pane" id="visualizations">
              <!--<textarea id="vis_code" name="code">
                <script>
                var settings = {
                  csv:"${download_urls["csv"]}",
                  xAxis:"${columns[0]}",
                  yAxis:[
                    % for col in columns[1:]:
                    "${col}",
                    % endfor
                    ],
                  minY:null,
                  maxY:null
                }
                </script>
              </textarea>-->
          <div class='chart_type_selectors'>
            <div class='chart_type_wrap x_axis'>
              <div class="nav-header">${_('x Axis:') }</div>
              <select name="xAxis" id="xAxis">
                % for col in columns:
                <option value='"${col}"'>${col}</option>
                % endfor
              </select>
            </div>
            <div class='chart_type_wrap y_axis' >
              yAxis:<br/>
              <input type="checkbox" name="yAxis" value="${columns[0]}">${columns[0]}<br>
              % for col in columns[1:]:
              <input type="checkbox" name="yAxis" value="${col}" checked="checked" >${col}<br>
              % endfor
            </div>
            <div class='chart_type_wrap chart_type'>
              <div class="nav-header">${_('chart type:') }</div>
              <input type="radio" name="type" value="area"        id="area"  checked="checked"/><label for="area">${_('area') }</label>
              <input type="radio" name="type" value="bar"         id="bar"                    /><label for="bar">${_('bar') }</label>
              <input type="radio" name="type" value="line"        id="line"                   /><label for="line">${_('line') }</label>
              <input type="radio" name="type" value="scatterplot" id="scatterplot"            /><label for="scatterplot">${_('scatter') }</label>
              <input type="radio" name="type" value="pie"         id="pie"                    /><label for="pie"> ${_('pie') }</label>
            </div>
            <div class='chart_type_wrap value_type'>
              <div class="nav-header">${_('value type:') }</div>
              <input type="radio" name="stacked" value="false"  /> <img src='/beeswax/static/css/images/charts/stack.png'> ${_('stack') }<br/>
              <input type="radio" name="stacked" value="true" checked="checked" /> <img src='/beeswax/static/css/images/charts/value.png'> ${_('value') }<br/>
            </div>
            <div class='chart_type_wrap sort'>
              <div class="nav-header">${_('Sort:') }</div>
              <select name="sort" id="graph_sort">
                <option value=''></option>
              </select>
            </div>
            <div class="chart_type_wrap direction">
              <div class="nav-header">${_('Direction:') }</div>
              <input type="radio" name="direction" value="true" checked="checked" />  ${_('asc') }<br/>
              <input type="radio" name="direction" value="false"  /> ${_('desc') }<br/>
            </div>

            <input type="hidden" value='${download_urls["csv"]}' name="csv"/>
            <input type="hidden" value='${visualize_url}' name="visualize_csv"/>
          </div>
          <div class='nav-header chart_toobig_message hide'>${_('Can\'t show visualizations for more than 1000 rows')}</div>
          <div class='nav-header chart_nodata_message hide'>${_('No data to visualize')}</div>
          <iframe id="preview" class="well"></iframe>
        </div>
        <!--/Visualization -->
        % else:

         <div class="tab-pane" id="visualizations"></div>
        % endif
        % endif
      </div>

        </div>
    </div>
</div>

%if can_save:
## duplication from save_results.mako
<div id="saveAs" class="modal hide fade">
  <form id="saveForm" action="${url(app_name + ':save_results', query.id) }" method="POST"
        class="form form-inline form-padding-fix"> ${ csrf_token_field | n } 
    <div class="modal-header">
      <a href="#" class="close" data-dismiss="modal">&times;</a>
      <h3>${_('Save Query Results')}</h3>
    </div>
    <div class="modal-body">
      <label class="radio">
        <input id="id_save_target_0" type="radio" name="save_target" value="to a new table" checked="checked"/>
        &nbsp;${_('In a new table')}
      </label>
      ${comps.field(save_form['target_table'], notitle=True, placeholder=_('Table Name'))}
      <br/>
      <label class="radio">
        <input id="id_save_target_1" type="radio" name="save_target" value="to HDFS directory">
        &nbsp;${_('In an HDFS directory')}
      </label>
      ${comps.field(save_form['target_dir'], notitle=True, hidden=True, placeholder=_('Results location'), klass="pathChooser")}
      <br/>
      <br/>
      <div id="fileChooserModal" class="smallModal well hide">
        <a href="#" class="close" data-dismiss="modal">&times;</a>
      </div>
    </div>
    <div class="modal-footer">
      <div id="fieldRequired" class="hide" style="position: absolute; left: 10;">
        <span class="label label-important">${_('Sorry, name is required.')}</span>
      </div>
      <a class="btn" data-dismiss="modal">${_('Cancel')}</a>
      <a id="saveBtn" class="btn btn-primary">${_('Save')}</a>
      <input type="hidden" name="save" value="save"/>
    </div>
  </form>
</div>
%endif.resultTable



<script type="text/javascript" charset="utf-8">
    $(document).ready(function () {
      $(".resultTable").dataTable({
        "bPaginate": false,
        "bLengthChange": false,
        "bInfo": false,
        "oLanguage": {
            "sEmptyTable": "${_('No data available')}",
            "sZeroRecords": "${_('No matching records')}",
        },
        "fnDrawCallback": function( oSettings ) {
          $(".resultTable").jHueTableExtender({
            hintElement: "#jumpToColumnAlert",
            fixedHeader: true,
            firstColumnTooltip: true
          });
        }
      });
      $(".dataTables_wrapper").css("min-height", "0");
      $(".dataTables_filter").hide();
      $("input[name='save_target']").change(function () {
        $("#fieldRequired").addClass("hide");
        $("input[name='target_dir']").removeClass("fieldError");
        $("input[name='target_table']").removeClass("fieldError");
        if ($(this).val().indexOf("HDFS") > -1) {
          $("input[name='target_table']").addClass("hide");
          $("input[name='target_dir']").removeClass("hide");
          $(".fileChooserBtn").removeClass("hide");
        }
        else {
          $("input[name='target_table']").removeClass("hide");
          $("input[name='target_dir']").addClass("hide");
          $(".fileChooserBtn").addClass("hide");
        }
      });

      $("#saveBtn").click(function () {
        if ($("input[name='save_target']:checked").val().indexOf("HDFS") > -1) {
          if ($.trim($("input[name='target_dir']").val()) == "") {
            $("#fieldRequired").removeClass("hide");
            $("input[name='target_dir']").addClass("fieldError");
            return false;
          }
        }
        else {
          if ($.trim($("input[name='target_table']").val()) == "") {
            $("#fieldRequired").removeClass("hide");
            $("input[name='target_table']").addClass("fieldError");
            return false;
          }
        }
        $("#saveForm").submit();
      });


      $("input[name='target_dir']").after(getFileBrowseButton($("input[name='target_dir']")));

      function getFileBrowseButton(inputElement) {
        return $("<a>").addClass("btn").addClass("fileChooserBtn").addClass("hide").text("..").click(function (e) {
          e.preventDefault();
          $("#fileChooserModal").jHueFileChooser({
            onFolderChange:function (filePath) {
              inputElement.val(filePath);
            },
            onFolderChoose:function (filePath) {
              inputElement.val(filePath);
              $("#fileChooserModal").slideUp();
            },
            createFolder:false,
            uploadFile:false,
            selectFolder:true,
            initialPath:$.trim(inputElement.val())
          });
          $("#fileChooserModal").slideDown();
        });
      }

      $("#collapse").click(function () {
        $(".sidebar-nav").parent().css("margin-left", "-31%");
        $("#expand").show().css("top", $(".sidebar-nav i").position().top + "px");
        $(".sidebar-nav").parent().next().removeClass("span9").addClass("span12").addClass("noLeftMargin");
      });
      $("#expand").click(function () {
        $(this).hide();
        $(".sidebar-nav").parent().next().removeClass("span12").addClass("span9").removeClass("noLeftMargin");
        $(".sidebar-nav").parent().css("margin-left", "0");
      });



      resizeLogs();

      $(window).resize(function () {
        resizeLogs();
      });

      $("a[href='#log']").on("shown", function () {
        resizeLogs();
      });

      function resizeLogs() {
        $("#log pre").css("overflow", "auto").height($(window).height() - $("#log pre").position().top - 40);
      }

      $('.vn-enable').change(function () {
        if ($(this).attr('checked')) {
          $('a[href="#visualizations"]').show();
        } else {
          $('a[href="#visualizations"]').hide();
        }
      });

    });
</script>

${ commonfooter(messages) | n,unicode }
