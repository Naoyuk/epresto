import CheckboxSelectAll from 'stimulus-checkbox-select-all'

export default class extends CheckboxSelectAll {
  static target = ['checkbox', 'checkboxAll']
  connect() {
    super.connect()
    console.log(this.checkboxTarget.value)

    // Get all checked checkboxes
    this.checked

    // Get all unchecked checkboxes
    this.unchecked
  }
}
