{{! partial of
    https://raw.githubusercontent.com/josemarluedke/frontile/a9680f2681a8b1193feba0fdc27871566bcde120/packages/forms/src/components/input.gts
}}
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';
import { on } from '@ember/modifier';
import {
  useStyles,
  type InputSlots,
  type InputVariants,
  type SlotsToClasses
} from '@frontile/theme';
import { FormControl, type FormControlSharedArgs } from './form-control';
import { triggerFormInputEvent } from '../utils';
import { ref } from '@frontile/utilities';
import { CloseButton } from '@frontile/buttons';

interface Args extends FormControlSharedArgs {
  type?: string;
  value?: string;
  name?: string;
  size?: InputVariants['size'];
  classes?: SlotsToClasses<InputSlots>;

  /**
   * Whether to include a clear button
   */
  isClearable?: boolean;

  /**
   * Controls pointer-events property of startContent.
   * If you want to pass the click event to the input, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  startContentPointerEvents?: 'none' | 'auto';

  /**
   * Controls pointer-events property of endContent.
   * If you want to pass the click event to the input, set it to `none`.
   *
   * @defaultValue 'auto'
   */
  endContentPointerEvents?: 'none' | 'auto';

  /**
   * Callback when oninput is triggered
   */
  onInput?: (value: string, event?: InputEvent) => void;

  /**
   * Callback when onchange is triggered
   */
  onChange?: (value: string, event?: InputEvent) => void;
}

interface InputSignature {
  Args: Args;
  Blocks: {
    startContent: [];
    endContent: [];
  };
  Element: HTMLInputElement;
}

function or(arg1: unknown, arg2: unknown): boolean {
  return !!(arg1 || arg2);
}

class Input extends Component<InputSignature> {
  @tracked uncontrolledValue: string = '';

  inputRef = ref<HTMLInputElement>();

    if (this.isControlled) {
      this.args.onInput?.(value, event as InputEvent);
    } else {
      this.uncontrolledValue = value;
    }
  }

  @action handleOnChange(event: Event): void {
    const value = (event.target as HTMLInputElement).value;

    if (this.isControlled) {
      this.args.onChange?.(value, event as InputEvent);
    } else {
      this.uncontrolledValue = value;
    }
  }

    this.inputRef.element?.focus();
    triggerFormInputEvent(this.inputRef.element);
  }

  <template>
    <FormControl
      @size={{@size}}
      @label={{@label}}
      @isRequired={{@isRequired}}
      @description={{@description}}
      @errors={{@errors}}
      @isInvalid={{@isInvalid}}
      @class={{this.classes.base class=@classes.base}}
      as |c|
    >
      <div class={{this.classes.innerContainer class=@classes.innerContainer}}>
        {{#if (has-block "startContent")}}
          <div
            data-test-id="input-start-content"
            class={{this.classes.startContent
              class=@classes.startContent
              startContentPointerEvents=(if
                @startContentPointerEvents @startContentPointerEvents "auto"
              )
            }}
          >
            {{yield to="startContent"}}
          </div>
        {{/if}}
        <input
          {{this.inputRef.setup}}
          {{on "input" this.handleOnInput}}
          {{on "change" this.handleOnChange}}
          id={{c.id}}
          }}
          data-component="input"
          aria-invalid={{if c.isInvalid "true"}}
          aria-describedby={{c.describedBy @description c.isInvalid}}
          ...attributes
        />
        {{#if (or (has-block "endContent") this.isClearable)}}
          <div
          >
            {{yield to="endContent"}}

            {{#if this.isClearable}}
              <CloseButton
              />
            {{/if}}
          </div>
        {{/if}}
      </div>
    </FormControl>
  </template>
}

export { Input, type InputSignature };
export default Input;
