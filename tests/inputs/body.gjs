{{!
    https://github.com/miguelcobain/ember-yeti-table/raw/a6642a4f16b6786a0f72d1caaa3270d0cb194d05/ember-yeti-table/src/components/yeti-table/body.gjs
}}
import { action } from '@ember/object';

import Component from '@glimmer/component';

/**
  Renders a `<tbody>` element and yields the row component, row data and index.
  ```hbs
  <table.body as |body person index|>
    <body.row as |row|>
      <row.cell>
        {{person.firstName}} #{{index}}
      </row.cell>
      <row.cell>
        {{person.lastName}}
      </row.cell>
      <row.cell>
        {{person.points}}
      </row.cell>
    </body.row>
  </table.body>
  ```
  It can also be used as a blockless component to let yeti table automatically
  unroll thee rows for you, based on the `@prop` arguments you passed in to the
  column definition components.
  ```hbs
  <table.body/>
  ```
  Remember that this component's block will be rendered once per each item in the `@data` array.

  @class Body
  @yield {object} body
  @yield {Component} body.row - the row component
  @yield {Object} rowData - one item in the data array
  @yield {number} index
*/

// template imports
import { fn, get, hash } from '@ember/helper';
import TBodyRow from './tbody/row.gjs';

export default class Body extends Component {
  <template>
    <tbody class={{@theme.tbody}} ...attributes>
      {{#if (has-block)}}

        {{#each @data as |rowData index|}}
          {{yield (hash row=(component TBodyRow theme=@theme onClick=@onRowClick columns=@columns)) rowData index}}
        {{/each}}

      {{else}}

        {{#each @data as |rowData|}}
          <TBodyRow
            @theme={{@theme}}
            @onClick={{if @onRowClick (fn this.handleRowClick rowData)}}
            @columns={{@columns}}
            as |row|
          >

            {{#each @columns as |column|}}
              <row.cell @class={{column.columnClass}}>
                {{#if column.prop}}
                  {{get rowData column.prop}}
                {{else}}
                  {{rowData}}
                {{/if}}
              </row.cell>
            {{/each}}
          </TBodyRow>
        {{/each}}
      {{/if}}
    </tbody>
  </template>
  /**
   * Adds a click action to each row, called with the clicked row's data as an argument.
   * Can be used with both the blockless and block invocations.
   *
   * @argument onRowClick
   * @type Function
   */

  @action
  handleRowClick(rowData) {
    this.args.onRowClick?.(rowData);
  }
}
