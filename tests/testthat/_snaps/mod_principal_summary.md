# ui is created correctly

    Code
      mod_principal_summary_ui("id")
    Output
      <h1>Principal projection: summary</h1>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Notes</h3>
          </div>
          <div class="card-body">
            <p>Bed days are defined as the difference in days between discharge and admission, plus one day.
      One bed day is added to account for zero length of stay spells/partial days at the beginning and end of a spell.
      See the <a href="https://connect.strategyunitwm.nhs.uk/nhp/project_information">model project information site</a> for definitions of terms.</p>
      
            <p>Bed-availability data is not available at site level.</p>
          </div>
        </div>
        <script type="application/json">{"title":"Notes","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>
      <div class="col-sm-12">
        <div class="card bs4Dash">
          <div class="card-header">
            <h3 class="card-title">Summary by point of delivery</h3>
          </div>
          <div class="card-body">
            <div data-spinner-id="spinner-46fc03e74e82de292a3ae28234e2c826" class="shiny-spinner-output-container shiny-spinner-hideui">
              <div class="load-container shiny-spinner-hidden load1">
                <div id="spinner-46fc03e74e82de292a3ae28234e2c826" class="loader">Loading...</div>
              </div>
              <div style="height:400px" class="shiny-spinner-placeholder"></div>
              <div class="shiny-html-output gt_shiny" id="id-summary_table"></div>
            </div>
          </div>
        </div>
        <script type="application/json">{"title":"Summary by point of delivery","solidHeader":true,"width":12,"collapsible":false,"closable":false,"maximizable":false,"gradient":false}</script>
      </div>

# mod_principal_summary_table creates a gt object

    Code
      gt::as_raw_html(table)
    Output
      <div id="ydgabwknrs" style="padding-left:0px;padding-right:0px;padding-top:10px;padding-bottom:10px;overflow-x:auto;overflow-y:auto;width:auto;height:auto;">
        
        <table class="gt_table" style="-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale; font-family: system-ui, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji'; display: table; border-collapse: collapse; line-height: normal; margin-left: auto; margin-right: auto; color: #333333; font-size: 16px; font-weight: normal; font-style: normal; background-color: #FFFFFF; width: auto; border-top-style: solid; border-top-width: 2px; border-top-color: #FFFFFF; border-right-style: none; border-right-width: 2px; border-right-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 3px; border-bottom-color: #FFFFFF; border-left-style: none; border-left-width: 2px; border-left-color: #D3D3D3; table-layout: fixed;" data-quarto-disable-processing="false" data-quarto-bootstrap="false" bgcolor="#FFFFFF">
        <colgroup>
          <col>
          <col>
          <col style="width:150px;">
          <col style="width:150px;">
          <col style="width:150px;">
        </colgroup>
        <thead style="border-style: none;">
          <tr class="gt_col_headings" style="border-style: none; border-top-style: solid; border-top-width: 2px; border-top-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 1px; border-bottom-color: #000000; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3;">
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="pod_name" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: bold; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">Point of Delivery</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="baseline" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: bold; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">Baseline</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="principal" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: bold; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">Principal</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="change" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: bold; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">Change</th>
            <th class="gt_col_heading gt_columns_bottom_border gt_left" rowspan="1" colspan="1" scope="col" id="change_pcnt" style="border-style: none; color: #333333; background-color: #FFFFFF; font-size: 100%; font-weight: bold; text-transform: inherit; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: bottom; padding-top: 5px; padding-bottom: 6px; padding-left: 5px; padding-right: 5px; overflow-x: hidden; text-align: left;" bgcolor="#FFFFFF" valign="bottom" align="left">Percent Change</th>
          </tr>
        </thead>
        <tbody class="gt_table_body" style="border-style: none; border-top-style: solid; border-top-width: 2px; border-top-color: #D3D3D3; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #D3D3D3;">
          <tr class="gt_group_heading_row" style="border-style: none;">
            <th colspan="5" class="gt_group_heading" scope="colgroup" id="Inpatient" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; color: #FFFFFF; background-color: #686F73; font-size: 100%; font-weight: initial; text-transform: inherit; border-top-style: solid; border-top-width: 2px; border-top-color: #000000; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #000000; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; text-align: left;" bgcolor="#686F73" valign="middle" align="left">Inpatient</th>
          </tr>
          <tr class="gt_row_group_first" style="border-style: none;"><td headers="Inpatient  pod_name" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">a</td>
      <td headers="Inpatient  baseline" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">1</td>
      <td headers="Inpatient  principal" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #686f73; width: 33.3333333333333%">&nbsp;</span>
        <span style="width: 50%" align="right">4</span>
      </div></td>
      <td headers="Inpatient  change" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">3</span>
      </div></td>
      <td headers="Inpatient  change_pcnt" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">300%</span>
      </div></td></tr>
          <tr class="gt_group_heading_row" style="border-style: none;">
            <th colspan="5" class="gt_group_heading" scope="colgroup" id="Outpatient" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; color: #FFFFFF; background-color: #686F73; font-size: 100%; font-weight: initial; text-transform: inherit; border-top-style: solid; border-top-width: 2px; border-top-color: #000000; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #000000; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; text-align: left;" bgcolor="#686F73" valign="middle" align="left">Outpatient</th>
          </tr>
          <tr class="gt_row_group_first" style="border-style: none;"><td headers="Outpatient  pod_name" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">b</td>
      <td headers="Outpatient  baseline" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">2</td>
      <td headers="Outpatient  principal" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #686f73; width: 41.6666666666667%">&nbsp;</span>
        <span style="width: 50%" align="right">5</span>
      </div></td>
      <td headers="Outpatient  change" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">3</span>
      </div></td>
      <td headers="Outpatient  change_pcnt" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 25%">&nbsp;</span>
        <span style="width: 50%" align="right">150%</span>
      </div></td></tr>
          <tr class="gt_group_heading_row" style="border-style: none;">
            <th colspan="5" class="gt_group_heading" scope="colgroup" id="A&amp;amp;E" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; color: #FFFFFF; background-color: #686F73; font-size: 100%; font-weight: initial; text-transform: inherit; border-top-style: solid; border-top-width: 2px; border-top-color: #000000; border-bottom-style: solid; border-bottom-width: 2px; border-bottom-color: #000000; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; text-align: left;" bgcolor="#686F73" valign="middle" align="left">A&amp;E</th>
          </tr>
          <tr class="gt_row_group_first" style="border-style: none;"><td headers="A&E  pod_name" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">c</td>
      <td headers="A&E  baseline" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left">3</td>
      <td headers="A&E  principal" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #686f73; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">6</span>
      </div></td>
      <td headers="A&E  change" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 50%">&nbsp;</span>
        <span style="width: 50%" align="right">3</span>
      </div></td>
      <td headers="A&E  change_pcnt" class="gt_row gt_left" style="border-style: none; padding-top: 8px; padding-bottom: 8px; padding-left: 5px; padding-right: 5px; margin: 10px; border-top-style: solid; border-top-color: #FFFFFF; border-left-style: none; border-left-width: 1px; border-left-color: #D3D3D3; border-right-style: none; border-right-width: 1px; border-right-color: #D3D3D3; vertical-align: middle; overflow-x: hidden; text-align: left; border-top-width: 2px;" valign="middle" align="left"><div>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: transparent; width: 0%">&nbsp;</span>
        <span style="display: inline-block; direction: ltr; border: 0; background-color: #f9bf07; width: 16.6666666666667%">&nbsp;</span>
        <span style="width: 50%" align="right">100%</span>
      </div></td></tr>
        </tbody>
        
        
      </table>
      </div>

