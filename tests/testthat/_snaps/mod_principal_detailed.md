# ui is created correctly

    Code
      mod_principal_detailed_ui("id")
    Output
      <h1>Detailed activity estimates (principal projection)</h1>
      <div class="row">
        <div class="col-sm-3">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-activity_type-label" for="id-measure_selection-activity_type">Activity Type</label>
            <div>
              <select id="id-measure_selection-activity_type"></select>
              <script type="application/json" data-for="id-measure_selection-activity_type" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-3">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-pod-label" for="id-measure_selection-pod">POD</label>
            <div>
              <select id="id-measure_selection-pod"></select>
              <script type="application/json" data-for="id-measure_selection-pod" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-3">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-measure_selection-measure-label" for="id-measure_selection-measure">Measure</label>
            <div>
              <select id="id-measure_selection-measure"></select>
              <script type="application/json" data-for="id-measure_selection-measure" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
        <div class="col-sm-3">
          <div class="form-group shiny-input-container">
            <label class="control-label" id="id-aggregation-label" for="id-aggregation">Aggregation</label>
            <div>
              <select id="id-aggregation"></select>
              <script type="application/json" data-for="id-aggregation" data-nonempty="">{"plugins":["selectize-plugin-a11y"]}</script>
            </div>
          </div>
        </div>
      </div>
      <div class="shiny-spinner-output-container shiny-spinner-hideui ">
        <div class="load-container shiny-spinner-hidden load1">
          <div id="spinner-a633f9f77c95364214bbb43adb765056" class="loader">Loading...</div>
        </div>
        <div style="height:400px" class="shiny-spinner-placeholder"></div>
        <div id="id-results" class="shiny-html-output"></div>
      </div>

# table returns a gt

    Code
      table
    Output
      <div id="ydgabwknrs" style="overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
        <style>html {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Helvetica Neue', 'Fira Sans', 'Droid Sans', Arial, sans-serif;
      }
      
      #ydgabwknrs .gt_table {
        display: table;
        border-collapse: collapse;
        margin-left: auto;
        margin-right: auto;
        color: #333333;
        font-size: 16px;
        font-weight: normal;
        font-style: normal;
        background-color: #FFFFFF;
        width: auto;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #FFFFFF;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 3px;
        border-bottom-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_heading {
        background-color: #FFFFFF;
        text-align: left;
        border-bottom-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_title {
        color: #333333;
        font-size: 125%;
        font-weight: initial;
        padding-top: 4px;
        padding-bottom: 4px;
        padding-left: 5px;
        padding-right: 5px;
        border-bottom-color: #FFFFFF;
        border-bottom-width: 0;
      }
      
      #ydgabwknrs .gt_subtitle {
        color: #333333;
        font-size: 12px;
        font-weight: initial;
        padding-top: 0;
        padding-bottom: 6px;
        padding-left: 5px;
        padding-right: 5px;
        border-top-color: #FFFFFF;
        border-top-width: 0;
      }
      
      #ydgabwknrs .gt_bottom_border {
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_col_headings {
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 1px;
        border-bottom-color: #000000;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_col_heading {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: normal;
        text-transform: inherit;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: bottom;
        padding-top: 5px;
        padding-bottom: 6px;
        padding-left: 5px;
        padding-right: 5px;
        overflow-x: hidden;
      }
      
      #ydgabwknrs .gt_column_spanner_outer {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: normal;
        text-transform: inherit;
        padding-top: 0;
        padding-bottom: 0;
        padding-left: 4px;
        padding-right: 4px;
      }
      
      #ydgabwknrs .gt_column_spanner_outer:first-child {
        padding-left: 0;
      }
      
      #ydgabwknrs .gt_column_spanner_outer:last-child {
        padding-right: 0;
      }
      
      #ydgabwknrs .gt_column_spanner {
        border-bottom-style: solid;
        border-bottom-width: 1px;
        border-bottom-color: #000000;
        vertical-align: bottom;
        padding-top: 5px;
        padding-bottom: 5px;
        overflow-x: hidden;
        display: inline-block;
        width: 100%;
      }
      
      #ydgabwknrs .gt_group_heading {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        color: #333333;
        background-color: #FCDF83;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #000000;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #000000;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: middle;
      }
      
      #ydgabwknrs .gt_empty_group_heading {
        padding: 0.5px;
        color: #333333;
        background-color: #FCDF83;
        font-size: 100%;
        font-weight: initial;
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #000000;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #000000;
        vertical-align: middle;
      }
      
      #ydgabwknrs .gt_from_md > :first-child {
        margin-top: 0;
      }
      
      #ydgabwknrs .gt_from_md > :last-child {
        margin-bottom: 0;
      }
      
      #ydgabwknrs .gt_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        margin: 10px;
        border-top-style: solid;
        border-top-width: 1px;
        border-top-color: #FFFFFF;
        border-left-style: none;
        border-left-width: 1px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 1px;
        border-right-color: #D3D3D3;
        vertical-align: middle;
        overflow-x: hidden;
      }
      
      #ydgabwknrs .gt_stub {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-right-style: solid;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #ydgabwknrs .gt_stub_row_group {
        color: #333333;
        background-color: #FFFFFF;
        font-size: 100%;
        font-weight: initial;
        text-transform: inherit;
        border-right-style: solid;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
        padding-left: 5px;
        padding-right: 5px;
        vertical-align: top;
      }
      
      #ydgabwknrs .gt_row_group_first td {
        border-top-width: 2px;
      }
      
      #ydgabwknrs .gt_summary_row {
        color: #333333;
        background-color: #FFFFFF;
        text-transform: inherit;
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #ydgabwknrs .gt_first_summary_row {
        border-top-style: solid;
        border-top-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_first_summary_row.thick {
        border-top-width: 2px;
      }
      
      #ydgabwknrs .gt_last_summary_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_grand_summary_row {
        color: #333333;
        background-color: #FFFFFF;
        text-transform: inherit;
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #ydgabwknrs .gt_first_grand_summary_row {
        padding-top: 8px;
        padding-bottom: 8px;
        padding-left: 5px;
        padding-right: 5px;
        border-top-style: double;
        border-top-width: 6px;
        border-top-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_striped {
        background-color: rgba(128, 128, 128, 0.05);
      }
      
      #ydgabwknrs .gt_table_body {
        border-top-style: solid;
        border-top-width: 2px;
        border-top-color: #D3D3D3;
        border-bottom-style: solid;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_footnotes {
        color: #333333;
        background-color: #FFFFFF;
        border-bottom-style: none;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_footnote {
        margin: 0px;
        font-size: 90%;
        padding-left: 4px;
        padding-right: 4px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #ydgabwknrs .gt_sourcenotes {
        color: #333333;
        background-color: #FFFFFF;
        border-bottom-style: none;
        border-bottom-width: 2px;
        border-bottom-color: #D3D3D3;
        border-left-style: none;
        border-left-width: 2px;
        border-left-color: #D3D3D3;
        border-right-style: none;
        border-right-width: 2px;
        border-right-color: #D3D3D3;
      }
      
      #ydgabwknrs .gt_sourcenote {
        font-size: 90%;
        padding-top: 4px;
        padding-bottom: 4px;
        padding-left: 5px;
        padding-right: 5px;
      }
      
      #ydgabwknrs .gt_left {
        text-align: left;
      }
      
      #ydgabwknrs .gt_center {
        text-align: center;
      }
      
      #ydgabwknrs .gt_right {
        text-align: right;
        font-variant-numeric: tabular-nums;
      }
      
      #ydgabwknrs .gt_font_normal {
        font-weight: normal;
      }
      
      #ydgabwknrs .gt_font_bold {
        font-weight: bold;
      }
      
      #ydgabwknrs .gt_font_italic {
        font-style: italic;
      }
      
      #ydgabwknrs .gt_super {
        font-size: 65%;
      }
      
      #ydgabwknrs .gt_two_val_uncert {
        display: inline-block;
        line-height: 1em;
        text-align: right;
        font-size: 60%;
        vertical-align: -0.25em;
        margin-left: 0.1em;
      }
      
      #ydgabwknrs .gt_footnote_marks {
        font-style: italic;
        font-weight: normal;
        font-size: 75%;
        vertical-align: 0.4em;
      }
      
      #ydgabwknrs .gt_asterisk {
        font-size: 100%;
        vertical-align: 0;
      }
      
      #ydgabwknrs .gt_slash_mark {
        font-size: 0.7em;
        line-height: 0.7em;
        vertical-align: 0.15em;
      }
      
      #ydgabwknrs .gt_fraction_numerator {
        font-size: 0.6em;
        line-height: 0.6em;
        vertical-align: 0.45em;
      }
      
      #ydgabwknrs .gt_fraction_denominator {
        font-size: 0.6em;
        line-height: 0.6em;
        vertical-align: -0.05em;
      }
      </style>
        <table class="gt_table" style="table-layout: fixed;">
        <colgroup>
          <col/>
          <col/>
          <col style="width:150px;"/>
          <col style="width:150px;"/>
          <col style="width:150px;"/>
        </colgroup>
        
        <thead class="gt_col_headings">
          <tr>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Age Group</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">Baseline</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Final</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Change</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1">Percent Change</th>
          </tr>
        </thead>
        <tbody class="gt_table_body">
          <tr class="gt_group_heading_row">
            <td colspan="5" class="gt_group_heading">Male</td>
          </tr>
          <tr class="gt_row_group_first"><td class="gt_row gt_left"> 0- 4</td>
      <td class="gt_row gt_right">900</td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: -110%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #686f73; width: 160%">&nbsp;</span>
        <span style="width: 50%" align="right">800</span>
      </div></td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: NaN%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: NaN%">&nbsp;</span>
        <span style="width: 50%" align="right">-100</span>
      </div></td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 50%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: 130%">&nbsp;</span>
        <span style="width: 50%" align="right">-11%</span>
      </div></td></tr>
          <tr><td class="gt_row gt_left"> 5-14</td>
      <td class="gt_row gt_right">650</td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: -110%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #686f73; width: 110%">&nbsp;</span>
        <span style="width: 50%" align="right">550</span>
      </div></td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: NaN%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: NaN%">&nbsp;</span>
        <span style="width: 50%" align="right">-100</span>
      </div></td>
      <td class="gt_row gt_left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #ec6555; width: 180%">&nbsp;</span>
        <span style="width: 50%" align="right">-15%</span>
      </div></td></tr>
        </tbody>
        
        
      </table>
      </div>

