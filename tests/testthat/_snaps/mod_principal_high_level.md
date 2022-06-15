# ui is created correctly

    Code
      mod_principal_high_level_ui("id")
    Output
      <h1>High level activity estimates (principal projection)</h1>
      <div class="row">
        <div class="col-sm-12">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Activity Estimates</h3>
              <div class="card-tools float-right">
                <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                  <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                </button>
              </div>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-4b174f1cea96b659dd3d0255d49107ec" class="loader">Loading...</div>
                </div>
                <div style="height:400px" class="shiny-spinner-placeholder"></div>
                <div id="id-activity" class="shiny-html-output"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Activity Estimates","solidHeader":true,"width":12,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>
      <div class="row">
        <div class="col-sm-4">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">A&amp;E Attendances</h3>
              <div class="card-tools float-right">
                <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                  <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                </button>
              </div>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-57a7132147e4d9193d50448764b04413" class="loader">Loading...</div>
                </div>
                <div id="id-aae" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"A&amp;E Attendances","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-4">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Inpatient Admissions</h3>
              <div class="card-tools float-right">
                <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                  <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                </button>
              </div>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-5b107025a075291bc098523b663b5650" class="loader">Loading...</div>
                </div>
                <div id="id-ip" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Inpatient Admissions","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
        <div class="col-sm-4">
          <div class="card bs4Dash">
            <div class="card-header">
              <h3 class="card-title">Outpatient Attendances</h3>
              <div class="card-tools float-right">
                <button class="btn btn-tool btn-sm" type="button" data-card-widget="collapse">
                  <i class="fa fa-minus" role="presentation" aria-label="minus icon"></i>
                </button>
              </div>
            </div>
            <div class="card-body">
              <div class="shiny-spinner-output-container shiny-spinner-hideui ">
                <div class="load-container shiny-spinner-hidden load1">
                  <div id="spinner-021735fc960c4103867e436eb68c2826" class="loader">Loading...</div>
                </div>
                <div id="id-op" style="width:100%; height:400px; " class="plotly html-widget html-widget-output shiny-report-size shiny-report-theme"></div>
              </div>
            </div>
          </div>
          <script type="application/json">{"title":"Outpatient Attendances","solidHeader":true,"width":4,"collapsible":true,"closable":false,"maximizable":false,"gradient":false}</script>
        </div>
      </div>

# mod_principal_high_level_table returns a gt

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
        <table class="gt_table">
        
        <thead class="gt_col_headings">
          <tr>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1"></th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">2018/19</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">2019/20</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_right" rowspan="1" colspan="1">2020/21</th>
          </tr>
        </thead>
        <tbody class="gt_table_body">
          <tr><td class="gt_row gt_left">A&amp;E Attendance</td>
      <td class="gt_row gt_right">135,000</td>
      <td class="gt_row gt_right">136,000</td>
      <td class="gt_row gt_right">137,000</td></tr>
          <tr><td class="gt_row gt_left">Elective Admission</td>
      <td class="gt_row gt_right">8,800</td>
      <td class="gt_row gt_right">9,750</td>
      <td class="gt_row gt_right">10,700</td></tr>
          <tr><td class="gt_row gt_left">Daycase Admission</td>
      <td class="gt_row gt_right">58,000</td>
      <td class="gt_row gt_right">66,000</td>
      <td class="gt_row gt_right">74,000</td></tr>
          <tr><td class="gt_row gt_left">Non-Elective Admission</td>
      <td class="gt_row gt_right">60,000</td>
      <td class="gt_row gt_right">65,000</td>
      <td class="gt_row gt_right">70,000</td></tr>
          <tr><td class="gt_row gt_left">Birth Episode</td>
      <td class="gt_row gt_right">1,100</td>
      <td class="gt_row gt_right">1,150</td>
      <td class="gt_row gt_right">1,200</td></tr>
          <tr><td class="gt_row gt_left">First Outpatient Attendance</td>
      <td class="gt_row gt_right">140,000</td>
      <td class="gt_row gt_right">145,000</td>
      <td class="gt_row gt_right">150,000</td></tr>
          <tr><td class="gt_row gt_left">Follow-up Outpatient Attendance</td>
      <td class="gt_row gt_right">370,000</td>
      <td class="gt_row gt_right">380,000</td>
      <td class="gt_row gt_right">390,000</td></tr>
          <tr><td class="gt_row gt_left">Outpatient Procedure</td>
      <td class="gt_row gt_right">42,000</td>
      <td class="gt_row gt_right">44,500</td>
      <td class="gt_row gt_right">47,000</td></tr>
        </tbody>
        
        
      </table>
      </div>

